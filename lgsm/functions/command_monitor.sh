#!/bin/bash
# LinuxGSM command_monitor.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Monitors server by checking for running processes
# then passes to gamedig and gsquery.

fn_monitor_check_lockfile(){
	# Monitor does not run it lockfile is not found.
	if [ ! -f "${rootdir}/${lockselfname}" ]; then
		fn_print_error_nl "Disabled: No lockfile found"
		fn_script_log_error "Disabled: No lockfile found"
		echo -e "	* To enable monitor run ./${selfname} start"
		core_exit.sh
	fi

	# Fix if lockfile is not unix time or contains letters
	if [[ "$(cat "${rootdir}/${lockselfname}")" =~ [A-Za-z] ]]; then
			date '+%s' > "${rootdir}/${lockselfname}"
	fi
}

fn_monitor_check_update(){
	# Monitor will check if update is already running.
	if [ "$(pgrep "${selfname} update" | wc -l)" != "0" ]; then
		fn_print_error_nl "SteamCMD is currently checking for updates"
		fn_script_log_error "SteamCMD is currently checking for updates"
		core_exit.sh
	fi
}

fn_monitor_check_session(){
	fn_print_dots "Checking session: "
	fn_print_checking_eol
	fn_script_log_info "Checking session: CHECKING"
	fn_sleep_time
	# uses status var from check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Checking session: OK"
		fn_sleep_time
	else
		if [ "${shortname}" == "ts3" ]; then
			fn_print_error "Checking session: ${ts3error}: "
		elif [ "${shortname}" == "mumble" ]; then
			fn_print_error "Checking session: Not listening to port ${queryport}"
		else
			fn_print_error "Checking session: "
		fi
		fn_print_fail_eol_nl
		fn_script_log_error "Checking session: FAIL"
		fn_sleep_time
		alert="restart"
		alert.sh
		fn_script_log_info "Monitor is starting ${servername}"
		command_restart.sh
		core_exit.sh
	fi
}

fn_query_gsquery(){
	if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
		fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
	fi
	"${functionsdir}"/query_gsquery.py -a "${ip}" -p "${queryport}" -e "${querytype}" > /dev/null 2>&1
	querystatus="$?"
}

fn_query_tcp(){
	bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}'' > /dev/null 2>&1
	querystatus="$?"
}

fn_monitor_query(){
# Will loop and query up to 5 times every 15 seconds.
# Query will wait up to 60 seconds to confirm server is down as server can become non-responsive during map changes.
totalseconds=0
for queryattempt in {1..5}; do
	fn_print_dots "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
	fn_print_querying_eol
	fn_script_log_info "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt} : QUERYING"
	fn_sleep_time
	# querydelay
	if [ "$(cat "${rootdir}/${lockselfname}")" -gt "$(date "+%s" -d "${querydelay} mins ago")" ]; then
		fn_print_ok "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
		fn_print_delay_eol_nl
		fn_script_log_info "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt} : DELAY"
		fn_script_log_info "Query bypassed: ${gameservername} started less than ${querydelay} minute ago"
		fn_sleep_time
		monitorpass=1
		core_exit.sh
	# will use query method selected in fn_monitor_loop
	# gamedig
	elif [ "${querymethod}" ==  "gamedig" ]; then
		query_gamedig.sh
		if [ "${querystatus}" == "0" ]; then
      # Add query data to log.
			if [ -n "${gdname}" ]; then
				fn_script_log_info "Server name: ${gdname}"
			fi
			if [ -n "${gdplayers}" ]; then
				fn_script_log_info "Players: ${gdplayers}/${gdmaxplayers}"
			fi
			if [ -n "${gdmap}" ]; then
				fn_script_log_info "Map: ${gdmap}"
			fi
			if [ -n "${gdgamemode}" ]; then
				fn_script_log_info "Game Mode: ${gdgamemode}"
			fi
		fi
	# gsquery
	elif [ "${querymethod}" ==  "gsquery" ]; then
		fn_query_gsquery
	#tcp query
	elif [ "${querymethod}" ==  "tcp" ]; then
		fn_query_tcp
	fi

	if [ "${querystatus}" == "0" ]; then
		# Server query OK.
		fn_print_ok "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt}: OK"
		monitorpass=1
		# send LinuxGSM stats if monitor is OK.
		if [ "${stats}" == "on" ]; then
			info_stats.sh
		fi
		core_exit.sh
	else
		# Server query FAIL.
		fn_script_log_info "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt}: FAIL"
		fn_print_fail "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
		fn_print_fail_eol
		# Monitor will try gamedig (if supported) for first 30s then gsquery before restarting.
		if [ "${querymethod}" ==  "gsquery" ]||[ "${querymethod}" ==  "tcp" ]; then
			# gsquery will fail if longer than 60s
			if [ "${totalseconds}" -ge "59" ]; then
				# Monitor will FAIL if over 60s and trigger gane server reboot.
				fn_print_fail "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
				fn_print_fail_eol_nl
				fn_script_log_error "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt}: FAIL"

				# Send alert if enabled.
				alert="restartquery"
				alert.sh
				command_restart.sh
				core_exit.sh
			fi
		elif [ "${querymethod}" ==  "gamedig" ]; then
			# gamedig will fail and try gsquery if longer than 30s
			if [ "${totalseconds}" -ge "29" ]; then
				break
			fi
		fi

		# Second counter will wait for 15s before breaking loop.
		for seconds in {1..15}; do
			fn_print_fail "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: WAIT"
			totalseconds=$((totalseconds + 1))
			if [ "${seconds}" == "15" ]; then
				break
			fi
		done
	fi
done
}

fn_monitor_loop(){
	# loop though query methods selected by querymode.
	totalseconds=0
	if [ "${querymode}" == "2" ]; then
		local query_methods_array=( gamedig gsquery )
	elif [ "${querymode}" == "3" ]; then
		local query_methods_array=( gamedig )
	elif [ "${querymode}" == "4" ]; then
			local query_methods_array=( gsquery )
	elif [ "${querymode}" == "5" ]; then
		local query_methods_array=( tcp )
	fi
	for querymethod in "${query_methods_array[@]}"
	do
		# Will check if gamedig is installed and bypass if not.
		if [ "${querymethod}" == "gamedig" ]; then
			if [ "$(command -v gamedig 2>/dev/null)" ]&&[ "$(command -v jq 2>/dev/null)" ]; then
				if [ -z "${monitorpass}" ]; then
					fn_monitor_query
				fi
			else
				fn_script_log_info "gamedig is not installed"
				fn_script_log_info "https://docs.linuxgsm.com/requirements/gamedig"
			fi
		else
			# will not query if query already passed.
			if [ -z "${monitorpass}" ]; then
				fn_monitor_query
			fi
		fi
	done
}

monitorflag=1
check.sh
logs.sh
info_config.sh
info_parms.sh

# query pre-checks
fn_monitor_check_lockfile
fn_monitor_check_update
fn_monitor_check_session

# Add a querydelay of 1 min if var missing.
if [ -z "${querydelay}" ]; then
	querydelay="1"
fi

fn_monitor_loop
