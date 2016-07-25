#!/bin/bash
# LGSM check_config.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Checks if the server config is missing and warns the user if needed.

local commandname="CHECK"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ ! -e "${servercfgfullpath}" ]; then
	if [ "${gamename}" != "Hurtworld" ]; then
		fn_print_dots ""
		sleep 0.5
		fn_print_warn_nl "Configuration file missing!"
		echo "${servercfgfullpath}"
		fn_script_log_warn "Configuration file missing!"
		fn_script_log_warn "${servercfgfullpath}"
		sleep 2
	fi
fi