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
LOGIN_MESSAGE="ICDC Login"

# Export global variable for allowing blueutil tool to run as root
# Type: INT
export BLUEUTIL_ALLOW_ROOT=1