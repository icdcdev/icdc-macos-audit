#!/bin/bash
# Copyright 2022 Volkswagen de México
# Developed by: ICDC Dev Team
# This script checks all the steps described in
# https://www.cisecurity.org/benchmark/apple_os

source ./utils/vars.sh
source ./utils/functions.sh
#checkSudoPermissions
#checkDependencies
source ./audit/l1.sh
source ./audit/l2.sh

logTitle "Audit Overview"
log warn "Total: ${TOTAL_WARN} ⚠️"
log success "Total: ${TOTAL_SUCCESS} ✅" 