#!/bin/bash
# LinuxGSM command_monitor.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Monitors server by checking for running processes
# then passes to gamedig and gsquery.

commandname="MONITOR"
commandaction="Monitoring"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_monitor_check_lockfile(){
	# Monitor does not run it lockfile is not found.
	if [ ! -f "${lockdir}/${selfname}.lock" ]; then
		fn_print_dots "Checking lockfile: "
		fn_print_checking_eol
		fn_script_log_info "Checking lockfile: CHECKING"
		fn_print_error "Checking lockfile: No lockfile found: "
		fn_print_error_eol_nl
		fn_script_log_error "Checking lockfile: No lockfile found: ERROR"
		echo -e "* Start ${selfname} to run monitor."
		core_exit.sh
	fi

	# Fix if lockfile is not unix time or contains letters
	if [ -f "${lockdir}/${selfname}.lock" ]&&[[ "$(cat "${lockdir}/${selfname}.lock")" =~ [A-Za-z] ]]; then
			date '+%s' > "${lockdir}/${selfname}.lock"
	fi
}

fn_monitor_check_update(){
	# Monitor will check if update is already running.
	if [ "$(pgrep "${selfname} update" | wc -l)" != "0" ]; then
		fn_print_dots "Checking active updates: "
		fn_print_checking_eol
		fn_script_log_info "Checking active updates: CHECKING"
		fn_print_error_nl "Checking active updates: SteamCMD is currently checking for updates: "
		fn_print_error_eol
		fn_script_log_error "Checking active updates: SteamCMD is currently checking for updates: ERROR"
		core_exit.sh
	fi
}

fn_monitor_check_session(){
	fn_print_dots "Checking session: "
	fn_print_checking_eol
	fn_script_log_info "Checking session: CHECKING"
	# uses status var from check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_ok "Checking session: "
		fn_print_ok_eol_nl
		fn_script_log_pass "Checking session: OK"
	else
		fn_print_error "Checking session: "
		fn_print_fail_eol_nl
		fn_script_log_fatal "Checking session: FAIL"
		alert="restart"
		alert.sh
		fn_script_log_info "Checking session: Monitor is restarting ${selfname}"
		command_restart.sh
		core_exit.sh
	fi
}

fn_monitor_check_queryport(){
	# Monitor will check queryport is set before continuing.
	if [ -z "${queryport}" ]||[ "${queryport}" == "0" ]; then
		fn_print_dots "Checking port: "
		fn_print_checking_eol
		fn_script_log_info "Checking port: CHECKING"
		if [ -n "${rconenabled}" ]&&[ "${rconenabled}" != "true" ]&&[ ${shortname} == "av" ]; then
			fn_print_warn "Checking port: Unable to query, rcon is not enabled"
			fn_print_warn_eol_nl
			fn_script_log_warn "Checking port: Unable to query, rcon is not enabled"
		else
			fn_print_error "Checking port: Unable to query, queryport is not set"
			fn_script_log_error "Checking port: Unable to query, queryport is not set"
			fn_print_error_eol_nl
		fi
		core_exit.sh
	fi
}

fn_query_gsquery(){
	if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
		fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
	fi
	"${functionsdir}"/query_gsquery.py -a "${queryip}" -p "${queryport}" -e "${querytype}" > /dev/null 2>&1
	querystatus="$?"
}

fn_query_tcp(){
	bash -c 'exec 3<> /dev/tcp/'${queryip}'/'${queryport}'' > /dev/null 2>&1
	querystatus="$?"
}

fn_monitor_query(){
# Will loop and query up to 5 times every 15 seconds.
# Query will wait up to 60 seconds to confirm server is down as server can become non-responsive during map changes.
totalseconds=0
for queryattempt in {1..5}; do
	for queryip in "${queryips[@]}"; do
		fn_print_dots "Querying port: ${querymethod}: ${queryip}:${queryport} : ${totalseconds}/${queryattempt}: "
		fn_print_querying_eol
		fn_script_log_info "Querying port: ${querymethod}: ${queryip}:${queryport} : ${queryattempt} : QUERYING"
		# querydelay
		if [ "$(cat "${lockdir}/${selfname}.lock")" -gt "$(date "+%s" -d "${querydelay} mins ago")" ]; then
			fn_print_ok "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: "
			fn_print_delay_eol_nl
			fn_script_log_info "Querying port: ${querymethod}: ${ip}:${queryport} : ${queryattempt} : DELAY"
			fn_script_log_info "Query bypassed: ${gameservername} started less than ${querydelay} minutes ago"
			fn_script_log_info "Server started: $(date -d @$(cat "${lockdir}/${selfname}.lock"))"
			fn_script_log_info "Current time: $(date)"
			monitorpass=1
			core_exit.sh
		# will use query method selected in fn_monitor_loop
		# gamedig
		elif [ "${querymethod}" ==  "gamedig" ]; then
			query_gamedig.sh
		# gsquery
		elif [ "${querymethod}" ==  "gsquery" ]; then
			fn_query_gsquery
		#tcp query
		elif [ "${querymethod}" ==  "tcp" ]; then
			fn_query_tcp
		fi

		if [ "${querystatus}" == "0" ]; then
			# Server query OK.
			fn_print_ok "Querying port: ${querymethod}: ${queryip}:${queryport} : ${totalseconds}/${queryattempt}: "
			fn_print_ok_eol_nl
			fn_script_log_pass "Querying port: ${querymethod}: ${queryip}:${queryport} : ${queryattempt}: OK"
			monitorpass=1
			if [ "${querystatus}" == "0" ]; then
				# Add query data to log.
				if [ "${gdname}" ]; then
					fn_script_log_info "Server name: ${gdname}"
				fi
				if [ "${gdplayers}" ]; then
					fn_script_log_info "Players: ${gdplayers}/${gdmaxplayers}"
				fi
				if [ "${gdbots}" ]; then
					fn_script_log_info "Bots: ${gdbots}"
				fi
				if [ "${gdmap}" ]; then
					fn_script_log_info "Map: ${gdmap}"
				fi
				if [ "${gdgamemode}" ]; then
					fn_script_log_info "Game Mode: ${gdgamemode}"
				fi

				# send LinuxGSM stats if monitor is OK.
				if [ "${stats}" == "on" ]||[ "${stats}" == "y" ]; then
					info_stats.sh
				fi
			fi
			core_exit.sh
		else
			# Server query FAIL.
			fn_print_fail "Querying port: ${querymethod}: ${queryip}:${queryport} : ${totalseconds}/${queryattempt}: "
			fn_print_fail_eol
			fn_script_log_warn "Querying port: ${querymethod}: ${queryip}:${queryport} : ${queryattempt}: FAIL"
			# Monitor will try gamedig (if supported) for first 30s then gsquery before restarting.
			# gsquery will fail if longer than 60s
			if [ "${totalseconds}" -ge "59" ]; then
				# Monitor will FAIL if over 60s and trigger gane server reboot.
				fn_print_fail "Querying port: ${querymethod}: ${queryip}:${queryport} : ${totalseconds}/${queryattempt}: "
				fn_print_fail_eol_nl
				fn_script_log_warn "Querying port: ${querymethod}: ${queryip}:${queryport} : ${queryattempt}: FAIL"
				# Send alert if enabled.
				alert="restartquery"
				alert.sh
				command_restart.sh
				fn_firstcommand_reset
				core_exit.sh
			fi
		fi
	done
		# Second counter will wait for 15s before breaking loop.
		for seconds in {1..15}; do
			fn_print_fail "Querying port: ${querymethod}: ${ip}:${queryport} : ${totalseconds}/${queryattempt}: ${cyan}WAIT${default}"
			sleep 0.5
			totalseconds=$((totalseconds + 1))
			if [ "${seconds}" == "15" ]; then
				break
			fi
		done
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
	for querymethod in "${query_methods_array[@]}"; do
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
core_logs.sh
info_config.sh
info_parms.sh

# query pre-checks
fn_monitor_check_lockfile
fn_monitor_check_update
fn_monitor_check_session
# Monitor will not continue if session only check.
if [ "${querymode}" != "1" ]; then
	fn_monitor_check_queryport

	# Add a querydelay of 1 min if var missing.
	if [ -z "${querydelay}" ]; then
		querydelay="1"
	fi

	fn_monitor_loop
fi
core_exit.sh
