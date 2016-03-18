#!/bin/bash
# LGSM core_getopt.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="180316"

# Description: REDIRECT FUNCTION to new location for core_getopt.sh

core_getopt.sh(){
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_getopt.sh