#!/bin/bash
# LGSM command_monitor.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Monitors server by checking for running proccesses
# then passes to monitor_gsquery.sh.

local modulename="Monitor"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_monitor_teamspeak3(){
check.sh
logs.sh
fn_printdots "${servername}"
fn_scriptlog "${servername}"
sleep 1
if [ ! -f "${rootdir}/${lockselfname}" ]; then
	fn_printinfo "Disabled: No lock file found"
	fn_scriptlog "Disabled: No lock file found"
	sleep 1
	echo -en "\n"
	echo "To enable monitor run ./${selfname} start"
	exit 1
fi
fn_printdots "Checking session: CHECKING"
fn_scriptlog "Checking session: CHECKING"
sleep 1
info_ts3status.sh
if [ "${ts3status}" = "Server is running" ]; then
	fn_printok "Checking session: OK"
	fn_scriptlog "Checking session: OK"
	sleep 1
	sleep 0.5
	echo -en "\n"
	exit
else
	fn_printfail "Checking session: FAIL"
	fn_scriptlog "Checking session: FAIL"
	sleep 1
	fn_printfail "Checking session: FAIL: ${ts3status}"
	fn_scriptlog "Checking session: FAIL: ${ts3status}"
	failurereason="${ts3status}"
	if [ "${emailnotification}" = "on" ]; then
		subject="${servicename} Monitor - Restarting ${servername}"
		actiontaken="restarted ${servername}"
		email.sh
	fi
fi
sleep 0.5
echo -en "\n"
fn_restart
}

fn_monitor_tmux(){
check.sh
info_config.sh
fn_printdots "${servername}"
fn_scriptlog "${servername}"
sleep 1
if [ ! -f "${rootdir}/${lockselfname}" ]; then
	fn_printinfo "Disabled: No lock file found"
	fn_scriptlog "Disabled: No lock file found"
	sleep 1
	echo -en "\n"
	echo "To enable monitor run ./${selfname} start"
	exit 1
fi

updatecheck=$(ps -ef|grep "${selfname} update"|grep -v grep|wc -l)
if [ "${updatecheck}" = "0" ]||[ "${gamename}" == "Unreal Tournament 99" ]||[ "${gamename}" == "Unreal Tournament 2004" ]; then
	fn_printdots "Checking session: CHECKING"
	fn_scriptlog "Checking session: CHECKING"
	sleep 1
	tmuxwc=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -v failed|grep -Ec "^${servicename}:")
	if [ "${tmuxwc}" -eq 1 ]; then
		fn_printok "Checking session: OK"
		fn_scriptlog "Checking session: OK"
		sleep 1
		echo -en "\n"

		if [ "${engine}" == "avalanche" ]||[ "${engine}" == "goldsource" ]||[ "${engine}" == "idtech3" ]||[ "${engine}" == "realvirtuality" ]||[ "${engine}" == "source" ]||[ "${engine}" == "spark" ]||[ "${engine}" == "unity3d" ]||[ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
			monitor_gsquery.sh
		fi
		exit $?
	else
		fn_printfail "Checking session: FAIL"
		fn_scriptlog "Checking session: FAIL"
		sleep 1
		echo -en "\n"
		if [ "${emailnotification}" = "on" ]; then
			subject="${servicename} Monitor - Starting ${servername}"
			failurereason="${servicename} process not running"
			actiontaken="${servicename} has been restarted"
			email.sh
		fi
		fn_scriptlog "Monitor is starting ${servername}"
		command_start.sh
	fi
else
	fn_printinfonl "SteamCMD is currently checking for updates"
	fn_scriptlog "SteamCMD is currently checking for updates"
	sleep 1
	fn_printinfonl "When update is complete ${servicename} will start"
	fn_scriptlog "When update is complete ${servicename} will start"
	sleep 1
fi
}

if [ "${gamename}" == "Teamspeak 3" ]; then
	fn_monitor_teamspeak3
else
	fn_monitor_tmux
fi
