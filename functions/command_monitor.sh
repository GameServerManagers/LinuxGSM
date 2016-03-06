#!/bin/bash
# LGSM command_monitor.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Monitors server by checking for running proccesses
# then passes to monitor_gsquery.sh.

local modulename="Monitor"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_monitor_check_lockfile(){
	# Monitor does not run it lockfile is not found
	if [ ! -f "${rootdir}/${lockselfname}" ]; then
		fn_print_info_nl "Disabled: No lock file found"
		fn_scriptlog "Disabled: No lock file found"
		echo "	* To enable monitor run ./${selfname} start"
		exit 1
	fi
}

fn_monitor_check_update(){
	# Monitor will not check if update is running.
	updatecheck=$(ps -ef|grep "${selfname} update"|grep -v grep|wc -l)
	if [ "${updatecheck}" >= "1" ]; then
		fn_print_info_nl "SteamCMD is currently checking for updates"
		fn_scriptlog "SteamCMD is currently checking for updates"
		sleep 1
		exit
	fi
}

fn_monitor_msg_checking(){
	fn_print_dots "Checking session: "
	fn_print_checking_eol
	fn_scriptlog "Checking session: CHECKING"
	sleep 1	
}

fn_monitor_email_notification(){
	# Email will be sent if enabled
	if [ "${emailnotification}" = "on" ]; then
		subject="${servicename} Monitor - Starting ${servername}"
		failurereason="${servicename} process not running"
		actiontaken="${servicename} has been restarted"
		email.sh
	fi	
}

fn_monitor_teamspeak3(){
	info_ts3status.sh
	if [ "${ts3status}" = "Server is running" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_scriptlog "Checking session: OK"
		exit
	else
		fn_print_fail "Checking session: ${ts3status}: "
		fn_print_fail_eol_nl
		fn_scriptlog "Checking session: ${ts3status}: FAIL"
		failurereason="${ts3status}"
		fn_monitor_email_notification
	fi
	fn_scriptlog "Monitor is starting ${servername}"
	sleep 1
	fn_restart
}

fn_monitor_tmux(){
	# checks that tmux session is running
	tmuxwc=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -Ec "^${servicename}:")
	if [ "${tmuxwc}" == "1" ]; then
		fn_print_ok "Checking session: OK"
		fn_print_ok_eol_nl
		fn_scriptlog "Checking session: OK"
		# runs gsquery check on game with specific engines.
		local allowed_engines_array=( avalanche goldsource realvirtuality source spark unity3d unreal unreal2 )
		for allowed_engine in "${allowed_engines_array[@]}"
		do
			if [ "${allowed_engine}" == "${function_selfname}" ]; then
				monitor_gsquery.sh
			fi
		done
		exit
	else
		fn_print_fail "Checking session: "
		fn_print_fail_eol_nl
		fn_scriptlog "Checking session: FAIL"
		fn_monitor_email_notification
		fn_scriptlog "Monitor is starting ${servername}"
		sleep 1
		command_start.sh
	fi
}

check.sh
logs.sh
info_config.sh
fn_print_dots "${servername}"
fn_scriptlog "${servername}"
sleep 1
fn_monitor_check_lockfile
fn_monitor_check_update
fn_monitor_msg_checking
if [ "${gamename}" == "Teamspeak 3" ]; then
	fn_monitor_teamspeak3
else
	fn_monitor_tmux
fi