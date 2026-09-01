# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of cross-platform bash scripts for Linux, Mac, and Windows (via WSL/Git Bash). The repository provides utilities for development automation, git management, file operations, and system configuration. Scripts are organized by function into directories.

## Code Quality and Standards

### ShellCheck Configuration
- Uses `.shellcheckrc` with `external-sources=true` setting
- All scripts should pass ShellCheck validation
- Run: `shellcheck script_name.sh`

### Coding Style
Follows the Unofficial Shell Scripting Stylesheet conventions:
- `variable_name` - Lower case with underscores for variables
- `CONSTANT_NAME` - Upper case for constants
- `E_ERROR_CODE` - Error codes prefixed with "E_"
- `FunctionName` - Upper case for function names

### Script Template
Use `lib/bash-template.sh` as the starting point for new scripts:
- Includes bash strict mode: `set -euo pipefail`
- Provides debugging toggle via `set +x`/`set -x`

## Architecture and Shared Components

### Library Structure
- `lib/` - Shared utilities that other scripts depend on
  - `bash-template.sh` - Standard template with strict mode (`set -euo pipefail`)
  - `colors.sh` - Terminal color definitions and `color_echo()` function
    - Source with: `source "${SCRIPT_PATH}"/../lib/colors.sh`
    - Provides comprehensive color constants (RESET, RED, GREEN, etc.)
    - Mac-compatible using '\033' instead of '\e'

### Common Patterns
All scripts follow these patterns:
- Use bash strict mode (`set -euo pipefail`)
- Include help functionality via `-h`/`--help` flags
- Source `colors.sh` for consistent terminal output
- Use `IFS=$'\n\t'` for safe word splitting

## Directory Structure and Key Scripts

### daylog/ - Daily Logging Tools
- `diary.sh` - Interactive diary with git integration and editor support
- `daylog.sh` - Daily log entry creation
- `daylog_cfg.sh` - Configuration management

### git/ - Repository Management
- `syncall.sh` - Synchronizes all git repositories in ~/Repos/
- `create_github_repo.sh` - GitHub repository creation
- `pushpull.sh`, `syncdirs.sh` - Various sync utilities

### files/ - File Operations
- `savefiletree.sh` - Directory tree generation and file consolidation

### cfg/ - System Configuration
- `install_dotfiles.sh` - Dotfiles setup for new systems
- `install_source_code_pro.sh` - Font installation

### linux/ - Linux-Specific Utilities
- `toggle_touchscreen.sh` - Interactive touchscreen toggle
- `fix_touchpad.sh` - Recover an I2C HID touchpad that failed to probe at boot

### ai/ - AI Processing Tools
- `wav_2_txt.sh` - Whisper-based audio transcription with timing metrics

### net/ - Network Utilities
- DNS testing and lookup scripts (`dns_test.sh`, `dig_test.sh`, `ns_test.sh`)

### updates/ - System Update Automation
- System update utilities

## Troubleshooting Reminders

### Dead mouse pointer / touchpad (baby-dell, Dell Inspiron 3185)

**Run `linux/fix_touchpad.sh` first. Do not re-diagnose this from scratch.**

```bash
./linux/fix_touchpad.sh --check   # report status, change nothing
./linux/fix_touchpad.sh           # reload the driver, then re-probe
```

On baby-dell the touchpad is an I2C HID device (`DELL087F:00 04F3:3082`) that
intermittently fails to probe at boot with error `-121` (EREMOTEIO). It failed on
8 of 12 boots sampled between 2026-08-22 and 2026-09-01.

The trap: a phantom `ETPS/2 Elantech Touchpad` enumerates on *every* boot, even when
the real touchpad is dead. So `xinput list` shows an enabled touchpad and the XFCE
pointer settings look correct while the pointer does not work. Do not trust
`xinput list` to diagnose this; check the kernel's device list instead, which is what
`fix_touchpad.sh` does.

If the reload does not recover it, cold power cycle: shut down, hold the power button
for ~30 seconds, then boot. BIOS 1.5.0 (August 2022) is the final release for this
model, so no firmware fix is pending.

## Development Commands

### Code Quality
```bash
# Check scripts with shellcheck (if available)
shellcheck script.sh

# The repository includes .shellcheckrc with external-sources=true
```

### Testing Scripts
1. Validate syntax: `bash -n script_name.sh`
2. Run ShellCheck: `shellcheck script_name.sh`
3. Test with various inputs and edge cases

Scripts include help information accessible via:
```bash
./script.sh -h
./script.sh --help
```

## Development Workflow

### Creating New Scripts
1. Copy `lib/bash-template.sh` as starting point
2. Follow established naming conventions
3. Include proper help documentation
4. Source `lib/colors.sh` for consistent output
5. Add executable permissions: `chmod +x script_name.sh`

### Script Requirements
- All scripts must be executable
- Include proper shebang: `#!/bin/bash`
- Use strict mode: `set -euo pipefail`
- Source color library for consistent output formatting
- Include help documentation accessible via `-h` or `--help`

### Git Management
- Scripts automatically handle git operations where applicable
- Use provided git utilities for repository synchronization
- Ensure scripts work across different git repository states

## Usage Patterns

Scripts follow consistent CLI patterns:
- `-h, --help` for help
- `-v, --version` for version info
- `-c, --config` for configuration display (where applicable)

Example usage:
```bash
# Run script with help
./daylog/diary.sh --help

# Configure and run daylog
./daylog/daylog_cfg.sh
./daylog/daylog.sh

# Git repository management
./git/syncall.sh
```

## Dependencies

- Bash 4.0+ required
- Standard Unix utilities (find, tree, etc.)
- Git for repository management scripts
- Scripts handle cross-platform compatibility (Linux/Mac/Windows WSL)
