#!/bin/bash
# LinuxGSM check_logs.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if log files exist.

local commandname="CHECK"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_check_logs(){
	fn_print_dots "Checking for log files"
	sleep 0.5
	fn_print_info_nl "Checking for log files: Creating log files"
	checklogs=1
	install_logs.sh
}

# Create directories for the script and console logs
if [ ! -d "${lgsmlogdir}" ]||[ ! -d "${consolelogdir}" ]&&[ "${gamename}" != "TeamSpeak 3" ]; then
	fn_check_logs
fi

# Create gamelogdir
# If variable exists gamelogdir exists and log/server does not
if [ -n "${gamelogdir}" ]&&[ -d "${gamelogdir}" ]&&[ ! -d "${logdir}/server" ]; then
	fn_check_logs
fi
