#!/bin/bash
# LinuxGSM command_monitor.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Monitors server by checking for running processes.
# then passes to gamedig and gsquery.

local commandname="MONITOR"
local commandaction="Monitor"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_monitor_loop(){
# Will query up to 5 times every 15 seconds.
# Query will wait up to 60 seconds to confirm server is down giving server time if changing map.
for queryattempt in {1..5}; do
	fn_print_dots "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
	fn_print_querying_eol
	fn_script_log_info "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt} : QUERYING"
	sleep 0.5
	if [ "${querymethod}" ==  "gamedig" ]; then
		query_gamedig.sh
	elif [ "${querymethod}" ==  "gsquery" ]; then
		if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
			fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
		fi
		"${functionsdir}"/query_gsquery.py -a "${ip}" -p "${queryport}" -e "${engine}" > /dev/null 2>&1
		querystatus="$?"
	elif [ "${querymethod}" ==  "telnet" ]; then
		bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}''
		querystatus="$?"
	fi

	if [ "${querystatus}" == "0" ]; then
		# Server query OK
		sleep 0.5
		fn_print_ok "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt}: OK"
		exitcode=0
		monitorpass=1
		core_exit.sh
	else
		# Server query FAIL
		fn_script_log_info "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt}: FAIL"
		fn_print_fail "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
		fn_print_fail_eol
		sleep 0.5
		# monitor try gamedig first then gsquery before restarting
		if [ "${querymethod}" ==  "gsquery" ]; then
			if [ "${totalseconds}" -ge "59" ]; then
				# Server query FAIL for over 59 seconds reboot server
				fn_print_fail "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
				fn_print_fail_eol_nl
				fn_script_log_error "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt}: FAIL"
				sleep 0.5

				# Send alert if enabled
				alert="restartquery"
				alert.sh
				command_restart.sh
				core_exit.sh
			fi
		elif [ "${querymethod}" ==  "gamedig" ]; then
			if [ "${totalseconds}" -ge "29" ]; then
				break
			fi
		fi

		# Seconds counter
		for seconds in {1..15}; do
			fn_print_fail "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: WAIT"
			totalseconds=$((totalseconds + 1))
			sleep 1
			if [ "${seconds}" == "15" ]; then
				break
			fi
		done
	fi
done
}

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
	if [ "$(ps -ef | grep "${selfname} update" | grep -v grep | wc -l)" != "0" ]; then
		fn_print_error_nl "SteamCMD is currently checking for updates"
		fn_script_log_error "SteamCMD is currently checking for updates"
		sleep 0.5
		core_exit.sh
	fi
}

fn_monitor_check_session(){
	fn_print_dots "Checking session: "
	fn_print_checking_eol
	fn_script_log_info "Checking session: CHECKING"
	sleep 0.5
	if [ "${status}" != "0" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Checking session: OK"
	else
		if [ "${gamename}" == "TeamSpeak 3" ]; then
			fn_print_error "Checking session: ${ts3error}: "
		elif [ "${gamename}" == "Mumble" ]; then
			fn_print_error "Checking session: Not listening to port ${queryport}"
		else
			fn_print_error "Checking session: "
		fi
		fn_print_fail_eol_nl
		fn_script_log_error "Checking session: FAIL"
		alert="restart"
		alert.sh
		fn_script_log_info "Monitor is starting ${servername}"
		sleep 0.5
		command_restart.sh
	fi
	sleep 0.5
}

fn_monitor_query(){
	fn_script_log_info "Querying port: query enabled"
	# engines that work with query
	local allowed_engines_array=( avalanche2.0 avalanche3.0 goldsource idtech2 idtech3 idtech3_ql iw2.0 iw3.0 lwjgl2 madness quake refractor realvirtuality source spark starbound unity3d unreal unreal2 unreal4 wurm )
	for allowed_engine in "${allowed_engines_array[@]}"
	do
		if [ "${allowed_engine}" == "${engine}" ]; then
			if [ "${engine}" == "idtech3_ql" ]; then
				local engine="quakelive"
			elif [ "${gamename}" == "Killing Floor 2" ]; then
				local engine="unreal4"
			fi

			# will first attempt to use gamedig then gsquery
			totalseconds=0
			local query_methods_array=( gamedig gsquery )
			for query_method in "${query_methods_array[@]}"
			do
				if [ "${query_method}" == "gamedig" ]; then
					# will bypass gamedig if not installed
					if [ "$(command -v gamedig 2>/dev/null)" ]&&[ "$(command -v jq 2>/dev/null)" ]; then
						if [ -z "${monitorpass}" ]; then
							querymethod="${query_method}"
							fn_monitor_loop
						fi
					fi
				else
					if [ -z "${monitorpass}" ]; then
						querymethod="${query_method}"
						fn_monitor_loop
					fi
				fi
			done
		fi
	done
}

fn_monitor_query_telnet(){
	querymethod="telnet"
	fn_monitor_loop
}

monitorflag=1
fn_print_dots "${servername}"
sleep 0.5
check.sh
logs.sh
info_config.sh
info_parms.sh

fn_monitor_check_lockfile
fn_monitor_check_update
fn_monitor_check_session
# Query has to be enabled in Starbound config
if [ "${gamename}" == "Starbound" ]; then
	if [ "${queryenabled}" == "true" ]; then
		fn_monitor_query
	fi
elif [ "${gamename}" == "TeamSpeak 3" ]||[ "${gamename}" == "Eco" ]; then
	fn_monitor_query_telnet
else
	fn_monitor_query
fi

core_exit.sh