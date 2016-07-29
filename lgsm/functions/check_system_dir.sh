#!/bin/bash
# LGSM check_system_dir.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Checks if systemdir is accessible.

local commandname="CHECK"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ ! -d "${systemdir}" ]; then
	fn_print_fail_nl "Cannot access ${systemdir}: No such directory"
	if [ -d "${scriptlogdir}" ]; then
		fn_script_log_fatal "Cannot access ${systemdir}: No such directory."
	fi
	core_exit.sh
fi
