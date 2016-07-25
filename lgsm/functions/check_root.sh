#!/bin/bash
# LGSM check_root.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Checks if the user tried to run the script as root.

local commandname="CHECK"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ $(whoami) = "root" ]; then
	fn_print_fail_nl "Do NOT run this script as root!"
	if [ -d "${scriptlogdir}" ]; then
		fn_script_log_fatal "${selfname} attempted to run as root."
	fi
	core_exit.sh
fi
