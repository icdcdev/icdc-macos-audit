#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

#######################################
# Print a message to console
# GLOBALS: N/A
# ARGUMENTS:
#   ${1} STRING - Message level (e.g error, success, warn, info)
#   ${2} STRING - Message that will be printed
# OUTPUTS:
#   Write String with echo to terminal output
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
function log(){
  local red='\033[0;31m'
  local green='\033[0;32m'
  local yellow='\033[1;33m'
  local blue='\033[0;34m'
  local reset='\033[0m'

  local message="${2}"
  local level="${1}"
  local color=""
  local levelFmt=""

  case $level in
    error)
      color=$red
      levelFmt="ERROR"
    ;;
    success)
      color=$green
      levelFmt=" OK "
    ;;
    warn)
      color=$yellow
      levelFmt="WARN"
    ;;
    info)
      color=$blue
      levelFmt="INFO"
    ;;
  esac
  
  echo -e "${color} `date "+%Y/%m/%d %H:%M:%S"`" $message$" ${reset}"
  echo "`date "+%Y/%m/%d %H:%M:%S"` [$levelFmt] $message" >> $LOG_FILE
}

function logTitle(){
  special=$(echo "${1}" | sed 's/./=/g')
  echo -e "\n"
  echo $'\n' >> $LOG_FILE
  log info $special
  log info "${1}"
  log info $special

  
}

#######################################
# Calculate the number of days that have passed since a given date
# GLOBALS: N/A
# ARGUMENTS:
#   ${1} STRING - Date to use in format YYYY-MM-DD
# OUTPUTS: N/A
# RETURN:
#   INTEGER - The number of days that have passed since date given
#######################################
function dateDiffNow(){
  nowTimestamp=$(date "+%s")
  dateTimestamp=$(date -j -f '%Y-%m-%d' "$1" "+%s")

  echo $(((nowTimestamp - dateTimestamp) / 86400))
}

############################################
# Check if current user has sudo permissions
# GLOBALS: N/A
# OUTPUTS: N/A
# RETURN:  N/A
############################################
function checkSudoPermissions(){
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
  echo -e "\n"
}

############################################
# Check if device has dependencies installed
# GLOBALS: N/A
# OUTPUTS: N/A
# RETURN:  N/A
############################################
function checkDependencies(){
  log info "======================================"
  log info "Checking if dependencies are installed"
  log info "======================================"
  log info "Checking if Homebrew is installed"
  if [[ $(command -v brew) == "" ]]; then
    echo "Installing Hombrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    log success "Hombrew is installed ✅"
  fi

  log info "Checking if Blueutil is installed"
  if [[ $(command -v blueutil) == "" ]]; then
    echo "Installing Blueutil"
    brew install blueutil
  fi
  log info "Checking if jq is installed"
  if [[ $(command -v jq) == "" ]]; then
    echo "Installing jq"
    brew install jq
  fi
}

############################################
# Check if folder or file has the following
# permissions: -r--r----- root wheel
# GLOBALS: N/A
# OUTPUTS: N/A
# RETURN:  true - if all files have set the
#          permissions correctly
#          false - if any file does not have
#          the previous configuration
############################################
function isWriteAndReadPermissionsRight(){
  local path=$1
  local permissions=$2
  local user=$3
  local group=$4

  local files=$(ls -le $path)
  local totalFiles=0
  local command="find $path !"
  if [[ -n $permissions ]]; then
    command=" $command -perm $permissions"
  fi
  if [[ -n $user ]]; then
    command=" $command -user $user"
  fi
  if [[ -n $group ]]; then
    command=" $command -group $group"
  fi

  for file in `$command`; do
    if [[ $file == $path || $file == *"current"* ]]; then
      continue
    fi
    totalFiles=$((totalFiles+1))
  done

  if [[ $totalFiles -eq 0 ]]; then
    echo 1
  else
    echo 0
  fi
}