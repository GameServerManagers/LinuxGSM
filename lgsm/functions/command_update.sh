#!/bin/bash
# LinuxGSM command_update.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of servers.

commandname="UPDATE"
commandaction="Updating"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots ""
check.sh
core_logs.sh
check_last_update.sh

if [ "${shortname}" == "ts3" ]; then
	update_ts3.sh
elif [ "${shortname}" == "mc" ]; then
	update_minecraft.sh
elif [ "${shortname}" == "mcb" ]; then
	update_minecraft_bedrock.sh
elif [ "${shortname}" == "mumble" ]; then
	update_mumble.sh
elif [ "${shortname}" == "fctr" ]; then
	update_factorio.sh
elif [ "${shortname}" == "mta" ]; then
	update_mta.sh
elif [ "${shortname}" == "jk2" ]; then
	update_jediknight2.sh	
else
	update_steamcmd.sh
fi

core_exit.sh
