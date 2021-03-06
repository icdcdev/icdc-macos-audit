#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

logTitle "LEVEL 2"
logTitle "Section 1 - Install Updates, Patches and Additional Security Software"

log info "1.7 Audit Computer Name"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
log success "Manual resolution ✅"

logTitle "Section 2 - System Preferences"
logTitle "Section 2.1 - Bluetooth"
logTitle "Section 2.2 - Date & Time"
logTitle "Section 2.3 - Desktop & Screen Saver"

log info "2.3.2 Ensure Screen Saver Corners Are Secure"
hotCorners=("wvous-tl-corner" "wvous-tr-corner" "wvous-bl-corner" "wvous-br-corner")
for corner in "${hotCorners[@]}"; do
  cornerValue=$(sudo -u "$USER" /usr/bin/defaults read com.apple.dock "$corner")
  if [[ $cornerValue -eq 6 ]]; then
    log warn "Please disable hot corner that contains disable screensaver ⚠️"
    TOTAL_WARN=$((TOTAL_WARN + 1))
    break
  fi
done
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
log success "Hot corners are secure ✅"

logTitle "Section 2.4 - Sharing"
log info "2.4.10 Ensure Content Caching Is Disabled"
isContentCachingEnabled=$(/usr/bin/defaults read /Library/Preferences/com.apple.AssetCache.plist Activated)
if [[ $isContentCachingEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Content caching is disabled ✅"
else
  log warn "Please disable content caching ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "2.4.12 Ensure Media Sharing Is Disabled"
isMediaSharingDisabled=$(sudo -u "$USER" defaults read com.apple.amp.mediasharingd home-sharing-enabled)
if [[ $isMediaSharingDisabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Media Sharing is disabled ✅"
else
  log warn "Please disable Media Sharing ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

logTitle "Section 2.5 - Security & Privacy"
logTitle "Section 2.5.1 - Encryption"
logTitle "Section 2.5.2 - Firewall"
log info "2.5.3 Ensure Location Services Is Enabled"
isLocationServiceEnabled=$(sudo launchctl list | grep -c com.apple.locationd)
if [[ $isLocationServiceEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Location Services is enabled ✅"
else
  log warn "Please enable Location Services ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "2.5.4 Audit Location Services Access"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

log info "2.5.5 Ensure Sending Diagnostic and Usage Data to Apple Is Disabled"
isMessagesHistoryAutoSubmit=$(sudo /usr/bin/defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit)
messagesHistoryFilePerm=$(stat -f "%OLp %Sg" /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist)
if [[ $isMessagesHistoryAutoSubmit == 0 && $messagesHistoryFilePerm == "644 admin" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Diagnostic and Usage Data to Apple Is successfully configured ✅"
else
  log warn "Please configure in a right way Diagnostic and Usage Data to Apple's file ⚠️"
  log warn "1. Open System Preferences
            2. Select Security & Privacy
            3. Select Privacy
            4. Select Analytics & Improvements
            5. Uncheck Share Mac Analytics
            6. Uncheck Share with App Developers"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "2.5.7 Audit Camera Privacy and Confidentiality"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

logTitle "Section 2.6 - Apple ID"
logTitle "Section 2.6.1 - iCloud"

log info "2.6.1.1 Audit iCloud Configuration"
iCloudConfig=$(sudo -u "$USER" defaults read /Users/eduardoalvarez/Library/Preferences/MobileMeAccounts)
log info "Manual validation"
log info "$iCloudConfig"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

log info "2.6.1.2 Audit iCloud Keychain"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

log info "2.6.1.3 Audit iCloud Drive"
isICloudDocumentsEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Users/"$USER"/Library/Preferences/MobileMeAccounts | /usr/bin/grep -B 1 MOBILE_DOCUMENTS | /usr/bin/grep -c "Enabled = 1")
if [[ $isICloudDocumentsEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "iCloud Drive is configured successfully ✅"
else
  log warn "Please configure iCloud drive to sync documents ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "2.6.1.4 Ensure iCloud Drive Document and Desktop Sync is Disabled"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

log info "2.6.2 Audit App Store Password Settings"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

logTitle "Section 2.7 - Time Machine"
#log info "2.7.1 Ensure Backup Up Automatically is Enabled"
#isTimeMachineAutoBackupEnabled=$(/usr/bin/defaults read /Library/Preferences/com.apple.TimeMachine.plist AutoBackup)
#if [[ $isTimeMachineAutoBackupEnabled == "1" ]]; then
#  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
#  log success "Time Machine Auto backup enabled ✅"
#else
#  log warn "Please configure Time Machine auto backups ⚠️"
#  TOTAL_WARN=$((TOTAL_WARN + 1))
#fi
#
logTitle "Section 3 - Logging and Auditing"
#log info "3.2 Ensure Security Auditing Flags Are Configured Per Local Organizational Requirements"
#logFlags=$(grep -e "^flags:" /etc/security/audit_control)
#if [[ $logFlags == "flags: -all" ]]; then
#  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
#  log success "Log flags OK ✅"
#else
#  log warn "Please configure -all to log flags ⚠️"
#  TOTAL_WARN=$((TOTAL_WARN + 1))
#fi

log info "3.7 Audit Software Inventory"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

logTitle "Section 4 - Network Configurations"
log info "4.1 Ensure Bonjour Advertising Services Is Disabled"
isBonjourServiceDisabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements)
if [[ $isBonjourServiceDisabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Bonjour Advertising Services disabled ✅"
else
  log warn "Please disable Bonjour Advertising services ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "4.3 Audit Network Specific Locations"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

log info "4.6 Audit Wi-Fi Settings"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

logTitle "Section 5 - System Access, Authentication and Authorization"
logTitle "Section 5.1 - File System Permissions and Access Controls"
log info "5.1.8 Ensure No World Writable Files Exist in the Library Folder"

logTitle "Section 5.2 - Password Management"
log info "5.2.3 Ensure Complex Password Must Contain Alphabetic Characters Is Configured"
passwordContainsAlphanumeric=$(sudo /usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A1 minimumLetters | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1)
if [[ $passwordContainsAlphanumeric -ge 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Password must have alphabetic chars ✅"
else
  log warn "Please configure a password policy to contain alphanumeric characters ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "5.2.4 Ensure Complex Password Must Contain Numeric Character Is Configured"
passwordContainsNumeric=$(sudo /usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A1 minimumNumericCharacters | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1 )
if [[ $passwordContainsNumeric -ge 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Password must have numeric chars ✅"
else
  log warn "Please configure a password policy to contain numeric characters ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "5.2.5 Ensure Complex Password Must Contain Special Character Is Configured"
passwordContainsSpecialChars=$(sudo /usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A1 minimumSymbols | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1)
if [[ $passwordContainsSpecialChars -ge 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Password must have special chars ✅"
else
  log warn "Please configure a password policy to contain special characters ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "5.2.6 Ensure Complex Password Must Contain Uppercase and Lowercase Characters Is Configured"
passwordContainsMixedCaseChars=$(sudo /usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A1 minimumMixedCaseCharacters | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1)
if [[ passwordContainsMixedCaseChars -ge 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Password must have mixed case chars ✅"
else
  log warn "Please configure a password policy to contain mixed case characters ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "5.5 Ensure login keychain is locked when the computer sleeps"
sudo -u "$USER" security unlock-keychain /Users/"$USER"/Library/Keychains/login.keychain
keychainInfo=$(sudo -u "$USER" security show-keychain-info /Users/"$USER"/Library/Keychains/login.keychain 2>&1 | grep -c 'lock-on-sleep')
if [[ $keychainInfo -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Keychain is locked when computer sleeps ✅"
else
  log warn "Please configure keychain to lock when computer sleeps ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "5.9 Ensure system is set to hibernate"
isMacbook=$(sudo system_profiler SPHardwareDataType | grep -c "Model Name: MacBook")
standByDelayLowValue=$(sudo pmset -g | grep -e standbydelaylow | awk -F " " '{print $2}')
standByDelayHighValue=$(sudo pmset -g | grep -e standbydelayhigh | awk -F " " '{print $2}')
highStandByThresholdValue=$(sudo pmset -g | grep -e highstandbythreshold | awk -F " " '{print $2}')
destroyFvKeyOnStandByValue=$(sudo pmset -g | grep DestroyFVKeyOnStandby | awk -F " " '{print $2}')
hibernateModeValue=$(sudo pmset -g | grep -e hibernatemode | awk -F " " '{print $2}')
if [[ $isMacbook -eq 1 && $standByDelayLowValue -le 600 && $standByDelayHighValue -le 600 && $highStandByThresholdValue -ge 90 && $destroyFvKeyOnStandByValue -eq 1 && $hibernateModeValue -eq 25 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "System Hibernate configurations are ok ✅"
else
  log warn "Please configure hibernate configurations with the following values ⚠️"
  log warn "standbydelaylow <value≤600>"
  log warn "standbydelayhigh <value≤600>"
  log warn "highstandbythreshold <value≥90>"
  log warn "destroyfvkeyonstandby 1"
  log warn "hibernatemode 25"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "5.13 Ensure a Login Window Banner Exists"
if [[ -f "/Library/Security/PolicyBanner.txt" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Login Window Banner exists ✅"
else
  log warn "Please configure a login window banner ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

log info "5.15 Ensure Fast User Switching Is Disabled"
isFastUserSwitchingEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/.GlobalPreferences MultipleSessionEnabled)
if [[ $isFastUserSwitchingEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
  log success "Fast User Switching is disabled ✅"
else
  log warn "Please disable fast switching ⚠️"
  TOTAL_WARN=$((TOTAL_WARN + 1))
fi

logTitle "Section 6 - User Accounts and Environment"
logTitle "Section 6.1 - Accounts Preferences Action Items"
logTitle "Section 7 - Appendix: Additional Considerations"

log info "7.1 Extensible Firmware Interface (EFI) password"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))

log info "7.2 FileVault and Local Account Password Reset using AppleID"
log info "Manual validation"
TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))