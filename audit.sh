#!/bin/bash

##################################################
## THIS SCRIPT CHECK ALL THE STEPS DESCRIBED IN
## https://www.cisecurity.org/benchmark/apple_os
##################################################
TOTAL_SUCCESS=0
TOTAL_WARN=0

function log(){
  local red='\033[0;31m'
  local green='\033[0;32m'
  local yellow='\033[1;33m'
  local blue='\033[0;34m'
  local reset='\033[0m'

  local message="${2}"
  local level="${1}"
  local color=""

  case $level in
    error)
      color=$red
    ;;
    success)
      color=$green
    ;;
    warn)
      color=$yellow
    ;;
    info)
      color=$blue
    ;;
  esac

  echo -e "${color} `date "+%Y/%m/%d %H:%M:%S"`" $message$" ${reset}"
}
function dateDiffNow(){
  now=$(date "+%Y-%m-%d")
  echo $(( ($(date -d $now +%s) - $(date -d $1 +%s)) / 86400 ))  
}

log info "========================"
log info "#ICDC MacOS Auditor v1.0"
log info "========================"
echo -e "\n"
log info "Asking for root permissions..."

if [[ "$EUID" = 0 ]]; then
  log success "You are root 🤖"
else
  sudo -k
  if sudo true; then
    log success "Login successfully 🤖"
  else
    log error "Wrong password, please retry ❌"
    exit 1
  fi
fi

# 1.1 Ensure All Apple-provided Software Is Current
log info "1.1 Checking last date software update date... 🔍"
lastFullSuccessfulDate=$(/usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate | awk -F '"' '$0=$2' | awk '{ print $1 }')
daysAfterFullSuccessfulDate=$(dateDiffNow $lastFullSuccessfulDate);
log info "Your system has $daysAfterFullSuccessfulDate days after your last successful date"
if [ $daysAfterFullSuccessfulDate -gt 30 ]; then
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system is not updated, please update to lastest version ⚠️"
 else
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system is updated ✅"
fi


# 1.2 Ensure Auto Update Is Enabled
log info "1.2 Checking if autoupdate is enabled"
isAutomaticUpdatesEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled)
if [ $isAutomaticUpdatesEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have check automatic updates ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic updates ⚠️"
  #log warn "Enabling automatic updates..."
  #sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  #log success "Automatic updates enabled successfully ✅"
fi


# 1.3 Ensure Download New Updates When Available is Enabled
log info "1.3 Ensuring if download new updates when available is enabled"
isAutomaticDownloadEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload)
if [ $isAutomaticDownloadEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have automatic download updates enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic download updates ⚠️"
  #log warn "Enabling automatic download updates..."
  #sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
  #log success "Automatic download updates enabled successfully ✅"
fi


# 1.4 Ensure Installation of App Update Is Enabled
log info "1.3 Ensuring if installation of app update is enabled"
isNewUpdatesAppEnabled=$(sudo /usr/bin/defaults read /Library/Preferences/com.apple.commerce AutoUpdate)
if [ $isNewUpdatesAppEnabled -eq 1 ]; then
  TOTAL_SUCCESS=$((TOTAL_SUCCESS+1))
  log success "Your system have automatic app download updates enabled ✅"
else
  TOTAL_WARN=$((TOTAL_WARN+1))
  log warn "Your system dont have automatic app download updates ⚠️"
  #log warn "Enabling automatic download updates..."
  #sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
  #log success "Automatic download updates enabled successfully ✅"
fi



log info "=============="
log info "Audit Overview"
log info "=============="
log warn "Total: ${TOTAL_WARN} ⚠️"
log success "Total: ${TOTAL_SUCCESS} ✅"







# log info "Installing software updates... 🤖"
# sudo /usr/sbin/softwareupdate -i -a -R