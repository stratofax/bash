#!/bin/bash
# Description
# By:      Neil Johnson
# Created: Monday,  September 11, 2006
#
# report undefined variables
shopt -s -o nounset

usage()
{
printf "%s tests command-line outgoing mail.\n", "$(basename $0)"
printf "usage: `basename $0` [-$OPTIONLIST] \n  by: Neil Johnson\nOptions:\n   -h   display this help \n   -i   display current settings \n   -t   test mail with current settings\n"
}
#set constants
declare TRUE=1
declare FALSE=0
HELP="$(FALSE)"
# Define the mail-specific variables
OPTIONLIST="hipt"
SHOWSETTINGS=$FALSE
MAILIT=$FALSE
computername="$(hostname)"
subject="Mail test from $(computername)"

# to="neil.johnson@gmail.com sysadmin@cadent.net"
# to="sysadmin@cadent.net"
# to="stratofax@yahoo.com"
to="neil@cadent.net"

cc=""
#cc="-c neil.johnson@gmail.com"
#cc="-c sysadmin@cadent.net,neil@cadent.com"
runby=`whoami`
rundate=`date "+%m/%d/%y"`
runtime=`date "+%H:%M:%S"`
datetime=`date "+%y%m%d%H%M%S"`
#the temporary directory must end in a slash!
tempdir="/var/tmp/"
filetitle="mail-test-"
mailfile="$tempdir$filetitle$datetime.txt"

if [ $# -eq 0 ]; then
  HELP=$TRUE
fi

while getopts $OPTIONLIST OPTION
do
  case $OPTION in
  h) # display help
    HELP=$TRUE
    subject="$subject -h"
    ;;
  i) # display settings
    SHOWSETTINGS=$TRUE
    subject="$subject -i"
    ;;
  t) # test mail
    MAILIT=$TRUE
    subject="$subject -t"
    ;;
  *) #unrecognized parameter
    HELP=$TRUE
    printf "For help, enter: `basename $0` -h\n"
    ;;
  esac
done

hr="----------"

# mailopts="-v -s \"$subject\" -c $cc $to"
mailopts=" -s "

headertext=`printf "Subject: $subject \nTo: $to \nCc: $cc"`

bodytext=`printf "This test message was generated\n by the account $runby\n on the computer $computername\n on $rundate at $runtime \nDelivery\n sent to $to\n cc $cc \nCommand \n mail $mailopts \"$subject\" $cc $to \nFile \n mail file: $mailfile\n"`

settings=`printf "Current Settings\n$hr\nHeaders \n$hr\n$headertext\n$hr\nBody Text\n$hr\n$bodytext\n$hr"`
# if help is requested, display and stop
if [ $HELP -eq $TRUE ]; then
  usage
fi

# show settings, if requested
if [ $SHOWSETTINGS -eq $TRUE ]; then
  printf "$settings\n"
fi

# send mail if requested
if [ $MAILIT -eq $TRUE ]; then
  printf "$bodytext" > $mailfile
  errwrite=$?
  if [ $errwrite -eq $FALSE ]; then
    # mail -v -s "$subject" -c $cc $to < $mailfile
    mail  $mailopts "$subject" $cc $to < $mailfile
    errmail=$?
    printf "Message sent successfully. (Result = $errmail) \n"
    exit $errmail
  else
    printf "Couldn't write mail file. Send cancelled. (Result = $errwrite)\n"
    exit $errwrite
  fi
fi


# report a clean exit
exit 0