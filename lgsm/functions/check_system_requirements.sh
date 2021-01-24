#!/bin/bash
# LinuxGSM check_system_requirements.sh
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks RAM requirements.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_distro.sh

# RAM requirements in megabytes for each game or engine.

if [ "${shortname}" == "ark" ]; then
	ramrequirementmb="4000"
	ramrequirementgb="4"
elif [ "${shortname}" == "bt" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${shortname}" == "mh" ]; then
	ramrequirementmb="4000"
	ramrequirementgb="4"
elif [ "${shortname}" == "arma3" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${shortname}" == "rust" ]; then
	ramrequirementmb="4000"
	ramrequirementgb="4"
elif [ "${shortname}" == "mc" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${shortname}" == "pstbs" ]; then
	ramrequirementmb="2000"
	ramrequirementgb="2"
elif [ "${shortname}" == "ns2" ]||[ "${shortname}" == "ns2c" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${shortname}" == "st" ]; then
	ramrequirementmb="1000"
	ramrequirementgb="1"
elif [ "${shortname}" == "pvr" ];then
	ramrequirementmb="2000"
	ramrequirementgb="2"
fi

# If the game or engine has a minimum RAM Requirement, compare it to system's available RAM.
if [ "${ramrequirementmb}" ]; then
	if [ "${physmemtotalmb}" -lt "${ramrequirementmb}" ]; then
		fn_print_dots "Check RAM"
		# Warn the user.
		fn_print_warn_nl "Check RAM: ${ramrequirementgb}G required, ${physmemtotal} available"
		echo  "	* ${gamename} server may fail to run or experience poor performance."
		fn_sleep_time
	fi
fi
