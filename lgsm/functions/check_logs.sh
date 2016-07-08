#!/bin/bash
# LGSM check_logs.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Checks that log files exist on server start

local modulename="Checking"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Create dir's for the script and console logs
if [ ! -d "${scriptlogdir}" ]||[ ! -d "${consolelogdir}" ]&&[ "${gamename}" != "Teamspeak 3" ]; then
	fn_print_dots "Checking for log files"
	sleep 1
	fn_print_info_nl "Checking for log files: Creating log files"
	checklogs=1
	install_logs.sh
fi
