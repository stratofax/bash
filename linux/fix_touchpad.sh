#!/bin/bash

#######################################
# fix_touchpad.sh
#
# Recover an I2C HID touchpad that is missing or has stopped working.
#
# Some laptops (the Dell Inspiron 3185 in particular) attach their
# touchpad to the I2C bus via the i2c_hid_acpi driver. That probe
# fails intermittently with error -121 (EREMOTEIO), leaving the
# machine with no working pointer. Reloading the driver re-probes
# the device and usually brings it back without a reboot.
#
# WARNING: a phantom "ETPS/2 Elantech Touchpad" can appear in
# `xinput list` even when the real touchpad is dead, so a touchpad
# listed by xinput is NOT proof that the touchpad works. This
# script checks the kernel's own device list instead.
#
# Nor is the kernel's device list proof on its own: the touchpad can
# enumerate normally at boot and then drop off the I2C bus minutes
# later, leaving a stale device node behind. So the device list
# answers "is it there?" and the kernel log answers "does it still
# work?". Both have to agree before we call the touchpad healthy.
#######################################

# turn on output for debugging
#set -x
# turn off output for production
set +x
# turn on unoffical bash strict mode
set -euo pipefail
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/colors.sh
source "${SCRIPT_DIR}"/../lib/colors.sh

# Error codes
readonly E_BAD_OPTION=1
readonly E_NO_MODULE=2
readonly E_RELOAD_FAILED=3
readonly E_STILL_MISSING=4

readonly TOUCHPAD_MODULE="i2c_hid_acpi"
readonly INPUT_DEVICES="/proc/bus/input/devices"
# Scopes kernel messages to this touchpad. The ACPI ID appears both in
# the driver's error lines ("i2c-DELL087F:00") and in the lines logged
# when the device registers an input or a HID driver binds to it, so one
# grep collects the whole story for this device and nothing else --
# notably not the ELAN touchscreen, which shares the 04F3 vendor ID.
readonly TOUCHPAD_ACPI_ID="DELL087F"
# The re-probe is not instant; it took about 6 seconds on the Inspiron 3185.
readonly WAIT_SECONDS=15

ShowHelp () {
    cat <<HELP_EOF
Usage: $(basename "$0") [-c|--check] [-h|--help]

Recover an I2C HID touchpad that failed to probe at boot, or that
probed and later dropped off the bus, by reloading the
${TOUCHPAD_MODULE} kernel module.

Options:
  -c, --check   Report touchpad status only; make no changes
  -h, --help    Show this help and exit

Exit codes:
  0                  touchpad present (or successfully recovered)
  ${E_BAD_OPTION}                  unknown option
  ${E_NO_MODULE}                  ${TOUCHPAD_MODULE} not available on this system
  ${E_RELOAD_FAILED}                  module reload failed
  ${E_STILL_MISSING}                  touchpad still not working after the reload

If this script does not recover the touchpad, power the machine
right down, hold the power button for ~30 seconds, then boot.
HELP_EOF
}

# Print the name of the kernel's I2C HID touchpad, if it has one.
# Reads $INPUT_DEVICES in paragraph mode: one record per device,
# one field per line. A real I2C touchpad has both a name matching
# "touchpad" and a sysfs path under an i2c bus, which is what
# distinguishes it from the PS/2 phantom.
FindTouchpad () {
    awk 'BEGIN { RS = ""; FS = "\n" }
        {
            name = ""
            sysfs = ""
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^N: Name=/) {
                    name = $i
                    sub(/^N: Name="/, "", name)
                    sub(/"$/, "", name)
                }
                if ($i ~ /^S: Sysfs=/) {
                    sysfs = $i
                }
            }
            if (tolower(name) ~ /touchpad/ && sysfs ~ /\/i2c-/) {
                print name
            }
        }' "${INPUT_DEVICES}"
}

# Report whether the kernel's last word on the touchpad was an error.
#
# A -121 is not by itself proof of a dead touchpad. The driver retries,
# and a failed report fetch is often followed moments later by a
# successful bind, which means something recovered it. What matters is
# which came last. Kernel messages are chronological, so the final line
# mentioning this device tells us the state it was left in: a "failed"
# line with nothing after it means nothing recovered the device, while
# a bind or input-registration line means it came back.
#
# Returns 1 when journalctl is unavailable, so a system without it
# falls back to the device-list check alone rather than crying wolf.
TouchpadFailedSinceLastProbe () {
    if ! command -v journalctl > /dev/null 2>&1; then
        return 1
    fi
    local last
    last="$(journalctl -k -b 0 2>/dev/null | grep "${TOUCHPAD_ACPI_ID}" | tail -1 || true)"
    case "${last}" in
        *failed*) return 0 ;;
        *)        return 1 ;;
    esac
}

# Run a command as root, asking for sudo only when we need it.
RunPrivileged () {
    if [ "${EUID}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Show the most recent kernel complaints from the driver, as evidence.
ShowKernelErrors () {
    if ! command -v journalctl > /dev/null 2>&1; then
        return 0
    fi
    local errors
    errors="$(journalctl -k -b 0 2>/dev/null | grep "${TOUCHPAD_ACPI_ID}" | tail -5 || true)"
    if [ -n "${errors}" ]; then
        color_echo "${YELLOW}" "Recent kernel messages for this touchpad:"
        echo "${errors}"
    fi
}

# --- Command Line Options ---

check_only=false

case "${1:-}" in
    -h|--help)
        ShowHelp
        exit 0
        ;;
    -c|--check)
        check_only=true
        ;;
    "")
        ;;
    *)
        color_echo "${RED}" "Unknown option: ${1}"
        ShowHelp
        exit "${E_BAD_OPTION}"
        ;;
esac

# --- Script Logic ---

touchpad_name="$(FindTouchpad)"

if [ -n "${touchpad_name}" ] && ! TouchpadFailedSinceLastProbe; then
    color_echo "${GREEN}" "Touchpad is present: ${touchpad_name}"
    exit 0
fi

if [ -n "${touchpad_name}" ]; then
    color_echo "${RED}" "Touchpad is present but not responding: ${touchpad_name}"
    color_echo "${YELLOW}" "It enumerated, then dropped off the bus -- the device node is stale."
else
    color_echo "${RED}" "No I2C touchpad found -- it failed to probe."
fi
ShowKernelErrors

if [ "${check_only}" = true ]; then
    exit "${E_STILL_MISSING}"
fi

if ! modinfo "${TOUCHPAD_MODULE}" > /dev/null 2>&1; then
    color_echo "${RED}" "Module ${TOUCHPAD_MODULE} is not available on this system."
    exit "${E_NO_MODULE}"
fi

color_echo "${CYAN}" "Reloading ${TOUCHPAD_MODULE} (sudo may ask for your password)..."

if ! RunPrivileged modprobe -r "${TOUCHPAD_MODULE}"; then
    color_echo "${RED}" "Could not unload ${TOUCHPAD_MODULE}."
    exit "${E_RELOAD_FAILED}"
fi

if ! RunPrivileged modprobe "${TOUCHPAD_MODULE}"; then
    color_echo "${RED}" "Could not load ${TOUCHPAD_MODULE}."
    exit "${E_RELOAD_FAILED}"
fi

color_echo "${CYAN}" "Waiting up to ${WAIT_SECONDS}s for the touchpad to re-probe..."

for (( second = 1; second <= WAIT_SECONDS; second++ )); do
    sleep 1
    touchpad_name="$(FindTouchpad)"
    if [ -n "${touchpad_name}" ] && ! TouchpadFailedSinceLastProbe; then
        color_echo "${GREEN}" "Touchpad recovered after ${second}s: ${touchpad_name}"
        exit 0
    fi
done

color_echo "${RED}" "Touchpad still not working after ${WAIT_SECONDS}s."
ShowKernelErrors
color_echo "${YELLOW}" "Try a cold power cycle: shut down, hold the power button ~30s, then boot."
exit "${E_STILL_MISSING}"
