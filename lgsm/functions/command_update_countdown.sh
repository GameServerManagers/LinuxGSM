#!/bin/bash
# LGSM command_update_countdown.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Updates's the server with countdown

local modulename="Updating"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"


check.sh
command_execute.sh


update_countdown_timer(){
	
COUNTDOWN_TYPE=UPDATE

	if [ "$1" != "fast" ]
	then
		execute "say WARNING!!! SERVER $COUNTDOWN_TYPE in 1 minute!"
		sleep 30
		execute "say WARNING!!! SERVER $COUNTDOWN_TYPE in 30 seconds!"
		sleep 20
	fi

	for SECONDS in 10 9 8 7 6 5 4 3 2 1
	do
		execute "say WARNING!!! SERVER $COUNTDOWN_TYPE in $SECONDS seconds!"
		sleep 1
	done
	forceupdate=1;
	update_check.sh
}