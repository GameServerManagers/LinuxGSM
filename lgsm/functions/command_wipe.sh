#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Wipes server data, useful after updates for some games like Rust

local commandname="WIPE"
local commandaction="wipe data"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

fn_print_header

# Checks if there is something to wipe
fn_wipe_server(){
	# Rust Wipe
	if [ "${gamename}" == "Rust" ]; then
		if [ -d "${serveridentitydir}/storage" ]||[ -d "${serveridentitydir}/user" ]||[ -n "$(find "{serveridentitydir}" -type f -name "proceduralmap*.sav")" ]; then
			echo " * Any user, storage, and map data will be erased."
			while true; do
				read -e -i "y" -p "Continue? [Y/n]" yn
				case $yn in
				[Yy]* ) break;;
				[Nn]* ) echo Exiting; core_exit.sh;;
				* ) echo "Please answer yes or no.";;
				esac
			done
			fn_script_log_info "User selected to continue"
			fn_wipe_server_process
		else 
			echo "Nothing to wipe"
			core_exit.sh
		fi
	else
		echo "Wipe is not available"
		core_exit.sh
	fi
}

# Removes files to wipe server
fn_wipe_server_remove_files(){
	if [ "${gamename}" == "Rust" ]; then
		if [ -n "$(find "{serveridentitydir}" -type f -name "proceduralmap*.sav")" ]; then
			echo "Removing map"
			rm -f "${serveridentitydir}/proceduralmap*.sav"
		fi
		if [ -d "${serveridentitydir}/user" ]; then
			echo "Removing users data"
			rm -rf "${serveridentitydir}/user"
		fi
		if [ -d "${serveridentitydir}/storage" ]; then
			echo "Removing storage data"
			rm -rf "${serveridentitydir}/storage"
		fi
	fi
}

# Process to server wipe
fn_wipe_server_process(){
	check_status.sh
	if [ "${status}" != "0" ]; then
		exitbypass=1
		command_stop.sh
		fn_wipe_server_remove_files
		exitbypass=1
		command_start.sh
	else
		fn_wipe_server_remove_files
	fi
	echo "Server Wiped"
}

fn_wipe_server
