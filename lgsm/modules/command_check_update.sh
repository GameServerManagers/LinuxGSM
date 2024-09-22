#!/bin/bash
# LinuxGSM command_check_update.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of servers.

commandname="CHECK-UPDATE"
commandaction="Check for Update"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots ""
check.sh
core_logs.sh

if [ "${shortname}" == "ts3" ]; then
	update_ts3.sh
elif [ "${shortname}" == "mc" ]; then
	update_mc.sh
elif [ "${shortname}" == "mcb" ]; then
	update_mcb.sh
elif [ "${shortname}" == "pmc" ] || [ "${shortname}" == "vpmc" ] || [ "${shortname}" == "wmc" ]; then
	update_pmc.sh
elif [ "${shortname}" == "fctr" ]; then
	update_fctr.sh
elif [ "${shortname}" == "mta" ]; then
	update_mta.sh
elif [ "${shortname}" == "jk2" ]; then
	update_jk2.sh
elif [ "${shortname}" == "vints" ]; then
	update_vints.sh
elif [ "${shortname}" == "ut99" ]; then
	update_ut99.sh
else
	update_steamcmd.sh
fi

core_exit.sh
