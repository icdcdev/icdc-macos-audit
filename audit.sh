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
  log warn "Not time server was found, please set time.apple.com ⚠️"
else
  timeInServer=$(sudo sntp $timeServer -t 10)
  #log info "$timeInServer"
  secondsFirstValue=$(echo "$timeInServer" | awk -F " " '{print substr($1,2)}' | bc)
  secondsSecondValue=$(echo "$timeInServer" | awk -F " " '{print $3}' | bc)
  #log info "$secondsFirstValue"
  #log info "$secondsSecondValue"
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

log info "2.3.3 Audit Lock Screen and Start Screen Saver Tools"
hasTopLeftCornerActive=$(sudo -u $USER /usr/bin/defaults read com.apple.dock wvous-tl-corner)
if [[ -z $hasTopLeftCornerActive || $hasTopLeftCornerActive -ne 13 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure a top left hot corner ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Top Left Hot corner ✅"
fi

logTitle "Section 2.4 - Sharing"

log info "2.4.1 Ensure Remote Apple Events Is Disabled"
isAppleEventsEnabled=$(sudo /usr/sbin/systemsetup -getremoteappleevents | awk -F ": " '{print $2}')
if [[ $isAppleEventsEnabled == "Off" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Remote Apple Events Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Apple Events ⚠️"
fi

log info "2.4.2 Ensure Internet Sharing Is Disabled"
isInternetSharingEnabled=$(sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.nat | grep -i Enabled | awk '{ gsub(/ /,""); print }')
if [[ -z $isInternetSharingEnabled || $isInternetSharingEnabled == "Enabled=1;" ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Internet Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Internet Sharing Is Disabled ✅"
fi

log info "2.4.3 Ensure Screen Sharing Is Disabled"
isScreenSharingDisabled=$(sudo launchctl print-disabled system | grep -c '"com.apple.screensharing" => true')
if [[ -z $isScreenSharingDisabled || $isScreenSharingDisabled -eq 0 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Screen Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Screen Sharing Is Disabled ✅"
fi

log info "2.4.4 Ensure Printer Sharing Is Disabled"
isPrinterSharingEnabled=$(sudo cupsctl | grep _share_printers | cut -d'=' -f2)
if [[ -z $isPrinterSharingEnabled || $isPrinterSharingEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Printer Sharing Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Printer Sharing ⚠️"
fi

log info "2.4.5 Ensure Remote Login Is Disabled"
isRemoteLoginActive=$(sudo systemsetup -getremotelogin | grep -c 'Remote Login: On')
if [[ -z $isRemoteLoginActive || $isRemoteLoginActive -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Remote Login Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Remote Login ⚠️"
fi

log info "2.4.6 Ensure DVD or CD Sharing Is Disabled"
isDVDOrCDSharingDisabled=$(sudo launchctl print-disabled system | grep -c '"com.apple.ODSAgent" => true')
if [[ -z $isDVDOrCDSharingDisabled || $isDVDOrCDSharingDisabled -eq 0 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable DVD or CD Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "DVD or CD Sharing Is Disabled ✅"
fi

log info "2.4.7 Ensure Bluetooth Sharing Is Disabled"
isBluetoothSharingEnabled=$(sudo -u $USER /usr/bin/defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled)
if [[ $isBluetoothSharingDisabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Bluetooth Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bluetooth Sharing Is Disabled ✅"
fi

log info "2.4.8 Ensure File Sharing Is Disabled"
isFileSharingDisabled=$(sudo launchctl print-disabled system | grep -c '"com.apple.smbd" => true')
if [[ $isFileSharingDisabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "File Sharing Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable File Sharing ⚠️"
fi

log info "2.4.9 Ensure Remote Management Is Disabled"
processArray=($(sudo ps -ef | grep -e MacOS/ARDAgent | awk '{ print $3 }'))
if [[ ${#processArray[@]} -gt 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Remote Management ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Remote Management Is Disabled ✅"
fi

log info "2.4.11 Ensure AirDrop Is Disabled"
isAirDropDisabledExists=$(sudo -u $USER defaults read com.apple.NetworkBrowser DisableAirDrop | grep "does not exist")
isAirDropDisabled=$(sudo -u $USER defaults read com.apple.NetworkBrowser DisableAirDrop | bc)
if [[ -n $isAirDropDisabledExists ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable AirDrop ⚠️"
else
  if [[ $isAirDropDisabled -eq 1 ]]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
    log success "AirDrop Is Disabled ✅"
  else
    TOTAL_WARN=$((TOTAL_WARN+1))
    log warn "Please disable AirDrop ⚠️"
  fi
fi

log info "2.4.13 Ensure AirPlay Receiver Is Disabled"
isAirPlayDisabledExists=$(sudo -u $USER defaults -currentHost read com.apple.controlcenter.plist AirplayRecieverEnabled | grep "does not exist")
isAirPlayDisabled=$(sudo -u $USER defaults -currentHost read com.apple.controlcenter.plist AirplayRecieverEnabled | bc)
if [[ -n $isAirPlayDisabledExists ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable AirPlay ⚠️"
else
  if [[ $isAirPlayDisabled -eq 0 ]]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
    log success "AirPlay Is Disabled ✅"
  else
    TOTAL_WARN=$((TOTAL_WARN+1))
    log warn "Please disable AirPlay ⚠️"
  fi
fi

logTitle "Section - 2.5 Security & Privacy"
logTitle "Section - 2.5.1 Encryption"

log info "2.5.1.1 Ensure FileVault Is Enabled"
isFileVaultEnabled=$(sudo fdesetup status | grep -c 'FileVault is On.')
if [[ $isFileVaultEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "File Vault is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable File Vault ⚠️"
fi

log info "2.5.1.2 Ensure all user storage APFS volumes are encrypted"
TOTAL_WARN=$((TOTAL_WARN+1))
log warn "Manual resolution"

log info "2.5.1.3 Ensure all user storage CoreStorage volumes are encrypted"
TOTAL_WARN=$((TOTAL_WARN+1))
log warn "Manual resolution"

logTitle "2.5.2 - Firewall"

log info "2.5.2.1 Ensure Gatekeeper is Enabled"
isGateKeeperEnabled=$(sudo /usr/sbin/spctl --status | grep -c 'assessments enabled')
if [[ $isGateKeeperEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Gatekeeper is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Gatekeeper ⚠️"
fi

log info "2.5.2.2 Ensure Firewall Is Enabled"
isFirewallEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.alf globalstate)
if [[ $isFirewallEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Firewall is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Firewall ⚠️"
fi

log info "2.5.2.3 Ensure Firewall Stealth Mode Is Enabled"
isFirewallStealhModeEnabled=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode | grep -c 'Stealth mode enabled')
if [[ $isFirewallStealhModeEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Firewall Stealth Mode is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Stealth Mode in Firewall ⚠️"
fi

log info "2.5.6 Ensure Limit Ad Tracking Is Enabled"
isAllowApplePersonalizedAdvertising=$(sudo -u $USER defaults -currentHost read /Users/$USER/Library/Preferences/com.apple.AdLib.plist allowApplePersonalizedAdvertising)
if [[ $isAllowApplePersonalizedAdvertising -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Apple Personalized Advertising limited successfully ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Apple Personalized Advertising ⚠️"
fi

logTitle "2.6 - Apple ID"
logTitle "2.7 - Time Machine"

log info "2.7.2 Ensure Time Machine Volumes Are Encrypted"
existsTimeMachineBackups=($(sudo /usr/bin/tmutil destinationinfo | grep -i NAME))
if [[ ${#existsTimeMachineBackups[@]} -gt 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please encrypt your time machine backups ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "There are not time machine backups ✅"
fi

log info "2.8 Ensure Wake for Network Access Is Disabled"
isWakeNetworkAccessDisabled=$(sudo pmset -g | grep 'womp' | awk '{print $2}')
if [[ $isWakeNetworkAccessDisabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Wake for Network Access ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Wake for Network Access is disabled ✅"
fi

log info "2.9 Ensure Power Nap Is Disabled"
isPowerNapDisabled=$(sudo pmset -g live | grep -c 'powernap             1')
if [[ $isPowerNapDisabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Wake for Network Access ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Wake for Network Access is disabled ✅"
fi

log info "2.10 Ensure Secure Keyboard Entry terminal.app is Enabled"
isSecureKeyboardEntry=$(sudo -u $USER /usr/bin/defaults read -app Terminal SecureKeyboardEntry)
if [[ $isSecureKeyboardEntry -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Secure Keyboard Entry for Terminal.app is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Secure Entry for Terminal.app ⚠️"
fi

log info "2.11 Ensure EFI Version Is Valid and Checked Regularly"
integrityCheck=$(sudo /usr/libexec/firmwarecheckers/eficheck/eficheck --integrity-check)
if [[ $integrityCheck != *"ReadBinaryFromKernel"* ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Secure Keyboard Entry for Terminal.app is enabled ✅"
elif [[ $integrityCheck == *"Primary allowlist version match found. No changes detected in primary hashes"* ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your Mac has up-to-date firmware ✅"
else
  log info "Veryfing if Mac does have an Apple T2 Security Chip"
  controllerChipName=$(sudo system_profiler SPiBridgeDataType | grep "T2")
  if [[ -n $controllerChipName ]]; then
    t2IntegrityCheck=$(sudo launchctl list | grep com.apple.driver.eficheck)
    if [[ -n $controllerChipName ]]; then
      TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
      log success "Your Mac has up-to-date firmware ✅"
    else
      TOTAL_WARN=$((TOTAL_WARN+1))
      log error "EFI does not pass the integrity check you may send a report to Apple ❌"
      log error "Is recommended to back-up your files and install a clean known good Operating System and Firmware."
    fi
  fi
fi

log info "2.12 Audit Automatic Actions for Optical Media"
log success "Your Mac does not have Optical Media"

log info "2.13 Audit Siri Settings"
isSiriEnabled=$(sudo -u $USER /usr/bin/defaults read com.apple.assistant.support.plist 'Assistant Enabled')
if [[ $isSiriEnabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Siri ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Siri is disabled ✅"
fi

log info "2.14 Audit Sidecar Settings"
isSidecarEnabled=$(sudo /usr/bin/defaults read com.apple.sidecar.display AllowAllDevices | grep -c true)
if [[ $isSidecarEnabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Sidecar ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Sidecar is disabled ✅"
fi

log info "2.14 Audit Touch ID and Wallet & Apple Pay Settings"
isTouchIDEnabled=$(bioutil -rs | grep functionality | awk '{print $4}')
isTouchIDUnlocking=$(bioutil -rs | grep unlock | awk '{print $5}')
if [[ $isTouchIDEnabled -eq 1 && $isTouchIDUnlocking -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Touch ID is enabled and is properly configured ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Manual Configuration"
  log warn "Please enable and configure your Touch ID ⚠️"
fi

logTitle "Audit Overview"
log warn "Total: ${TOTAL_WARN} ⚠️"
log success "Total: ${TOTAL_SUCCESS} ✅"







# log info "Installing software updates... 🤖"
# sudo /usr/sbin/softwareupdate -i -a -R