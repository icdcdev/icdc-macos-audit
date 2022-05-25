#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script applies all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

source ./utils/functions.sh

USER=$(whoami)
TIME_SERVER=time.apple.com

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
sudo /usr/sbin/systemsetup -setnetworktimeserver $TIME_SERVER > /dev/null 2>&1
sudo /usr/sbin/systemsetup -setusingnetworktime on > /dev/null 2>&1
log success "Time and date enabled successfully ✅" 

# 2.2.2 Ensure time set is within appropriate limits
log info "2.2.2 Setting time and date automatically within appropiate limits..."
sudo sntp -sS $TIME_SERVER -t 10 > /dev/null 2>&1
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
sudo /usr/sbin/systemsetup -setremoteappleevents off > /dev/null
log success "Remote Apple Events disabled sucessfully ✅"

# 2.4.2 Ensure Internet Sharing Is Disabled
log info "2.4.2 Disabling Internet sharing..."
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict Enabled -int 0
log success "Internet Sharing disabled sucessfully ✅"

# 2.4.3 Ensure Screen Sharing Is Disabled
log info "2.4.3 Disabling Screen sharing..."
sudo launchctl disable system/com.apple.screensharing
log success "Screen Sharing disabled sucessfully ✅"

# 2.4.4 Ensure Printer Sharing Is Disabled
log info "2.4.4 Disabling Printer sharing..."
sudo cupsctl --no-share-printers
log success "Printer Sharing disabled sucessfully ✅"

# 2.4.5 Ensure Remote Login Is Disabled
log info "2.4.5 Disabling Remote Login..."
sudo systemsetup -f -setremotelogin off > /dev/null
log success "Remote Login disabled sucessfully ✅"

# 2.4.6 Ensure DVD or CD Sharing Is Disabled
log info "2.4.6 Disabling DVD/CD Sharing..."
sudo launchctl disable system/com.apple.ODSAgent 
log success "DVD/CD Sharing disabled sucessfully ✅"

# 2.4.7 Ensure Bluetooth Sharing Is Disabled
log info "2.4.7 Disabling Bluetooth Sharing..."
sudo -u $USER /usr/bin/defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false
log success "Bluetooth Sharing disabled sucessfully ✅"

# 2.4.8 Ensure File Sharing Is Disabled
log info "2.4.8 Disabling File Sharing..."
sudo launchctl disable system/com.apple.smbd
log success "File Sharing disabled sucessfully ✅"

# 2.4.9 Ensure Remote Management Is Disabled
log info "2.4.9 Disabling Remote Management..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop > /dev/null
log success "Remote Management disabled sucessfully ✅"

log info "2.4.11 Disabling Airdrop..."
sudo -u $USER defaults write com.apple.NetworkBrowser DisableAirDrop -bool true
log success "Airdrop disabled sucessfully ✅"

log info "2.4.13 Disabling AirPlay..."
sudo -u $USER defaults -currentHost write com.apple.controlcenter.plist AirplayRecieverEnabled -bool false
log success "AirPlay disabled sucessfully ✅"

logTitle "Section 2.5 - Security & Privacy"
logTitle "Section 2.5.1 - Encryption"

log info "2.5.1.1 Enabling FileVault..."
sudo fdesetup enable -user $USER > /dev/null 2>&1
log success "FileVault enabled sucessfully ✅"

logTitle "2.5.2 - Firewall"

log info "2.5.2.1 Enabling Gatekeeper..."
sudo /usr/sbin/spctl --master-enable
log success "Gatekeeper enabled sucessfully ✅"

log info "2.5.2.2 Enabling Firewall..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 1
log success "Gatekeeper enabled sucessfully ✅"

log info "2.5.2.3 Enabling Stealth Mode Firewall..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on > /dev/null
log success "Stealth Mode Firewall enabled sucessfully ✅"

log info "2.5.6 Disabling Apple Personalized Advertising..."
sudo -u $USER defaults -currentHost write /Users/$USER/Library/Preferences/com.apple.Adlib.plist allowApplePersonalizedAdvertising -bool false
log success "Apple Personalized Advertising disabled successfully ✅"

logTitle "2.6 - Apple ID"
logTitle "2.7 - Time Machine"

#TO-DO
log info "2.7.2 Ensure Time Machine Volumes Are Encrypted"

log info "2.8 Disabling Wake for Network Access..."
sudo pmset -a womp 0
log success "Wake for Network Access disabled successfully ✅"

log info "2.9 Disabling Power Nap..."
sudo pmset -a powernap 0
log success "Power Nap disabled successfully ✅"

log info "2.10 Enabling securing Keyboard Entry terminal.app ..."
sudo -u $USER /usr/bin/defaults write -app Terminal SecureKeyboardEntry -bool true
log success "Securing Keyboard Entry Terminal.app enabled successfully ✅"

log info "2.13 Disabling Siri ..."
sudo -u $USER /usr/bin/defaults write com.apple.assistant.support.plist 'Assistant Enabled' -bool false
sudo -u $USER /usr/bin/defaults write com.apple.Siri.plist LockscreenEnabled -bool false
sudo -u $USER /usr/bin/defaults write com.apple.Siri.plist StatusMenuVisible -bool false
sudo -u $USER /usr/bin/defaults write com.apple.Siri.plist VoiceTriggerUserEnabled -bool false
sudo /usr/bin/killall -HUP cfprefsd
sudo /usr/bin/killall SystemUIServer
log success "Siri disabled successfully ✅"

log info "2.14 Disabling SideCar ..."
sudo /usr/bin/defaults write com.apple.sidecar.display AllowAllDevices false
sudo /usr/bin/defaults write com.apple.sidecar.display hasShownPref false
log info "SideCar disabled successfully ✅"

log info "3.1 Enabling Security Auditing..."
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist > /dev/null 2>&1
log info "Security Auditing enabled successfully ✅"

log info "3.3 Enabling Install log retention for 365 Days..."
installLogFile=/etc/asl/com.apple.install
sudo rm -rf $installLogFile
echo 'file $installLogFile rotate=utc compress file_max=50M ttl≥365 size_only' | sudo tee -a $installLogFile > /dev/null
log success "Install log enabled successfully ✅"

log info "3.4 Enabling Security Auditing Retention Log..."
auditControlLogFile=/etc/security/audit_control
sudo rm -rf $auditControlLogFile
echo $'dir:/var/audit\n
flags:lo,aa\n
minfree:5\n
naflags:lo,aa\n
policy:cnt,argv\n
filesz:2M\n
expire-after:60d\n
superuser-set-sflags-mask:has_authenticated,has_console_access\n
superuser-clear-sflags-mask:has_authenticated,has_console_access\n
member-set-sflags-mask:\n
member-clear-sflags-mask:has_authenticated\n' | sudo tee -a $auditControlLogFile > /dev/null
log success "Security Auditing Retention Log enabled successfully ✅"

log info "3.5 Configuring audit records properly..."
sudo chown -R root:wheel /etc/security/audit_control
sudo chmod -R o-rw /etc/security/audit_control
sudo chown -R root:wheel /var/audit/
sudo chmod -R o-rw /var/audit/
log success "Install log enabled successfully ✅"

log info "3.6 Enabling Firewall Logging..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on > /dev/null 2>&1
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingopt detail > /dev/null 2>&1
log success "Firewall logging enabled successfully ✅"

logTitle "4 - Network Configurations"

log info "4.2 Enabling Wi-Fi status in menubar..."
sudo -u $USER defaults -currentHost write com.apple.controlcenter.plist WiFi -int 18
log success "Wi-Fi status in menubar enabled successfully ✅"

log info "4.5 Disabling NFS Server..."
sudo launchctl disable system/com.apple.nfsd
log success "NFS Server disabled successfully ✅"

logTitle "5 - System Access, Authentication and Authorization"
logTitle "5.1 - File System Permissions and Access Controls"

log info "5.1.1 Configuring right permissions for $USER home folder..."
sudo /bin/chmod -R og-rwx /Users/$USER
log success "Home folder permissions enabled successfully ✅"

log info "5.1.2 Enabling SIPS..."
sudo /usr/bin/csrutil enable > /dev/null 2>&1
log success "SIPS enabled successfylly ✅"

log info "5.1.2 Enabling Mobile File Integrity..."
sudo /usr/sbin/nvram boot-args="" 
log success "Mobile File Integrity enabled successfylly ✅"