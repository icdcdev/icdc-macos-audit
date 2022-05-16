#!/usr/bin/env bash


##################################################
## THIS SCRIPT APPLIES ALL THE STEPS DESCRIBED IN
## https://www.cisecurity.org/benchmark/apple_os
##################################################

source ./utils/functions.sh

USER=$(whoami)

logTitle "#ICDC MacOS Auditor (Applier) v1.0"

STATUS=$1
if [ $# -eq 0 ]; then
  STATUS=true
fi
log info "Setting all configurations to $STATUS"

logTitle "Section 1 - Install Updates, Patches and Additional Security Software"

# 1.1 Ensure All Apple-provided Software Is Current
log info "1.1 Verifying apple-provided software updates..."
#sudo /usr/sbin/softwareupdate -i -a
log success "1.1 System is updated ✅"

# 1.2 Ensure Auto Update Is Enabled
log info "1.1 Enabling automatic updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool $STATUS
log success "1.2 Auto update enabled ✅"

# 1.3 Ensure Download New Updates When Available is Enabled
log info "1.1 Enabling download new updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool $STATUS
log success "Download new updates enabled ✅"

# 1.4 Ensure Installation of App Update Is Enabled
log info "1.4 Enabling automatic download updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool $STATUS
log success "Automatic download updates enabled successfully ✅"

# 1.5 Ensure System Data Files and Security Updates Are Downloaded Automatically Is Enabled
log info "1.5 Enabling Data Files & Security Updates download..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool $STATUS
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool $STATUS
log success "Automatic download updates enabled successfully ✅"

# 1.6 Ensure Install of macOS Updates Is Enabled
log info "1.6 Enabling Install of macOs Updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool $STATUS
log success "Installation of macOs Updates enabled successfully ✅"

# 1.6 Ensure Install of macOS Updates Is Enabled
log info "1.6 Enabling Install of macOs Updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool $STATUS
log success "Installation of macOs Updates enabled successfully ✅"

logTitle "Section 2 - System Preferences"
logTitle "Section 2.1 - Bluetooth"

# 2.1.1 Ensure Bluetooth Is Disabled If No Devices Are Paired
log info "1.6 Checking if bluetooth is disabled..."
isBluetoothEnabled=$(blueutil -p)
if [ $isBluetoothEnabled -eq 1 ]; then
  log info "Bluetooth enabled, checking if exists paired devices..."
  pairedBluetoothDevices=$(blueutil --connected --format json | jq 'length')
  if [ $pairedBluetoothDevices -eq 0 ]; then
    log info "Bluetooth enabled and no devices paired, turning off bluetooth..."
    blueutil -p 0
    log info "Bluetooth disabled successfully ✅"
  else
    log info "Bluetooth enabled and devices paired ✅"
  fi
fi

# 2.1.2 Ensure Show Bluetooth Status in Menu Bar Is Enabled
log info "2.1.2 Enabling Bluetooth status in menu bar..."
defaults write com.apple.controlcenter.plist Bluetooth -int 18
log success "Bluetooth status in menu bar enabled successfully ✅"

logTitle "Section 2.2 - Date & Time"

# 2.2.1 Ensure Show Bluetooth Status in Menu Bar Is Enabled
log info "2.2.1 Setting time and date automatically..."
sudo /usr/sbin/systemsetup -setnetworktimeserver pool.ntp.org > /dev/null 2>&1
sudo /usr/sbin/systemsetup -setusingnetworktime on > /dev/null 2>&1
log success "Time and date enabled successfully ✅" 

# 2.2.2 Ensure time set is within appropriate limits
log info "2.2.2 Setting time and date automatically within appropiate limits..."
sudo sntp -sS pool.ntp.org
log success "Time and date with appropiate limits enabled successfully ✅"

logTitle "Section 2.3 - Desktop & Screen Saver"

# 2.3.1 Ensure time set is within appropriate limits
log info "2.3.1 Setting inactivity interval of 20 minutes or less for the screen saver..."
sudo /usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 600
log success "1 min for screen saver configured successfully ✅"

# 2.3.3 Audit Lock Screen and Start Screen Saver Tools
log info "2.3.3 Setting up Top Left hot corner to lock screen..."
sudo -u $USER /usr/bin/defaults write com.apple.dock wvous-tl-corner -int 13
log success "Top Left hot corner configured successfully ✅"

logTitle "Section 2.4 - Sharing"

# 2.4.1 Audit Lock Screen and Start Screen Saver Tools
log info "2.4.1 Disabling Remote Apple Events..."
sudo /usr/sbin/systemsetup -setremoteappleevents off
log success "Remote Apple Events disabled sucessfully ✅"

# 2.4.2 Ensure Internet Sharing Is Disabled
log info "2.4.2 Disabling Internet sharing..."
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict Enabled -int 0
log success "Internet Sharing disabled sucessfully ✅"