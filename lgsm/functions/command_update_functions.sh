#!/bin/bash
# LinuxGSM command_update_functions.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.
# Legacy Command

command_update_linuxgsm.sh(){
functionfile="${FUNCNAME[0]}"
fn_fetch_function
}

command_update_linuxgsm.sh
