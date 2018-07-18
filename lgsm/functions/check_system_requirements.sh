#!/bin/bash
# LinuxGSM check_system_requirements.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Checks RAM requirements

local commandname="CHECK"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_distro.sh

# RAM requirements in megabytes for each game or engine.

if [ "${gamename}" == "ARK: Survival Evolved" ]; then
	ramrequirementmb="4000"
	ramrequirementgb="4"
elif [ "${gamename}" == "ARMA 3" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${gamename}" == "Rust" ]; then
	ramrequirementmb="4000"
	ramrequirementgb="4"
elif [ "${gamename}" == "Minecraft" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${gamename}" == "Natural Selection 2" ]||[ "${gamename}" == "NS2: Combat" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${shortname}" == "st" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
fi

# If the game or engine has a minimum RAM Requirement, compare it to system's available RAM.
if [ -n "${ramrequirementmb}" ]; then
	if [ "${physmemtotalmb}" -lt "${ramrequirementmb}" ]; then
		fn_print_dots "Check RAM"
		sleep 0.5
		# Warn the user
		fn_print_warn_nl "Check RAM: ${ramrequirementgb}G required, ${physmemtotal} available"
		sleep 0.5
		echo  "	* ${gamename} server may fail to run or experience poor performance."
		sleep 0.5
	fi
fi
