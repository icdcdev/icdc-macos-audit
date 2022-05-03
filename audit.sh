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

#######################################
# Print a message to console
# GLOBALS: N/A
# ARGUMENTS:
#   ${1} STRING - Message level (e.g error, success, warn, info)
#   ${2} STRING - Message that will be printed
# OUTPUTS:
#   Write String with echo to terminal output
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
function log(){
  local red='\033[0;31m'
  local green='\033[0;32m'
  local yellow='\033[1;33m'
  local blue='\033[0;34m'
  local reset='\033[0m'

  local message="${2}"
  local level="${1}"
  local color=""

  case $level in
    error)
      color=$red
    ;;
    success)
      color=$green
    ;;
    warn)
      color=$yellow
    ;;
    info)
      color=$blue
    ;;
  esac

  echo -e "${color} `date "+%Y/%m/%d %H:%M:%S"`" $message$" ${reset}"
}

#######################################
# Calculate the number of days that have passed since a given date
# GLOBALS: N/A
# ARGUMENTS:
#   ${1} STRING - Date to use in format YYYY-MM-DD
# OUTPUTS: N/A
# RETURN:
#   INTEGER - The number of days that have passed since date given
#######################################
function dateDiffNow(){
  now=$(date "+%Y-%m-%d")
  echo $(( ($(date -d $now +%s) - $(date -d $1 +%s)) / 86400 ))  
}

log info "========================"
log info "#ICDC MacOS Auditor v1.0"
log info "========================"
echo -e "\n"
log info "Asking for root permissions..."

if [[ "$EUID" = 0 ]]; then
  log success "You are root 🤖"
else
  sudo -k
  if sudo true; then
    log success "Login successfully 🤖"
  else
    log error "Wrong password, please retry ❌"
    exit 1
  fi
fi

echo -e "\n"
log info "======================================"
log info "Checking if dependencies are installed"
log info "======================================"
echo -e "\n"
log info "Checking if Homebrew is installed"
if [[ $(command -v brew) == "" ]]; then
  echo "Installing Hombrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  log success "Hombrew is installed ✅}"
fi

log info "Checking if Blueutil is installed"
if [[ $(command -v blueutil) == "" ]]; then
  echo "Installing Blueutil"
  brew install blueutil
else
  log success "Blueutil is installed ✅}"
fi

log info "Checking if jq is installed"
if [[ $(command -v jq) == "" ]]; then
  echo "Installing jq"
  brew install jq
else
  log success "jq is installed ✅}"
fi



echo -e "\n"
log info "====================================================================="
log info "Section 1 - Install Updates, Patches and Additional Security Software"
log info "====================================================================="
echo -e "\n"

# 1.1 Ensure All Apple-provided Software Is Current
log info "1.1 Ensure All Apple-provided Software Is Current... 🔍"
lastFullSuccessfulDate=$(/usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate | awk -F '"' '$0=$2' | awk '{ print $1 }')
daysAfterFullSuccessfulDate=$(dateDiffNow $lastFullSuccessfulDate);
log info "Your system has $daysAfterFullSuccessfulDate days after your last successful date"
if [ $daysAfterFullSuccessfulDate -gt 30 ]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system is not updated, please update to lastest version ⚠️"
 else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system is updated ✅"
fi


# 1.2 Ensure Auto Update Is Enabled
log info "1.2 Ensure Auto Update Is Enabled... 🔍"
isAutomaticUpdatesEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled)
if [ $isAutomaticUpdatesEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have check automatic updates ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic updates ⚠️"
  #log warn "Enabling automatic updates..."
  #sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  #log success "Automatic updates enabled successfully ✅"
fi


# 1.3 Ensure Download New Updates When Available is Enabled
log info "1.3 Ensure Download New Updates When Available is Enabled"
isAutomaticDownloadEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload)
if [ $isAutomaticDownloadEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have automatic download updates enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic download updates ⚠️"
  #log warn "Enabling automatic download updates..."
  #sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
  #log success "Automatic download updates enabled successfully ✅"
fi


# 1.4 Ensure Installation of App Update Is Enabled
log info "1.4 Ensuring if installation of app update is enabled"
isNewUpdatesAppEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.commerce AutoUpdate)
if [ $isNewUpdatesAppEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have automatic app download updates enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic app download updates ⚠️"
  #log warn "Enabling automatic download updates..."
  #sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
  #log success "Automatic download updates enabled successfully ✅"
fi


# 1.5 Ensure System Data Files and Security Updates Are Downloaded Automatically Is Enabled
log info "1.5 Ensure System Data Files and Security Updates Are Downloaded Automatically Is Enabled"
isSystemDataFilesConfig=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall)
isSystemDataFilesCritical=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall)
if [[ $isSystemDataFilesConfig -eq 1 && $isSystemDataFilesCritical -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "System Data Files and Security Updates Are Downloaded Automatically Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "System Data Files and Security Updates Are Downloaded Automatically aren't Enabled ⚠️"
fi

# 1.5 Ensure Install of macOS Updates Is Enabled
log info "1.6 Ensure Install of macOS Updates Is Enabled"
isAutomaticallyInstallMacOSUpdatesEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates)
if [ $isAutomaticallyInstallMacOSUpdatesEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "MacOS Automatically Updates are enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "MacOS Automatically Updates aren't enabled ⚠️"
fi

echo -e "\n"
log info "====================="
log info "Section 2 - Bluetooth"
log info "====================="
echo -e "\n"

# 2.1.1 Ensure Bluetooth Is Disabled If No Devices Are Paired
log info "2.1.1 Ensure Bluetooth Is Disabled If No Devices Are Paired"
isBluetoothDisabledIfNoDevicesArePaired=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState)
if [ $isBluetoothDisabledIfNoDevicesArePaired -eq 0 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bluetooth is disabled and not paired devices found ✅"
elif [ $isBluetoothDisabledIfNoDevicesArePaired -eq 1 ]; then
  #Checking if exists paired devices
  pairedBluetoothDevices=$(blueutil --connected --format json | jq 'length')
  if [ $pairedBluetoothDevices -eq 1 ]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
    log success "Bluetooth is enabled and paired devices were found ✅"
  else
    TOTAL_WARN=$((TOTAL_WARN+1))
    log warn "Bluetooth is enabled and paired devices were not found ⚠️"
  fi
fi

# 2.1.2 Ensure Show Bluetooth Status in Menu Bar Is Enabled
log info "2.1.2 Ensure Show Bluetooth Status in Menu Bar Is Enabled"
isBluetoothVisibleOnMenuBar=$(defaults read com.apple.controlcenter.plist | grep "NSStatusItem Visible Bluetooth" | awk '{print $5}')
if [ $isBluetoothVisibleOnMenuBar == "1;" ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bluetooth status in menu bar is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Bluetooth status in menu bar is disabled ⚠️"
fi

# 2.2.1 Ensure "Set time and date automatically" Is Enabled
log info "2.1.2 Ensure 'Set time and date automatically' Is Enabled"
isSetTimeAndDateAutomatically=$(sudo /usr/sbin/systemsetup -getusingnetworktime | awk -F ": " '{print $2}')
if [ $isSetTimeAndDateAutomatically == "On" ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "'Set time and date automatically' Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "'Set time and date automatically' Is Disabled ⚠️"
fi

# 2.2.2 Ensure "Set time and date automatically" Is Enabled
log info "2.1.2 Ensure time set is within appropriate limits"
timeServer=$(sudo /usr/sbin/systemsetup -getnetworktimeserver | awk -F ": " '{print $2}')
if [ -z $timeServer ]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Not time server was found, please set time.apple.com ⚠️"
else
  secondsFirstValue=$(sudo sntp $timeServer | awk -F " " '{print $1}' | awk -F "+" '{print $2}')
  secondsSecondValue=$(sudo sntp $timeServer | awk -F " " '{print $3}')
  if [[ $secondsFirstValue > -270 && $secondsSecondValue < 270 ]]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
    log success "Time is set within an appropriate limits ✅"
  else
    TOTAL_WARN=$((TOTAL_WARN+1))
    log warn "Time is not set within an appropriate limits, please set between -270 and 270 seconds ⚠️"
  fi
fi


echo -e "\n"
log info "=============="
log info "Audit Overview"
log info "=============="
log warn "Total: ${TOTAL_WARN} ⚠️"
log success "Total: ${TOTAL_SUCCESS} ✅"







# log info "Installing software updates... 🤖"
# sudo /usr/sbin/softwareupdate -i -a -R