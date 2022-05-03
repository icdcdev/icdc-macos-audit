#!/usr/bin/env bash


##################################################
## THIS SCRIPT CHECK ALL THE STEPS DESCRIBED IN
## https://www.cisecurity.org/benchmark/apple_os
##################################################
read -n1 c
case "$c" in
    (1) echo One. ;;
    (2) echo Two. ;;
    ($'\033') 
        read -t.001 -n2 r
        case "$r" in
            ('[A') echo Up. ;;
            ('[B') echo Down. ;;
        esac
esac