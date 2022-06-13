#!/bin/bash
# Copyright 2022 Volkswagen de Mexico
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

logTitle "#ICDC MacOS Auditor (Applier L2) v1.0"
logTitle "Section 1 - Install Updates, Patches and Additional Security Software"
log info "1.7 Audit Computer Name"
log success "Manual resolution ✅"
logTitle "Section 2 - System Preferences"
logTitle "Section 2.1 - Bluetooth"
logTitle "Section 2.2 - Date & Time"
logTitle "Section 2.3 - Desktop & Screen Saver"

log info "2.3.2 Disabling non secure hot corners..."
hotCorners=( "wvous-tl-corner" "wvous-tr-corner" "wvous-bl-corner" "wvous-br-corner")
for corner in "${hotCorners[@]}"; do
  cornerValue=$(sudo -u "$USER" /usr/bin/defaults read com.apple.dock "$corner")
  if [[ $cornerValue -eq 6 ]]; then
    sudo -u "$USER" /usr/bin/defaults write com.apple.dock "$corner" -int 0
  fi
done
log success "Non secure hot corners disabled successfully"

logTitle "Section 2.4 - Sharing"
log info "2.4.10 Disabling content caching..."
sudo /usr/bin/AssetCacheManagerUtil deactivate
log success "Content caching disabled successfully"

log info "2.4.12 Disabling Media Sharing..."
sudo -u "$USER" defaults write com.apple.amp.mediasharingd home-sharing-enabled -int 0
log success "Media Sharing disabled successfully"

logTitle "Section 2.5 - Security & Privacy"
log info "2.5.3 Enabling Location Services..."
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locationd.plist
log success "Location services enabled successfully"

log info "2.5.5 Disabling auto submit apple diagnosis logs..."
sudo /usr/bin/defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false
sudo chmod 644 /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist
sudo chgrp admin /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist
log success "Auto submit apple diagnosis logs successfully disabled"

logTitle "Section 2.5.1 - Encryption"
logTitle "Section 2.5.2 - Firewall"
logTitle "Section 2.6 - Apple ID"
logTitle "Section 2.6.1 - iCloud"
logTitle "Section 2.7 - Time Machine"

log info "2.7.1 Enabling automatic Time Machine backups..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine.plist AutoBackup -bool true
log success "Time Machine automatic backups enabled successfully"

logTitle "Section 3 - Logging and Auditing"
log info "3.2 Enabling -all to log flags..."
sudo sed -i '' "s/^flags:.*/flags: -all/g" /etc/security/audit_control
log success "Log flags enabled successfully"

logTitle "Section 4 - Network Configurations"
log info "4.1 Disabling Bonjour Advertising Services..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
log success "Bonjour Advertising Services disabled successfully"

logTitle "Section 5 - System Access, Authentication and Authorization"
logTitle "Section 5.1 - File System Permissions and Access Controls"
log info "5.1.8 Ensure No World Writable Files Exist in the Library Folder"

logTitle "Section 5.2 - Password Management"
log info "5.2.3 Adding alphanumeric chars in password policy..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "requiresAlpha=5"
log success "Alphanumeric chars added to password policy"

log info "5.2.4 Adding numeric chars in password policy..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "requiresNumeric=2"
log success "Numeric chars added to password policy"

log info "5.2.5 Adding special chars in password policy..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "requiresSymbol=1"
log success "Special chars added to password policy"

log info "5.2.6 Adding mixed case chars in password policy..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "requiresMixedCase=1"
log success "Mixed case chars added to password policy"

log info "5.5 Configuring keychain to lock when computer sleeps..."
sudo -u "$USER" security set-keychain-settings -l /Users/"$USER"/Library/Keychains/login.keychain
log success "Keychain locked when computer sleeps"

log info "5.9 Setting up right values for hibernate configuration..."
sudo pmset -a standbydelaylow 500
sudo pmset -a standbydelayhigh 500
sudo pmset -a highstandbythreshold 100
sudo pmset -a destroyfvkeyonstandby 1
sudo pmset -a hibernatemode 25
log success "Hibernate configuration updated successfully"

log info "5.13 Configuring a login window banner..."
sudo echo "ICDC Login Banner" | sudo tee -a /Library/Security/PolicyBanner.txt
log success "Login window banner updated successfully"

log info "5.15 Disabling fast user switching..."
sudo /usr/bin/defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false
log success "Fast user switching disabled successfully"

logTitle "Section 6 - User Accounts and Environment"
logTitle "Section 6.1 - Accounts Preferences Action Items"
logTitle "Section 7 - Appendix: Additional Considerations"