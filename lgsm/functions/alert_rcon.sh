#!/bin/bash
# LGSM command_stop.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="050616"

# Description: Different countdown's for the server.

local modulename="countdown"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
command_execute.sh


countdown()
{
		execute "say WARNING!!! SERVER $COUNTDOWN_TYPE in 1 minute!"
		sleep 30
		execute "say WARNING!!! SERVER $COUNTDOWN_TYPE in 30 seconds!"
		sleep 20

	for SECONDS in 10 9 8 7 6 5 4 3 2 1
	do
		execute "say WARNING!!! SERVER $COUNTDOWN_TYPE in $SECONDS seconds!"
		sleep 1
	done
}

execute()
{
	TMUX_BIN=tmux
	$TMUX_BIN send -t ${servicename} "$*" "enter"
	echo "Command executed: '$*'"
}
