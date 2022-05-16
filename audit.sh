#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

source ./utils/functions.sh

# Global variable to save all success points
# Type: INT
TOTAL_SUCCESS=0
# Global variable to save all warning points
# Type: INT
TOTAL_WARN=0
USER=$(whoami)
USER_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep "IOPlatformUUID" | sed -e 's/^.* "\(.*\)"$/\1/'`

logTitle "#ICDC MacOS Auditor v1.0"

checkSudoPermissions
#checkDependencies

logTitle "Section 1 - Install Updates, Patches and Additional Security Software"

# 1.1 Ensure All Apple-provided Software Is Current
log info "1.1 Ensure All Apple-provided Software Is Current"
lastFullSuccessfulDate=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate | awk -F '"' '$0=$2' | awk '{ print $1 }')
daysAfterFullSuccessfulDate=$(dateDiffNow $lastFullSuccessfulDate);
log info "Your system has $daysAfterFullSuccessfulDate days after your last successful date"
if [ $daysAfterFullSuccessfulDate -gt 30 ]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system is not updated, please update to lastest version ⚠️"
 else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "System is updated ✅"
fi


#1.2 Ensure Auto Update Is Enabled
log info "1.2 Ensure Auto Update Is Enabled... 🔍"
isAutomaticUpdatesEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled)
if [ $isAutomaticUpdatesEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have check automatic updates ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system does not have automatic updates ⚠️"
fi


# 1.3 Ensure Download New Updates When Available is Enabled
log info "1.3 Ensure Download New Updates When Available is Enabled"
isAutomaticDownloadEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload)
if [ $isAutomaticDownloadEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have automatic new download updates enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic new download updates ⚠️"
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

# 1.6 Ensure Install of macOS Updates Is Enabled
log info "1.6 Ensure Install of macOS Updates Is Enabled"
isAutomaticallyInstallMacOSUpdatesEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates)
if [ $isAutomaticallyInstallMacOSUpdatesEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "MacOS Automatically Updates are enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "MacOS Automatically Updates aren't enabled ⚠️"
fi

logTitle "Section 2.1 - Bluetooth"
# 2.1.1 Ensure Bluetooth Is Disabled If No Devices Are Paired
log info "2.1.1 Ensure Bluetooth Is Disabled If No Devices Are Paired"
isBluetoothEnabled=$(blueutil -p)
if [ $isBluetoothEnabled -eq 0 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bluetooth is disabled ✅"
elif [ $isBluetoothEnabled -eq 1 ]; then
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

logTitle "Section 2.2 - Date & Time"
# 2.2.1 Ensure "Set time and date automatically" Is Enabled
log info "2.2.1 Ensure 'Set time and date automatically' Is Enabled"
isSetTimeAndDateAutomatically=$(sudo /usr/sbin/systemsetup -getusingnetworktime | awk -F ": " '{print $2}')
if [ $isSetTimeAndDateAutomatically == "On" ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "'Set time and date automatically' Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "'Set time and date automatically' Is Disabled ⚠️"
fi

# 2.2.2 Ensure time set is within appropriate limits
log info "2.2.2 Ensure time set is within appropriate limits"
timeServer=$(sudo /usr/sbin/systemsetup -getnetworktimeserver | awk -F ": " '{print $2}')
if [ -z $timeServer ]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Not time server was found, please set pool.ntp.org ⚠️"
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

logTitle "Section 2.3 - Desktop & Screen Saver"

# 2.3.1 Ensure an Inactivity Interval of 20 Minutes Or Less for the Screen Saver Is Enabled
log info "2.3.1 Ensure an Inactivity Interval of 20 Minutes Or Less for the Screen Saver Is Enabled"
inactivityInterval=$(sudo /usr/bin/defaults -currentHost read com.apple.screensaver idleTime)
if [[ -z $inactivityInterval || $inactivityInterval -eq 0 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure an Inactivity Interval ⚠️"
else
  if (("$inactivityInterval" <= "1200" )); then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
    log success "Inactivity Period ✅"
  else
    TOTAL_WARN=$((TOTAL_WARN+1))
    log warn "Please configure an Inactivity Interval of 20 Minutes Or Less (Current: $((inactivityInterval/60)) minutes) ⚠️"
  fi
fi

# 2.3.3 Audit Lock Screen and Start Screen Saver Tools
log info "2.3.3 Audit Lock Screen and Start Screen Saver Tools"
hasTopLeftCornerActive=$(sudo -u $USER /usr/bin/defaults read com.apple.dock wvous-tl-corner)
if [[ -z $hasTopLeftCornerActive || $hasTopLeftCornerActive -ne 13 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure a top left hot corner"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Top Left Hot corner ✅"
fi

logTitle "Audit Overview"
log warn "Total: ${TOTAL_WARN} ⚠️"
log success "Total: ${TOTAL_SUCCESS} ✅"







# log info "Installing software updates... 🤖"
# sudo /usr/sbin/softwareupdate -i -a -R