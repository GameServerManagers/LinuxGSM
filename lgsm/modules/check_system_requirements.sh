#!/bin/bash
# LinuxGSM check_system_requirements.sh
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks RAM requirements.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_distro.sh

# RAM requirements in gigabytes for each game or engine.

if [ "${shortname}" == "ark" ]; then
	ramrequirementgb="7"
elif [ "${shortname}" == "arma3" ]; then
	ramrequirementgb="2"
elif [ "${shortname}" == "armar" ]; then
	ramrequirementgb="3"
elif [ "${shortname}" == "bt" ]; then
	ramrequirementgb="1"
elif [ "${shortname}" == "cc" ]; then
	ramrequirementgb="1"
elif [ "${shortname}" == "dayz" ]; then
	ramrequirementgb="5"
elif [ "${shortname}" == "dodr" ]; then
	ramrequirementgb="2"
elif [ "${shortname}" == "hw" ]; then
	ramrequirementgb="3"
elif [ "${shortname}" == "mc" ]; then
	ramrequirementgb="1"
elif [ "${shortname}" == "pmc" ]; then
	ramrequirementgb="2"
elif [ "${shortname}" == "mh" ]; then
	ramrequirementgb="4"
elif [ "${shortname}" == "ns2" ] || [ "${shortname}" == "ns2c" ]; then
	ramrequirementgb="1"
elif [ "${shortname}" == "ps" ]; then
	ramrequirementgb="2"
elif [ "${shortname}" == "pvr" ]; then
	ramrequirementgb="1"
elif [ "${shortname}" == "pz" ]; then
	ramrequirementgb="3"
elif [ "${shortname}" == "rust" ]; then
	ramrequirementgb="9"
elif [ "${shortname}" == "sdtd" ]; then
	ramrequirementgb="4"
elif [ "${shortname}" == "sf" ]; then
	ramrequirementgb="12"
elif [ "${shortname}" == "squad" ]; then
	ramrequirementgb="2"
elif [ "${shortname}" == "sm" ]; then
	ramrequirementgb="10"
elif [ "${shortname}" == "st" ]; then
	ramrequirementgb="1"
elif [ "${shortname}" == "stn" ]; then
	ramrequirementgb="3"
elif [ "${shortname}" == "tu" ]; then
	ramrequirementgb="2"
elif [ "${shortname}" == "vh" ]; then
	ramrequirementgb="2"
else
	ramrequirementgb="0.5"
fi

# If the game or engine has a minimum RAM Requirement, compare it to system's available RAM.
if [ "${ramrequirementgb}" ]; then
	if (($(echo "${physmemtotalgb} < ${ramrequirementgb}" | bc -l))); then
		fn_print_dots "Checking RAM"
		fn_print_warn_nl "Checking RAM: ${ramrequirementgb}G required, ${physmemtotal} available"
		echo "* ${gamename} server may fail to run or experience poor performance."
		fn_sleep_time_5
	fi
fi
