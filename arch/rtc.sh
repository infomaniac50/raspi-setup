#!/bin/bash

function package_installed() {
  pacman -Q $1 2>/dev/null >/dev/null
  return $?
}

function read_ans()
{
  local ans=""
  read -p "$1 [y/n]" ans
  return $ans == 'y' || $ans == 'Y'
}

function find_rtc()
{
  i2cdetect -y $1
  return read_ans 'Did you see 0x68 in the device list?'
}

DEVICE=""

if [[ ! package_installed "i2c-tools" ]]; then
  read -p "We need to install i2c-tools. Press Enter to continue"
  pacman -S i2c-tools
fi

if  [[ find_rtc "1" ]]; then
  DEVICE="/sys/class/i2c-adapter/i2c-1/new_device"
elif [[ find_rtc "0" ]]; then
  DEVICE="/sys/class/i2c-adapter/i2c-0/new_device"
else
  echo "Unknown board"
  exit 1
fi

modprobe rtc-ds1307

echo "ds1307 0x68" > $DEVICE

echo "Setup done trying to read from RTC"
hwclock -r
if [[ read_ans 'Did the RTC return a timestamp?' ]]; then
  echo 'Success.'
  echo 'If the time is way off, the best way to set it is to have your system time synced via NTP, then run:'
  echo '# hwclock -w'
  echo 'and verify again with:'
  echo '# hwclock -r'
  echo 'If your RTC is showing the correct time, you can set your system time to it by running'
  echo '# hwclock -s'
else
  echo 'Failure'
fi
