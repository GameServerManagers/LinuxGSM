#!/bin/bash
# LGSM command_start_foreground.sh function
# Author: Robotex
# Github: https://github.com/Robotex/
# Description: Starts the server on foreground.

local commandname="START-FOREGROUND"
local commandaction="Starting on foreground"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Trap to remove lockfile on quit.
fn_lockfile_trap(){
	# Remove lock file
	rm -f "${rootdir}/${lockselfname}"
	# resets terminal. Servers can sometimes mess up the terminal on exit.
	reset
	fn_print_ok_nl "Closing foreground"
	fn_script_log_pass "Foreground closed"
	core_exit.sh
}

fn_start_foreground(){
	fn_parms

	# If server is already running stop it
	fn_print_info_nl "Stopping any running servers"
	fn_script_log_info "Stopping any running servers"
	sleep 1
	exitbypass=1
	command_stop.sh

	# Log rotation
	fn_script_log_info "Rotating log files"
	if [ "${engine}" == "unreal2" ]; then
		if [ -f "${gamelog}" ]; then
			mv "${gamelog}" "${gamelogdate}"
		fi
	fi
	mv "${scriptlog}" "${scriptlogdate}"
	mv "${consolelog}" "${consolelogdate}"

	# Create lock file
	date > "${rootdir}/${lockselfname}"
	# trap to remove lockfile on quit.
	trap fn_lockfile_trap INT
	cd "${executabledir}"
	${executable} ${parms}

	# Console logging enable or not set
	if [ "${consolelogging}" == "on" ]||[ -z "${consolelogging}" ]; then
		touch "${consolelog}"
		${executable} ${parms} 2>&1 | tee "${consolelog}"

	# Console logging disabled
	elif [ "${consolelogging}" == "off" ]; then
		touch "${consolelog}"
		cat "Console logging disabled by user" >> "{consolelog}"
		fn_script_log_info "Console logging disabled by user"
		${executable} ${parms}
	fi
	sleep 1

	# remove trap.
	trap - INT
	echo -en "\n"
}

fn_print_dots "${servername}"
sleep 1
check.sh
fix.sh
info_config.sh
logs.sh

# Will check for updates is updateonstart is yes
if [ "${status}" == "0" ]; then
	if [ "${updateonstart}" == "yes" ]||[ "${updateonstart}" == "1" ]||[ "${updateonstart}" == "on" ]; then
		exitbypass=1
		command_update.sh
	fi
fi

fn_start_foreground

core_exit.sh