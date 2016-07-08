#!/bin/bash
# LGSM command_update.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Handles updating of servers.

local commandnane="UPDATE"
local commandaction="Update"
local selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

fn_print_dots "Checking for update"
if [ "${gamename}" == "Teamspeak 3" ]; then
	update_ts3.sh
elif [ "${engine}" == "goldsource" ]||[ "${forceupdate}" == "1" ]; then
	update_steamcmd.sh
fi

core_exit.sh