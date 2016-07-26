#!/bin/bash
# LGSM check_config.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: If server config missing warn user.

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
if [ "${gamename}" == "Rust" ]; then
        if  [ -z "${rconpassword}" ]; then
                fn_print_dots ""
                sleep 0.5
                fn_print_warn_nl "RCON password not set!"
                echo "This would lead to unexpected behavior. Aborting."
                fn_script_log_warn "No RCON Password set, exitting!"
                exit 1
        elif [ "${rconpassword}" == "CHANGE_ME" ]; then
                fn_print_dots ""
                sleep 0.5
                fn_print_warn_nl "Default RCON Password detected!"
                echo "Having CHANGE_ME as a passowrd is not very safe."
                fn_script_log_warn "RCON Password is the default one!"
                sleep 2
        fi
fi
