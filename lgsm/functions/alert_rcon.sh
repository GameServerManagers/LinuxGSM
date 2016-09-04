#!/bin/bash
# LGSM command_stop.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="050616"

# Description: Different countdown's for the server.

local modulename="countdowns"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
command_execute.sh


alert_shutdown(){
	# checks if the server is already stopped before trying to stop.

	check_status.sh
		if [ "${status}" == "0" ]; then
	fn_print_ok_nl "${servername} is already stopped"
	fn_scriptlog "${servername} is already stopped"
		exit
	fi

COUNTDOWN_TYPE=SHUTDOWN

		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in 1 minute!"
		sleep 30
		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in 30 seconds!"
		sleep 20

	for SECONDS in 10 9 8 7 6 5 4 3 2 1
	do
		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in $SECONDS seconds!"
		sleep 1
	done
command_stop.sh
}

alert_restart(){
	# checks if the server is already stopped before trying to stop.

	check_status.sh
		if [ "${status}" == "0" ]; then
	fn_print_ok_nl "${servername} is already stopped"
	fn_scriptlog "${servername} is already stopped"
		exit
	fi
	
COUNTDOWN_TYPE=RESTART

		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in 1 minute!"
		sleep 30
		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in 30 seconds!"
		sleep 20

	for SECONDS in 10 9 8 7 6 5 4 3 2 1
	do
		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in $SECONDS seconds!"
		sleep 1
	done
fn_restart
}


alert_update(){
	# checks if the server is already stopped before trying to stop.

	check_status.sh
		if [ "${status}" == "0" ]; then
	fn_print_ok_nl "${servername} is already stopped"
	fn_scriptlog "${servername} is already stopped"
	update_check.sh
		exit
	fi

COUNTDOWN_TYPE=UPDATE

		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in 1 minute!"
		sleep 30
		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in 30 seconds!"
		sleep 20

	for SECONDS in 10 9 8 7 6 5 4 3 2 1
	do
		execute "${msg_type} WARNING!!! SERVER $COUNTDOWN_TYPE in $SECONDS seconds!"
		sleep 1
	done
	update_check.sh
}
