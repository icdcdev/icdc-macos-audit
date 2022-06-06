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

log info "2.4.10 Ensure Content Caching Is Disabled"
isMediaSharingDisabled=$(sudo -u $USER defaults read com.apple.amp.mediasharingd home-sharing-enabled)
if [[ $isMediaSharingDisabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Media Sharing is disabled ✅"
else
  log warn "Please disable Media Sharing ⚠️"
  TOTAL_WARN=$((TOTAL_WARN+1))
fi
