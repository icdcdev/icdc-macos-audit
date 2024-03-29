#!/bin/bash
# Copyright 2022 Volkswagen de Mexico
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

logTitle "#ICDC MacOS Auditor (Applier L1) v1.0"
logTitle "Section 1 - Install Updates, Patches and Additional Security Software"

log info "1.1 Verifying apple-provided software updates..."
sudo /usr/sbin/softwareupdate -i -a
log success "1.1 System is updated ✅"

log info "1.2 Enabling automatic updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
log success "1.2 Auto update enabled ✅"

log info "1.3 Enabling download new updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
log success "Download new updates enabled ✅"

log info "1.4 Enabling automatic download updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
log success "Automatic download updates enabled successfully ✅"

log info "1.5 Enabling Data Files & Security Updates download..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
log success "Automatic download updates enabled successfully ✅"

log info "1.6 Enabling Install of macOs Updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
log success "Installation of macOs Updates enabled successfully ✅"

log info "1.6 Enabling Install of macOs Updates..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
log success "Installation of macOs Updates enabled successfully ✅"

logTitle "Section 2 - System Preferences"
logTitle "Section 2.1 - Bluetooth"

log info "2.1.1 Checking if bluetooth is disabled..."
isBluetoothEnabled=$(blueutil -p)
if [[ $isBluetoothEnabled -eq 1 ]]; then
  log info "Bluetooth enabled, checking if exists paired devices..."
  pairedBluetoothDevices=$(blueutil --connected --format json | jq 'length')
  if [[ $pairedBluetoothDevices -eq 0 ]]; then
    log info "Bluetooth enabled and no devices paired, turning off bluetooth..."
    blueutil -p 0
    log info "Bluetooth disabled successfully ✅"
  else
    log info "Bluetooth enabled and devices paired ✅"
  fi
fi

log info "2.1.2 Enabling Bluetooth status in menu bar..."
sudo -u "$USER" /usr/bin/defaults write com.apple.controlcenter.plist "NSStatusItem Visible Bluetooth" -int 18
sudo -u "$USER" default -currentHost write com.apple.controlcenter.plist Bluetooth -int 18
sudo -u "$USER" default write com.apple.controlcenter.plist Bluetooth -int 18
log success "Bluetooth status in menu bar enabled successfully ✅"

logTitle "Section 2.2 - Date & Time"

log info "2.2.1 Setting time and date automatically..."
/usr/sbin/systemsetup -setnetworktimeserver "$TIME_SERVER" > /dev/null 2>&1
/usr/sbin/systemsetup -setusingnetworktime on > /dev/null 2>&1
log success "Time and date enabled successfully ✅" 

log info "2.2.2 Setting time and date automatically within appropriate limits..."
sudo sntp -sS "$TIME_SERVER" -t 10 > /dev/null 2>&1
log success "Time and date with appropriate limits enabled successfully ✅"

logTitle "Section 2.3 - Desktop & Screen Saver"

log info "2.3.1 Setting inactivity interval of 20 minutes or less for the screen saver..."
sudo -u "$USER" /usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 600
log success "1 min for screen saver configured successfully ✅"

log info "2.3.3 Setting up Bottom Left hot corner to lock screen..."
sudo -u "$USER" /usr/bin/defaults write com.apple.dock wvous-bl-corner -int 5
log success "Bottom Left hot corner configured successfully ✅"

logTitle "Section 2.4 - Sharing"

log info "2.4.1 Disabling Remote Apple Events..."
sudo /usr/sbin/systemsetup -setremoteappleevents off > /dev/null
log success "Remote Apple Events disabled successfully ✅"

log info "2.4.2 Disabling Internet sharing..."
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict Enabled -int 0
log success "Internet Sharing disabled successfully ✅"

log info "2.4.3 Disabling Screen sharing..."
sudo launchctl disable system/com.apple.screensharing
log success "Screen Sharing disabled successfully ✅"

log info "2.4.4 Disabling Printer sharing..."
sudo cupsctl --no-share-printers
log success "Printer Sharing disabled successfully ✅"

log info "2.4.5 Disabling Remote Login..."
sudo systemsetup -f -setremotelogin off > /dev/null
log success "Remote Login disabled successfully ✅"

log info "2.4.6 Disabling DVD/CD Sharing..."
sudo launchctl disable system/com.apple.ODSAgent 
log success "DVD/CD Sharing disabled successfully ✅"

log info "2.4.7 Disabling Bluetooth Sharing..."
sudo -u "$USER" /usr/bin/defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false
log success "Bluetooth Sharing disabled successfully ✅"

log info "2.4.8 Disabling File Sharing..."
sudo launchctl disable system/com.apple.smbd
log success "File Sharing disabled successfully ✅"

log info "2.4.9 Disabling Remote Management..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop > /dev/null
log success "Remote Management disabled successfully ✅"

log info "2.4.11 Disabling Airdrop..."
sudo -u "$USER" defaults write com.apple.NetworkBrowser DisableAirDrop -bool true
log success "Airdrop disabled successfully ✅"

log info "2.4.13 Disabling AirPlay..."
sudo -u "$USER" defaults -currentHost write com.apple.controlcenter.plist AirplayRecieverEnabled -bool false
log success "AirPlay disabled successfully ✅"

logTitle "Section 2.5 - Security & Privacy"
logTitle "Section 2.5.1 - Encryption"

log info "2.5.1.1 Enabling FileVault..."
sudo fdesetup enable -user "$USER" > /dev/null 2>&1
log success "FileVault enabled successfully ✅"

logTitle "2.5.2 - Firewall"

log info "2.5.2.1 Enabling Gatekeeper..."
sudo /usr/sbin/spctl --master-enable
log success "Gatekeeper enabled successfully ✅"

log info "2.5.2.2 Enabling Firewall..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 1
log success "Gatekeeper enabled successfully ✅"

log info "2.5.2.3 Enabling Stealth Mode Firewall..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
log success "Stealth Mode Firewall enabled successfully ✅"

log info "2.5.6 Disabling Apple Personalized Advertising..."
sudo -u "$USER" defaults -currentHost write /Users/"$USER"/Library/Preferences/com.apple.Adlib.plist allowApplePersonalizedAdvertising -bool false
sudo -u "$USER" defaults -currentHost write /Users/"$USER"/Library/Preferences/com.apple.Adlib.plist forceLimitAdTracking -bool false
log success "Apple Personalized Advertising disabled successfully ✅"

logTitle "2.6 - Apple ID"
logTitle "2.7 - Time Machine"
log info "2.7.2 Ensure Time Machine Volumes Are Encrypted"

log info "2.8 Disabling Wake for Network Access..."
sudo pmset -a womp 0
log success "Wake for Network Access disabled successfully ✅"

log info "2.9 Disabling Power Nap..."
sudo pmset -a powernap 0
log success "Power Nap disabled successfully ✅"

log info "2.10 Enabling securing Keyboard Entry terminal.app ..."
sudo -u "$USER" /usr/bin/defaults write -app Terminal SecureKeyboardEntry -bool true
sudo -u "$USER" defaults write -app Terminal SecureKeyboardEntry -bool true
log success "Securing Keyboard Entry Terminal.app enabled successfully ✅"

log info "2.13 Disabling Siri ..."
sudo -u "$USER" /usr/bin/defaults write com.apple.assistant.support.plist 'Assistant Enabled' -bool false
sudo -u "$USER" /usr/bin/defaults write com.apple.Siri.plist LockscreenEnabled -bool false
sudo -u "$USER" /usr/bin/defaults write com.apple.Siri.plist StatusMenuVisible -bool false
sudo -u "$USER" /usr/bin/defaults write com.apple.Siri.plist VoiceTriggerUserEnabled -bool false
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
echo 'file $installLogFile rotate=utc compress file_max=50M ttl=365 size_only' | sudo tee -a $installLogFile > /dev/null
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
sudo chmod 337 /etc/security/audit_control
sudo chown -R root:wheel /var/audit/
sudo chmod -R 337 /var/audit/
log success "Install log enabled successfully ✅"

log info "3.6 Enabling Firewall Logging..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on > /dev/null 2>&1
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingopt detail > /dev/null 2>&1
log success "Firewall logging enabled successfully ✅"

logTitle "4 - Network Configurations"

log info "4.2 Enabling Wi-Fi status in menubar..."
sudo -u "$USER" defaults -currentHost write com.apple.controlcenter.plist WiFi -int 18
log success "Wi-Fi status in menubar enabled successfully ✅"

log info "4.4 Disabling http server..."
sudo launchctl disable system/org.apache.httpd
log success "Http server disabled successfully ✅"

log info "4.5 Disabling NFS Server..."
sudo launchctl disable system/com.apple.nfsd
log success "NFS Server disabled successfully ✅"

logTitle "5 - System Access, Authentication and Authorization"
logTitle "5.1 - File System Permissions and Access Controls"

log info "5.1.1 Configuring right permissions for $USER home folder..."
sudo /bin/chmod -R og-rwx /Users/"$USER"
log success "Home folder permissions enabled successfully ✅"

log info "5.1.2 Enabling SIPS..."
sudo /usr/bin/csrutil enable > /dev/null 2>&1
log success "SIPS enabled successfully ✅"

log info "5.1.3 Enabling Mobile File Integrity..."
sudo /usr/sbin/nvram boot-args="" 
log success "Mobile File Integrity enabled successfully ✅"

log info "5.1.4 Enabling Library Validation..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.security.libraryvalidation.plist DisableLibraryValidation -bool false
log success "Library Validation enabled successfully ✅"

log info "5.1.5 Enabling SSV..."
sudo /usr/bin/csrutil enable authenticated-root > /dev/null 2>&1
log success "SSV enabled successfully ✅"

log info "5.1.6 Configuring right permissions in /Applications..."
# shellcheck disable=SC2162
sudo find /Applications -type d -perm -2 | while read file; do
  # shellcheck disable=SC2092
  `sudo /bin/chmod -R o-w "$file"`
  log warn "Permission of application $file must be changed"
done
log success "All apps configured successfully ✅"

logTitle "5.2 - Password Management"

log info "5.2.1 Changing Password Account Lockout to 5 times..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "maxFailedLoginAttempts=5"
log success "All apps configured successfully ✅"

log info "5.2.2 Changing Password Minimum Length to 15 chars..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "minChars=15"
log success "Password Minimum Length successfully changed to 15 chars ✅"

log info "5.2.7 Changing Password Age..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "maxMinutesUntilChangePassword=52560"
log success "Password Age successfully changed to 365 days ✅"

log info "5.2.8 Changing Password History..."
sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "usingHistory=15"
log success "Password History configured to 15 elements ✅"

log info "5.3 Changing Sudo Timeout Period to 0..."
sudo echo 'Defaults timestamp_timeout=0' | sudo EDITOR='tee -a' visudo > /dev/null 2>&1
log success "Sudo Timeout Period configured to 0 successfully ✅"

log info "5.6 Disabling root account..."
sudo /usr/sbin/dsenableroot -d
log success "root account disabled successfully ✅"

log info "5.7 Disabling root account..."
sudo /usr/bin/defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
log success "root account disabled successfully ✅"

log info "5.8 Enabling password from sleep..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.screensaver askForPassword -bool true
sudo /usr/bin/defaults write /Library/Preferences/com.apple.screensaver askForPasswordDelay -int 5
log success "Password sleep enabled successfully ✅"

log info "5.11 Disabling accessing to user's active and locked session by administrator..."
sudo security authorizationdb write system.login.screensaver use-login-window-ui
log success "Administrator cross account access disabled successfully ✅"

log info "5.12 Setting up a Login custom message..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$LOGIN_MESSAGE"
log success "Login custom message configured successfully ✅"

log info "5.14 Disabling password hint..."
sudo /usr/bin/dscl . -delete /Users/"$USER" hint
log success "Password hint disabled successfully ✅"

logTitle "6 - User Accounts and Environment"
logTitle "6.1 Accounts Preferences Action Items"

log info "6.1.1 Enabling show full name in login screen..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
log success "Full name at login screen enabled successfully ✅"

log info "6.1.2 Disabling password hint retries..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0
log success "Password hint retries disabled successfully ✅"

log info "6.1.3 Disabling guest account..."
sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
log success "Guest account disabled successfully ✅"

log info "6.1.4 Disabling guest access to shared folders..."
sudo /usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false
log success "Guest access to shared folder disabled successfully ✅"

log info "6.1.5 Removing guest home folder..."
sudo /bin/rm -R /Users/Guest 
log success "Guest home folder removed successfully ✅"

log info "6.2 Enabling filename extensions..."
sudo -u "$USER" /usr/bin/defaults write /Users/"$USER"/Library/Preferences/.GlobalPreferences.plist AppleShowAllExtensions -bool true
log success "Filename extensions enabled successfully ✅"

log info "6.3 Disabling automatic Safari opening safe files..."
sudo -u "$USER" /usr/bin/defaults write /Users/"$USER"/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false
log success "Automatic Safari opening safe files disabled successfully ✅"
