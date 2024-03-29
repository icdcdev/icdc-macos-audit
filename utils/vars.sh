#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os


# Global variable to save all success points
# Type: INT
TOTAL_SUCCESS=0

# Global variable to save all warning points
# Type: INT
TOTAL_WARN=0

# Global variable which contains user name
# Type: STRING
USER=$(dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]' | awk -F ' *: ' '$1=="name"{print $2}')

# Global variable which contains user UUID
# Type: STRING
USER_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep "IOPlatformUUID" | sed -e 's/^.* "\(.*\)"$/\1/'`

# Global variable which contains url to configure as a time server
# Type: STRING
TIME_SERVER=time.apple.com

# Global variable which contains url to configure as a time server
# Type: STRING
LOGIN_MESSAGE="This system is reserved for authorized use only and may be monitored"

# Global variable which contains today date
# Type: STRING
TODAY=$(date "+%Y-%m-%d")

# Global variable which contains log location
# Type: STRING
LOG_FILE="/Users/$USER/icdc-macos.$TODAY.log"

# Export global variable for allowing blueutil tool to run as root
# Type: INT
BLUEUTIL_ALLOW_ROOT=1

export TOTAL_SUCCESS
export TOTAL_WARN
export USER
export USER_UUID
export TIME_SERVER
export LOGIN_MESSAGE
export TODAY
export LOG_FILE
export BLUEUTIL_ALLOW_ROOT