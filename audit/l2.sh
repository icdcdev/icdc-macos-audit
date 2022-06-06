#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

logTitle "LEVEL 2"
logTitle "Section 1 - Install Updates, Patches and Additional Security Software"
log info "1.7 Audit Computer Name"
log success "Manual resolution ✅"
logTitle "Section 2 - System Preferences"
logTitle "Section 2.1 - Bluetooth"
logTitle "Section 2.2 - Date & Time"
logTitle "Section 2.3 - Desktop & Screen Saver"

log info "2.3.2 Ensure Screen Saver Corners Are Secure"
hotCorners=( "wvous-tl-corner" "wvous-tr-corner" "wvous-bl-corner" "wvous-br-corner")
for corner in "${hotCorners[@]}"; do
  cornerValue=$(sudo -u $USER /usr/bin/defaults read com.apple.dock "$corner")
  if [[ $cornerValue -eq 6 ]]; then
    log warn "Please disable hot corner that contains disable screensaver ⚠️"
    TOTAL_WARN=$((TOTAL_WARN+1))
    break
  fi
done
TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
log success "Hot corners are secure ✅"

logTitle "Section 2.4 - Sharing"
log info "2.4.10 Ensure Content Caching Is Disabled"
isContentCachingEnabled=$(/usr/bin/defaults read /Library/Preferences/com.apple.AssetCache.plist Activated)
if [[ $isContentCachingEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Content caching is disabled ✅"
else
  log warn "Please disable content caching ⚠️"
  TOTAL_WARN=$((TOTAL_WARN+1))
fi

log info "2.4.12 Ensure Media Sharing Is Disabled"
isMediaSharingDisabled=$(sudo -u $USER defaults read com.apple.amp.mediasharingd home-sharing-enabled)
if [[ $isMediaSharingDisabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Media Sharing is disabled ✅"
else
  log warn "Please disable Media Sharing ⚠️"
  TOTAL_WARN=$((TOTAL_WARN+1))
fi

logTitle "Section 2.5 - Security & Privacy"
log info "2.5.3 Ensure Location Services Is Enabled"
isLocationServiceEnabled=$(sudo launchctl list | grep -c com.apple.locationd)
if [[ $isLocationServiceEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Location Services is enabled ✅"
else
  log warn "Please enable Location Services ⚠️"
  TOTAL_WARN=$((TOTAL_WARN+1))
fi

log info "2.5.4 Audit Location Services Access"
log info "Manual validation"

log info "2.5.5 Ensure Sending Diagnostic and Usage Data to Apple Is Disabled"
isMessagesHistoryAutoSubmit=$(sudo /usr/bin/defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit)
messagesHistoryFilePerm=$(stat -f "%OLp %Sg" /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist)
if [[ $isMessagesHistoryAutoSubmit -eq false && $messagesHistoryFilePerm=="644 admin" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Diagnostic and Usage Data to Apple Is successfully configured ✅"
else
  log warn "Please configure in a right way Diagnostic and Usage Data to Apple's file ⚠️"
  TOTAL_WARN=$((TOTAL_WARN+1))
fi

log info "2.5.7 Audit Camera Privacy and Confidentiality"
log info "Manual validation"

logTitle "Section 2.5.1 - Encryption"
logTitle "Section 2.5.2 - Encryption"
logTitle "Section 2.6.1 - iCloud"

log info "2.6.1.1 Audit iCloud Configuration"
iCloudConfig=$(sudo -u $USER defaults read /Users/eduardoalvarez/Library/Preferences/MobileMeAccounts)
log info "Manual validation"
log info "$iCloudConfig"

log info "2.6.1.2 Audit iCloud Keychain"
log info "Manual validation"

log info "2.6.1.3 Audit iCloud Drive"
isICloudDocumentsEnabled=$(sudo -u $USER /usr/bin/defaults read /Users/$USER/Library/Preferences/MobileMeAccounts | /usr/bin/grep -B 1 MOBILE_DOCUMENTS | awk -F "Enabled =" '{print $2}')
if [[ $isICloudDocumentsEnabled=="1;" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "iCloud Drive is configured successfully ✅"
else
  log warn "Please configure iCloud drive to sync documents ⚠️"
  TOTAL_WARN=$((TOTAL_WARN+1))
fi