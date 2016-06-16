#!/bin/bash
# LGSM core_getopt.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: REDIRECT FUNCTION to new location for core_getopt.sh

core_getopt.sh(){
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_getopt.sh