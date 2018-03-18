#!/bin/bash
# LinuxGSM command_monitor.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Monitors server by checking for running processes.
# then passes to monitor_gsquery.sh.

local commandname="MONITOR"
local commandaction="Monitor"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_monitor_check_lockfile(){
	# Monitor does not run it lockfile is not found
	if [ ! -f "${rootdir}/${lockselfname}" ]; then
		fn_print_error_nl "Disabled: No lockfile found"
		fn_script_log_error "Disabled: No lockfile found"
		echo "	* To enable monitor run ./${selfname} start"
		core_exit.sh
	fi
}

fn_monitor_check_update(){
	# Monitor will not check if update is running.
	if [ "$(ps -ef|grep "${selfname} update"|grep -v grep|wc -l)" != "0" ]; then
		fn_print_error_nl "SteamCMD is currently checking for updates"
		fn_script_log_error "SteamCMD is currently checking for updates"
		sleep 1
		core_exit.sh
	fi
}

fn_monitor_msg_checking(){
	fn_print_dots "Checking session: "
	fn_print_checking_eol
	fn_script_log_info "Checking session: CHECKING"
	sleep 1
}

fn_monitor_teamspeak3(){
	if [ "${status}" != "0" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Checking session: OK"
	else
		fn_print_error "Checking session: ${ts3error}: "
		fn_print_fail_eol_nl
		fn_script_log_error "Checking session: ${ts3error}: FAIL"
		failurereason="${ts3error}"
		alert="restart"
		alert.sh
		fn_script_log_info "Monitor is starting ${servername}"
		sleep 1
		command_restart.sh
	fi
}

fn_monitor_mumble(){
	if [ "${status}" != "0" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Checking session: OK"
	else
		fn_print_error "Checking session: Not listening to port ${port}"
		fn_print_fail_eol_nl
		fn_script_log_error "Checking session: Not listening to port ${port}"
		failurereason="Checking session: Not listening to port ${port}"
		alert="restart"
		alert.sh
		fn_script_log_info "Monitor is starting ${servername}"
		sleep 1
		command_restart.sh
	fi
}
fn_monitor_tmux(){
	# checks that tmux session is running
	if [ "${status}" != "0" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Checking session: OK"
		# runs gsquery check on game with specific engines.
		local allowed_engines_array=( avalanche2.0 avalanche3.0 goldsource idtech2 idtech3 idtech3_ql iw2.0 iw3.0 madness quake refractor realvirtuality source spark starbound unity3d unreal unreal2 unreal4 )
		for allowed_engine in "${allowed_engines_array[@]}"
		do
			if [ "${allowed_engine}" == "starbound" ]; then
				info_config.sh
				if [ "${queryenabled}" == "true" ]; then
					monitor_gsquery.sh
				fi
			elif [ "${allowed_engine}" == "${engine}" ]; then
				monitor_gsquery.sh
			fi
		done
	else
		fn_print_error "Checking session: "
		fn_print_fail_eol_nl
		fn_script_log_error "Checking session: FAIL"
		alert="restart"
		alert.sh
		fn_script_log_info "Monitor is starting ${servername}"
		sleep 1
		command_restart.sh
	fi
}

monitorflag=1
fn_print_dots "${servername}"
sleep 1
check.sh
logs.sh
info_config.sh

fn_monitor_check_lockfile
fn_monitor_check_update
fn_monitor_msg_checking
if [ "${gamename}" == "TeamSpeak 3" ]; then
	fn_monitor_teamspeak3
elif [ "${gamename}" == "Mumble" ]; then
	fn_monitor_mumble
else
	fn_monitor_tmux
fi
core_exit.sh
