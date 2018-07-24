#!/bin/bash
# LinuxGSM command_update.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating of servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_print_dots ""
sleep 0.5
check.sh
logs.sh

if [ "${gamename}" == "TeamSpeak 3" ]; then
	update_ts3.sh
elif [ "${engine}" == "lwjgl2" ]; then
	update_minecraft.sh
elif [ "${gamename}" == "Mumble" ]; then
	update_mumble.sh
elif [ "${gamename}" == "Factorio" ]; then
	update_factorio.sh
elif [ "${gamename}" == "Multi Theft Auto" ]; then
	update_mta.sh
else
	update_steamcmd.sh
fi

core_exit.sh
