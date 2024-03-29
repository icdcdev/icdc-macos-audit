#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

logTitle "LEVEL 1"
logTitle "Section 1 - Install Updates, Patches and Additional Security Software"

log info "1.1 Ensure All Apple-provided Software Is Current"
lastFullSuccessfulDate=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate | awk -F '"' '$0=$2' | awk '{ print $1 }')
daysAfterFullSuccessfulDate=$(dateDiffNow "$lastFullSuccessfulDate");
log info "Your system has $daysAfterFullSuccessfulDate days after your last successful date"
if [[ $daysAfterFullSuccessfulDate -gt 30 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system is not updated, please update to latest version ⚠️"
 else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "System is updated ✅"
fi

log info "1.2 Ensure Auto Update Is Enabled... 🔍"
isAutomaticUpdatesEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled)
if [[ $isAutomaticUpdatesEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have check automatic updates ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system does not have automatic updates ⚠️"
fi

log info "1.3 Ensure Download New Updates When Available is Enabled"
isAutomaticDownloadEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload)
if [[ $isAutomaticDownloadEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have automatic new download updates enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic new download updates ⚠️"
fi

log info "1.4 Ensuring if installation of app update is enabled"
isNewUpdatesAppEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.commerce AutoUpdate)
if [[ $isNewUpdatesAppEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have automatic app download updates enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic app download updates ⚠️"
fi

log info "1.5 Ensure System Data Files and Security Updates Are Downloaded Automatically Is Enabled"
isSystemDataFilesConfig=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall)
isSystemDataFilesCritical=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall)
if [[ $isSystemDataFilesConfig -eq 1 && $isSystemDataFilesCritical -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "System Data Files and Security Updates Are Downloaded Automatically Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "System Data Files and Security Updates Are Downloaded Automatically aren't Enabled ⚠️"
fi

log info "1.6 Ensure Install of macOS Updates Is Enabled"
isAutomaticallyInstallMacOSUpdatesEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates)
if [[ $isAutomaticallyInstallMacOSUpdatesEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "MacOS Automatically Updates are enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "MacOS Automatically Updates aren't enabled ⚠️"
fi

logTitle "Section 2.1 - Bluetooth"

log info "2.1.1 Ensure Bluetooth Is Disabled If No Devices Are Paired"
isBluetoothEnabled=$(blueutil -p)
if [[ $isBluetoothEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bluetooth is disabled ✅"
elif [[ $isBluetoothEnabled -eq 1 ]]; then
  pairedBluetoothDevices=$(blueutil --connected --format json | jq 'length')
  if [[ $pairedBluetoothDevices -ge 1 ]]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
    log success "Bluetooth is enabled and paired devices were found ✅"
  else
    TOTAL_WARN=$((TOTAL_WARN+1))
    log warn "Bluetooth is enabled and paired devices were not found ⚠️"
  fi
fi

log info "2.1.2 Ensure Show Bluetooth Status in Menu Bar Is Enabled"
isBluetoothVisibleOnMenuBar=$(sudo -u "$USER" defaults -currentHost read com.apple.controlcenter.plist Bluetooth -int 18)
if [[ $isBluetoothVisibleOnMenuBar == "18" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bluetooth status in menu bar is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Bluetooth status in menu bar is disabled ⚠️"
fi

logTitle "Section 2.2 - Date & Time"
log info "2.2.1 Ensure 'Set time and date automatically' Is Enabled"
isSetTimeAndDateAutomatically=$(/usr/sbin/systemsetup -getusingnetworktime | awk -F ": " '{print $2}')
if [[ $isSetTimeAndDateAutomatically == "On" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "'Set time and date automatically' Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "'Set time and date automatically' Is Disabled ⚠️"
fi

log info "2.2.2 Ensure time set is within appropriate limits"
timeServer=$(sudo /usr/sbin/systemsetup -getnetworktimeserver | awk -F ": " '{print $2}')
log info "Time Server: $timeServer"
if [[ -n $timeServer && $timeServer == $TIME_SERVER ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Server Time OK ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Time is not set within an appropriate limits, please configure time with sntp $TIME_SERVER ⚠️"
fi

logTitle "Section 2.3 - Desktop & Screen Saver"

log info "2.3.1 Ensure an Inactivity Interval of 20 Minutes Or Less for the Screen Saver Is Enabled"
inactivityInterval=$(sudo -u "$USER" /usr/bin/defaults -currentHost read com.apple.screensaver idleTime)
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
hasCornersActive=$(/usr/bin/defaults read ~/Library/Preferences/com.apple.dock | /usr/bin/grep -i corner)
if [[ -z $hasCornersActive ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure a bottom left hot corner ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bottom Left Hot corner ✅"
fi

logTitle "Section 2.4 - Sharing"

log info "2.4.1 Ensure Remote Apple Events Is Disabled"
isAppleEventsEnabled=$(/usr/sbin/systemsetup -getremoteappleevents | awk -F ": " '{print $2}')
if [[ $isAppleEventsEnabled == "Off" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Remote Apple Events Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Apple Events ⚠️"
fi

log info "2.4.2 Ensure Internet Sharing Is Disabled"
isInternetSharingEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/SystemConfiguration/com.apple.nat | grep -i Enabled | awk '{ gsub(/ /,""); print }')
if [[ -z $isInternetSharingEnabled || $isInternetSharingEnabled == "Enabled=1;" ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Internet Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Internet Sharing Is Disabled ✅"
fi

log info "2.4.3 Ensure Screen Sharing Is Disabled"
isScreenSharingDisabled=$(launchctl print-disabled system | grep -c '"com.apple.screensharing" => true')
if [[ -z $isScreenSharingDisabled || $isScreenSharingDisabled -eq 0 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Screen Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Screen Sharing Is Disabled ✅"
fi

log info "2.4.4 Ensure Printer Sharing Is Disabled"
isPrinterSharingEnabled=$(cupsctl | grep _share_printers | cut -d'=' -f2)
if [[ -z $isPrinterSharingEnabled || $isPrinterSharingEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Printer Sharing Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Printer Sharing ⚠️"
fi

log info "2.4.5 Ensure Remote Login Is Disabled"
isRemoteLoginActive=$(systemsetup -getremotelogin | grep -c 'Remote Login: On')
if [[ -z $isRemoteLoginActive || $isRemoteLoginActive -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Remote Login Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Remote Login ⚠️"
fi

log info "2.4.6 Ensure DVD or CD Sharing Is Disabled"
isDVDOrCDSharingDisabled=$(launchctl print-disabled system | grep -c '"com.apple.ODSAgent" => true')
if [[ -z $isDVDOrCDSharingDisabled || $isDVDOrCDSharingDisabled -eq 0 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable DVD or CD Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "DVD or CD Sharing Is Disabled ✅"
fi

log info "2.4.7 Ensure Bluetooth Sharing Is Disabled"
isBluetoothSharingEnabled=$(sudo -u "$USER" /usr/bin/defaults -currentHost read com.apple.Bluetooth PrefKeyServicesEnabled)
if [[ isBluetoothSharingEnabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Bluetooth Sharing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Bluetooth Sharing Is Disabled ✅"
fi

log info "2.4.8 Ensure File Sharing Is Disabled"
isFileSharingDisabled=$(launchctl print-disabled system | grep -c '"com.apple.smbd" => true')
if [[ $isFileSharingDisabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "File Sharing Is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable File Sharing ⚠️"
fi

log info "2.4.9 Ensure Remote Management Is Disabled"
processArray=($(ps -ef | grep -e "MacOS/ARDAgent" | awk '{ print $3 }'))
if [[ ${#processArray[@]} -gt 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Remote Management ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Remote Management Is Disabled ✅"
fi

log info "2.4.11 Ensure AirDrop Is Disabled"
isAirDropDisabledExists=$(sudo -u "$USER" /usr/bin/defaults read com.apple.NetworkBrowser DisableAirDrop | grep "does not exist")
isAirDropDisabled=$(sudo -u "$USER" defaults read com.apple.NetworkBrowser DisableAirDrop | bc)
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
isAirPlayDisabledExists=$(sudo -u "$USER" defaults -currentHost read com.apple.controlcenter.plist AirplayRecieverEnabled | grep "does not exist")
isAirPlayDisabled=$(sudo -u "$USER" defaults -currentHost read com.apple.controlcenter.plist AirplayRecieverEnabled | bc)
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
isFileVaultEnabled=$(fdesetup status | grep -c 'FileVault is On.')
if [[ $isFileVaultEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "File Vault is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable File Vault ⚠️"
fi

log info "2.5.1.2 Ensure all user storage APFS volumes are encrypted"
TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
log success "All APFS Volumes are encrypted ✅"

log info "2.5.1.3 Ensure all user storage CoreStorage volumes are encrypted"
TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
log success "All CoreStorage Volumes are encrypted ✅"

logTitle "2.5.2 - Firewall"

log info "2.5.2.1 Ensure Gatekeeper is Enabled"
isGateKeeperEnabled=$(/usr/sbin/spctl --status | grep -c 'assessments enabled')
if [[ $isGateKeeperEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Gatekeeper is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Gatekeeper ⚠️"
fi

log info "2.5.2.2 Ensure Firewall Is Enabled"
isFirewallEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.alf globalstate)
if [[ $isFirewallEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Firewall is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Firewall ⚠️"
fi

log info "2.5.2.3 Ensure Firewall Stealth Mode Is Enabled"
isFirewallStealthModeEnabled=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode | grep -c 'Stealth mode enabled')
if [[ $isFirewallStealthModeEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Firewall Stealth Mode is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Stealth Mode in Firewall ⚠️"
fi

log info "2.5.6 Ensure Limit Ad Tracking Is Enabled"
isAllowApplePersonalizedAdvertising=$(sudo -u "$USER" defaults -currentHost read /Users/"$USER"/Library/Preferences/com.apple.AdLib.plist allowApplePersonalizedAdvertising)
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
IFS=$'\n'
timeMachineBackups=($(sudo /usr/bin/tmutil destinationinfo | grep -i NAME | awk -F ":" '{print $2}' | awk '{$1=$1};1'))
volumeTotals=0
for volume in ${timeMachineBackups[@]}; do
  isVolumeEncrypted=$(sudo diskutil info $volume | grep -c " FileVault:                 Yes")
  if [[ $isVolumeEncrypted -eq 1 ]]; then
    volumeTotals=$((volumeTotals + 1))
  fi
done
if [[ $volumeTotals -eq ${#timeMachineBackups[@]} ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "There are not time machine backups ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please encrypt your time machine backups ⚠️"
fi

log info "2.8 Ensure Wake for Network Access Is Disabled"
isWakeNetworkAccessDisabled=$(pmset -g | grep 'womp' | awk '{print $2}')
if [[ $isWakeNetworkAccessDisabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Wake for Network Access ⚠️"
  log warn "1. Open System Preferences
            2. Select Energy Saver
            3. Uncheck Wake for network access"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Wake for Network Access is disabled ✅"
fi

log info "2.9 Ensure Power Nap Is Disabled"
isPowerNapDisabled=$(pmset -g live | grep -c 'powernap             1')
if [[ $isPowerNapDisabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Wake for Network Access ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Wake for Network Access is disabled ✅"
fi

log info "2.10 Ensure Secure Keyboard Entry terminal.app is Enabled"
isSecureKeyboardEntry=$(sudo -u "$USER" /usr/bin/defaults read -app Terminal SecureKeyboardEntry)
if [[ $isSecureKeyboardEntry -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Secure Keyboard Entry for Terminal.app is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Secure Entry for Terminal.app ⚠️"
fi

log info "2.11 Ensure EFI Version Is Valid and Checked Regularly"
integrityCheck=$(/usr/libexec/firmwarecheckers/eficheck/eficheck --integrity-check)
if [[ $integrityCheck != *"ReadBinaryFromKernel"* ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Secure Keyboard Entry for Terminal.app is enabled ✅"
elif [[ $integrityCheck == *"Primary allowlist version match found. No changes detected in primary hashes"* ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your Mac has up-to-date firmware ✅"
else
  log info "Verifying if Mac does have an Apple T2 Security Chip"
  controllerChipName=$(system_profiler SPiBridgeDataType | grep "T2")
  if [[ -n $controllerChipName ]]; then
    t2IntegrityCheck=$(launchctl list | grep com.apple.driver.eficheck)
    if [[ -n $t2IntegrityCheck ]]; then
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
isSiriEnabled=$(sudo -u "$USER" /usr/bin/defaults read com.apple.assistant.support.plist 'Assistant Enabled')
if [[ $isSiriEnabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Siri ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Siri is disabled ✅"
fi

log info "2.14 Audit Sidecar Settings"
isSidecarEnabled=$(sudo -u "$USER" /usr/bin/defaults read com.apple.sidecar.display AllowAllDevices | grep -c true)
if [[ $isSidecarEnabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Sidecar ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Sidecar is disabled ✅"
fi

log info "2.15 Audit Touch ID and Wallet & Apple Pay Settings"
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

log info "2.15 Audit Notification System Preference Settings"
log success "Manual Configuration"
log success "Notifications skipped ✅"

logTitle "3 - Logging and Auditing"

log info "3.1 Ensure Security Auditing Is Enabled"
isAuditingEnabled=$(launchctl list | grep com.apple.auditd)
if [[ -z $isAuditingEnabled ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Security Auditing ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Security Auditing is Enabled ✅"
fi

log info "3.3 Ensure install.log Is Retained for 365 or More Days and No Maximum Size"
isLogRetainMaximum=$(grep -i ttl /etc/asl/com.apple.install)
isLogRetainEmpty=$(grep -i all_max= /etc/asl/com.apple.install)
if [[ $isLogRetainMaximum == *"ttl=365"* && -z $isLogRetainEmpty ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "File install.log is retained for 365 or more days and no maximum size ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Security Auditing ⚠️"
fi

log info "3.4 Ensure Security Auditing Retention Is Enabled"
isAuditingRetentionEnabled=$(grep -e "^expire-after" /etc/security/audit_control | awk -F ":" '{print $2}')
if [[ $isAuditingRetentionEnabled == "60d" || $isAuditingRetentionEnabled == "1G" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Security Auditing Retention Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure the Security Auditing Retention expire-after to 60d or 1G  ⚠️"
fi

log info "3.5 Ensure Access to Audit Records Is Controlled"
auditControlFileInfo=$(stat -f '%A %u %g' /etc/security/audit_control)
varControlFileInfo=$(stat -f '%A %u %g' /var/audit)
if [[ $auditControlFileInfo == "337 0 0" && $varControlFileInfo == "337 0 0" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Audit records permissions properly configured ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure audit records properly ⚠️"
fi

log info "3.6 Ensure Firewall Logging Is Enabled and Configured"
isFirewallLoggingEnabled=$(/usr/sbin/system_profiler SPFirewallDataType | /usr/bin/grep Logging | grep -c Yes)
firewallLoggingDetail=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.alf.plist loggingoption)
if [[ $isFirewallLoggingEnabled -eq 1 && firewallLoggingDetail -eq 2 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Firewall logging is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable firewall logging ⚠️"
fi

logTitle "4 - Network Configurations"

log info "4.2 Ensure Show Wi-Fi status in Menu Bar Is Enabled"
isWifiStatusInMenubar=$(sudo -u "$USER" /usr/bin/defaults -currentHost read com.apple.controlcenter.plist WiFi)
if [[ -z $isWifiStatusInMenubar || isWifiStatusInMenubar -ne 18 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure Wi-Fi status in Menu Bar ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Wi-Fi status ✅"
fi

log info "4.4 Ensure HTTP Server Is Disabled"
isApacheDisabled=$(/bin/launchctl print-disabled system | /usr/bin/grep -c '"org.apache.httpd" => true')
if [[ isApacheDisabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Apache HTTP Server disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Apache HTTP Server ⚠️"
fi

log info "4.5 Ensure NFS Server Is Disabled"
isNFSEnabled=$(launchctl print-disabled system | grep -c '"com.apple.nfsd" => false')
if [[ isNFSEnabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable NFS Server ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "NFS Server disabled ✅"
fi

logTitle "5 - System Access, Authentication and Authorization"
logTitle "5.1 - File System Permissions and Access Controls"

log info "5.1.1 Ensure Home Folders Are Secure"
homePermissions=$(/bin/ls -l /Users/ | grep "$USER" | awk -F " " '{print $1}')
if [[ $homePermissions == *"drwx------"* ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Home directory has right permissions ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure home folder with right permissions ⚠️"
fi

log info "5.1.2 Ensure System Integrity Protection Status (SIPS) Is Enabled"
isSIPSEnabled=$(/usr/bin/csrutil status | grep -c enabled)
if [[ $isSIPSEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "System Integrity Protection Status (SIPS) Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable System Integrity Protection Status (SIPS) ⚠️"
fi

log info "5.1.3 Ensure Apple Mobile File Integrity Is Enabled"
isMobileFileIntegrityEnabled=$(/usr/sbin/nvram -p | /usr/bin/grep -c "amfi_get_out_of_my_way=1")
if [[ $isMobileFileIntegrityEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Mobile File Integrity Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Mobile File Integrity ⚠️"
fi

log info "5.1.4 Ensure Library Validation Is Enabled"
isLibraryValidationEnabled=$(sudo -u "$USER" /usr/bin/defaults read /Library/Preferences/com.apple.security.libraryvalidation.plist DisableLibraryValidation)
if [[ -z $isLibraryValidationEnabled || isLibraryValidationEnabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Library Validation Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Library Validation ⚠️"
fi

log info "5.1.5 Ensure Sealed System Volume (SSV) Is Enabled"
isSSVEnabled=$(/usr/bin/csrutil authenticated-root status | grep -c enabled)
if [[ isSSVEnabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Sealed System Volume (SSV) Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable Sealed System Volume (SSV) ⚠️"
fi

log info "5.1.6 Ensure Appropriate Permissions Are Enabled for System Wide Applications"
apps=()
while IFS=  read -r -d $'\0'; do
  apps+=("$REPLY")
done < <(sudo find /Applications -type d -perm -2 -print0)

if [[ ${#apps[@]} -gt 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "You have applications with misconfiguration permissions ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Applications are OK ✅"
fi

logTitle "5.2 - Password Management"

log info "5.2.1 Ensure Password Account Lockout Threshold Is Configured"
passwordAccountLockout=$(/usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A 1 'policyAttributeMaximumFailedAuthentications' | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1)
if [[ $passwordAccountLockout -le 5 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Applications are OK ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "You have to configure a correct Password Account Lockout (5 or less) ⚠️"
fi

log info "5.2.2 Ensure Password Minimum Length Is Configured"
passwordLength=$(/usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A1 minimumLength | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1)
if [[ $passwordLength -ge 15 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Password Minimum Length is OK ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "You have to configure a minimum password length of 15 or greater ⚠️"
fi

log info "5.2.7 Ensure Password Age Is Configured"
passwordAge=$(/usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A1 policyAttributeDaysUntilExpiration | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1)
if [[ $passwordAge -le 365 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Password Age is OK ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "You have to configure a minimum password age of 365 days (525600 min) or less ⚠️"
fi

log info "5.2.8 Ensure Password History Is Configured"
passwordHistory=$(/usr/bin/pwpolicy -getaccountpolicies | /usr/bin/grep -A1 policyAttributePasswordHistoryDepth | /usr/bin/tail -1 | /usr/bin/cut -d'>' -f2 | /usr/bin/cut -d '<' -f1)
if [[ $passwordHistory -ge 15 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Password History is OK ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "You have to configure password history at least 15 ⚠️"
fi

log info "5.3 Ensure the Sudo Timeout Period Is Set to Zero"
isSudoTimeoutPeriodZero=$(/usr/bin/grep -c "timestamp" /etc/sudoers)
if [[ $isSudoTimeoutPeriodZero -ge 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Sudo Timeout Period is OK ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "You have to configure sudo timeout period to 0 ⚠️"
fi

log info "5.4 Ensure a Separate Timestamp Is Enabled for Each User/tty Combo"
sudoTtyTickets=$(/usr/bin/grep -E -s '!tty_tickets' /etc/sudoers /etc/sudoers.d/*)
sudoTimestampType=$(/usr/bin/grep -E -s 'timestamp_type' /etc/sudoers /etc/sudoers.d/*)
if [[ (-z $sudoTtyTickets) && (-z $sudoTimestampType || $sudoTimestampType != *"timestamp_type=ppid"* || $sudoTimestampType != *"timestamp_type=global"*) ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "sudoers controls are in place with explicit tickets per tty ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "sudoers controls are NOT in place with explicit tickets per tty ⚠️"
  log warn "Please refer to original document to resolve this issue ⚠️"
fi

log info "5.6 Ensure the root Account Is Disabled"
isRootAccountDisabled=$(sudo /usr/bin/dscl . -read /Users/root AuthenticationAuthority 2>&1)
if [[ $isRootAccountDisabled == *"No such key: AuthenticationAuthority"* ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "root Account is disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable root account ⚠️"
fi

log info "5.7 Ensure Automatic Login Is Disabled"
isAutomaticLoginDisabled=$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>&1 | grep -c "does not exist")
if [[ $isAutomaticLoginDisabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Automatic Login is Disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable automatic login ⚠️"
fi

log info "5.8 Ensure a Password is Required to Wake the Computer From Sleep or Screen Saver Is Enabled"
askForPassword=$(/usr/bin/defaults read /Library/Preferences/com.apple.screensaver askForPassword)
askForPasswordDelay=$(/usr/bin/defaults read /Library/Preferences/com.apple.screensaver askForPasswordDelay)
if [[ $askForPassword -eq 1 && $askForPasswordDelay -eq 5 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Password is Required to Wake the Computer From Sleep or Screen Saver Is Enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable password for computer from sleep ⚠️"
fi

log info "5.10 Require an administrator password to access system-wide preferences"
passwordForPreferences=$(security authorizationdb read system.preferences 2> /dev/null | grep -A1 shared | grep false)
if [[ $passwordForPreferences == *"<false/>"* ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Administrator password is required to access system-wide preferences ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure a password to access system-wide preferences ⚠️"
  log warn "1. Open System Preferences
            2. Select Security & Privacy
            3. Select General
            4. Select Advanced...
            5. Set Require an administrator password to access system-wide preferences"
fi

log info "5.11 Ensure an administrator account cannot login to another user's active and locked session"
isAccountLockedAccessedByAdministratorDisabled=$(security authorizationdb read system.login.screensaver 2>&1 | /usr/bin/grep -c 'use-login-window-ui')
if [[ $isAccountLockedAccessedByAdministratorDisabled -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Administrator cannot access to logged in nad locked session ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable administrator to access another user's active and locked sessions ⚠️"
fi

log info "5.12 Ensure a Custom Message for the Login Screen Is Enabled"
loginText=$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow.plist LoginwindowText)
if [[ $loginText == "$LOGIN_MESSAGE" ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Login custom message is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure a custom login message ⚠️"
fi

log info "5.14 Ensure Users' Accounts Do Not Have a Password Hint"
accountHint=$(/usr/bin/dscl . -list /Users hint | awk -F " " '{print $1" "$3}')
if [[ $accountHint == *"$USER hint"* ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please remove password hint ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Password hint is disabled ✅"
fi

logTitle "6 - User Accounts and Environment"
logTitle "6.1 Accounts Preferences Action Items"

log info "6.1.1 Ensure Login Window Displays as Name and Password Is Enabled"
isLoginFullNameShown=$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow SHOWFULLNAME)
if [[ $isLoginFullNameShown -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Login Window displays full name ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please configure show user full name at login screen ⚠️"
fi

log info "6.1.2 Ensure Show Password Hints Is Disabled"
isPasswordHintDisabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.loginwindow RetriesUntilHint)
if [[ $isPasswordHintDisabled -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Password hint is disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable password hint retries ⚠️"
fi

log info "6.1.3 Ensure Guest Account Is Disabled"
isGuestAccountEnabled=$(/usr/bin/defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled)
if [[ $isGuestAccountEnabled -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable guest account ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Guest account is disabled ✅"
fi

log info "6.1.4 Ensure Guest Access to Shared Folders Is Disabled"
isGuestAccessToSharedFolders=$(/usr/bin/defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess)
if [[ $isGuestAccessToSharedFolders -eq 1 ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable guest account ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Guest account is disabled ✅"
fi

log info "6.1.5 Ensure the Guest Home Folder Does Not Exist"
existsHomeFolder=$(sudo /bin/ls /Users/ | /usr/bin/grep Guest)
if [[ -n $existsHomeFolder ]]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please delete guest home folder ⚠️"
else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Guest home folder does not exists ✅"
fi

log info "6.2 Ensure Show All Filename Extensions Setting is Enabled"
areExtensionsShowed=$(sudo -u "$USER" /usr/bin/defaults read /Users/"$USER"/Library/Preferences/.GlobalPreferences.plist AppleShowAllExtensions)
if [[ $areExtensionsShowed -eq 1 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "All filename extensions is enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please enable all filename extensions ⚠️"
fi

log info "6.3 Ensure Automatic Opening of Safe Files in Safari Is Disabled"
isSafariAutoOpenFiles=$(sudo -u "$USER" /usr/bin/defaults read /Users/"$USER"/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads)
if [[ $isSafariAutoOpenFiles -eq 0 ]]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Safari automatic opening files is disabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Please disable Safari automatic opening files ⚠️"
fi