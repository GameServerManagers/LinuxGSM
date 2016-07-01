#!/bin/bash
# LGSM commanf_update.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description:Hangles updating of servers.

check.sh

fn_print_dots "Checking for update"
if [ "${gamename}" == "Teamspeak 3" ]; then
	update_ts3.sh
elif [ "${engine}" == "goldsource" ]||[ "${forceupdate}" == "1" ]; then
	update_steamcmd.sh
fi

core_exit.sh