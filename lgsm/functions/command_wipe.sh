#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Wipes server data for Rust, useful after monthly updates

local commandname="WIPE"
local commandaction="wipe data"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

fn_print_header

# Checks if there is something to wipe
fn_wipe_check(){
  if [ "${gamename}" == "Rust" ]; then
    if [ -d "${serveridentitydir}/storage" ]||[ -d "${serveridentitydir}/user" ]||[ -f "${serveridentitydir}/proceduralmap*.sav" ]; then
      fn_wipe_server_process
    else 
      echo "Nothing to wipe"
      core_exit.sh
    fi
}

fn_wipe_server_process(){
  check_status.sh
  if [ "${status}" != "0" ]; then
  	exitbypass=1
	  command_stop.sh
	  fn_validation
	  exitbypass=1
	  command_start.sh
else
	fn_validation
fi
}
