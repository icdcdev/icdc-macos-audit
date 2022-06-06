#!/bin/bash
# Copyright 2022 Volkswagen de México
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
  cornerValue=$(sudo -u $USER /usr/bin/defaults read com.apple.dock "$corner")
  if [[ $cornerValue -eq 6 ]]; then
    sudo -u $USER /usr/bin/defaults write com.apple.dock "$corner" -int 0
  fi
done
log success "Non secure hot corners disabled successfully"

logTitle "Section 2.4 - Sharing"
log info "2.4.10 Disabling content caching..."
sudo /usr/bin/AssetCacheManagerUtil deactivate
log success "Content caching disabled successfully"

log info "2.4.12 Disabling Media Sharing..."
sudo -u $USER defaults write com.apple.amp.mediasharingd home-sharing-enabled -int 0
log success "Media Sharing disabled successfully"

logTitle "Section 2.5 - Security & Privacy"
log info "2.5.3 Enabling Location Services..."
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locationd.plist
log success "Location services enabled successfully"