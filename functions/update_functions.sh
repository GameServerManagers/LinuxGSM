#!/bin/bash
# LGSM fn_update_functions function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: REDIRECT FUNCTION to new command_update_functions.sh

command_update_functions.sh(){
functionfile="${FUNCNAME}"
fn_runfunction
}

command_update_functions.sh

