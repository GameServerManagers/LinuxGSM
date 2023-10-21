#!/bin/bash
# LinuxGSM command_monitor.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Monitors server by checking for running processes
# then passes to gamedig and gsquery.

commandname="MONITOR"
commandaction="Monitoring"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn__restart_server() {
	if [ -f "${lockdir}/${selfname}.lock" ]; then
		alert="${1:?}}"
		alert.sh
		(
			fn_print_info_nl "Restarting the server and skip immediate exit"
			exitbypass=1
			command_stop.sh
			command_start.sh
			echo "" # start doesn't always print newline
		)
		fn_firstcommand_reset
	else
		fn_print_warn_nl "Skipping server restart because lockfile is missing, probably server is restarted during monitor execution."
	fi
}

fn_monitor_check_lockfile() {
	fn_print_dots "Checking lockfile"

	# Monitor does not run if lockfile is not found.
	if [ ! -f "${lockdir}/${selfname}.lock" ]; then
		fn_print_fail_nl "Checking lockfile: No lockfile found"
		exitcode="3"
		core_exit.sh

	# Fix if lockfile is not unix time or contains letters
	elif [[ "$(head -n 1 "${lockdir}/${selfname}.lock")" =~ [A-Za-z] ]]; then
		fn_print_warn_nl "Checking lockfile: fixing illegal lockfile"
		date '+%s' > "${lockdir}/${selfname}.lock"
		echo "${version}" >> "${lockdir}/${selfname}.lock"
		echo "${port}" >> "${lockdir}/${selfname}.lock"
	else
		fn_print_ok_nl "Checking lockfile"
	fi
}

fn_monitor_check_update() {
	fn_print_dots "Checking active updates"

	# Monitor will check if update is already running.
	if [ "$(pgrep "${selfname} update" | wc -l)" != "0" ]; then
		fn_print_fail_nl "SteamCMD is currently checking for updates"
		exitcode="2"
		core_exit.sh
	else
		fn_print_ok_nl "Checking active updates"
	fi
}

fn_monitor_is_server_running() {
	fn_print_dots "Checking session"

	# uses status var from check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_ok_nl "Checking session"
		return 0
	else
		fn_print_error_nl "Checking session"
		return 1
	fi
}

fn_monitor_check_queryport() {
	# Monitor will check queryport is set before continuing.
	if [ -z "${queryport}" ] || [ "${queryport}" == "0" ]; then
		fn_print_dots "Checking port: "
		fn_print_checking_eol
		fn_script_log_info "Checking port: CHECKING"
		if [ -n "${rconenabled}" ] && [ "${rconenabled}" != "true" ] && [ "${shortname}" == "av" ]; then
			fn_print_warn "Checking port: Unable to query, rcon is not enabled"
			fn_script_log_warn "Checking port: Unable to query, rcon is not enabled"
		else
			fn_print_error "Checking port: Unable to query, queryport is not set"
			fn_script_log_error "Checking port: Unable to query, queryport is not set"
		fi
		core_exit.sh
	fi
	return 0
}

fn_query_gsquery() {
	if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
		fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nohash"
	fi
	"${functionsdir}"/query_gsquery.py -a "${queryip}" -p "${queryport}" -e "${querytype}" > /dev/null 2>&1
	querystatus="$?"
}

fn_query_tcp() {
	bash -c "exec 3<> '/dev/tcp/${queryip}/${queryport}'" > /dev/null 2>&1
	querystatus="$?"
}

fn_monitor_query() {
	local fail_after="60" # seconds
	local time_per_attempt="3"
	local max_attempts="5"
	local wait_between_attempts="$(( (fail_after-max_attempts*time_per_attempt) / (max_attempts-1) ))"

	# Will loop and query up to 5 times every 15 seconds.
	# Query will wait up to 60 seconds to confirm server is down as server can become non-responsive during map changes.
	for queryattempt in $(seq 1 "${max_attempts}" ); do

		for queryip in "${queryips[@]}"; do
			local log_msg="Starting to query in mode \"${querymethod}\" to target \"${queryip}:${queryport}\" attempt ${queryattempt} / ${max_attempts}"
			fn_print_dots "${log_msg}"

			# will use query method selected in fn_monitor_loop
			querystatus="100"
			if [ "${querymethod}" ==  "gamedig" ]; then
				query_gamedig.sh

			elif [ "${querymethod}" ==  "gsquery" ]; then
				fn_query_gsquery

			elif [ "${querymethod}" ==  "tcp" ]; then
				fn_query_tcp

			else
				fn_print_fail_nl "${log_msg} reason: unhandled query method \"${querymethod}\""
			fi

			# if serverquery is fine
			if [ "${querystatus}" == "0" ]; then
				fn_print_ok_nl "${log_msg}"

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

				return 0
			else
				fn_print_warn_nl "${log_msg} querystatus=\"${querystatus}\""
			fi
		done

		# monitoring attempt failed, show details to resolve the issue:
		if ! ss -tuplwn | grep -qFe ":${queryport} "; then
			fn_print_warn_nl "Port is not in use right now \"${queryport}\". Check command details for ports, use provided command to check if every port is used + console to validate server is booted. Maybe server didn't boot, e.g. a second port which is needed is already in use by another application or the configuration for the queryport is incorrect."
		else
			# return value of following lines arent used so not an issue
		    #shellcheck disable=SC2155
			local process_using_port="$( ss -tuplwn "( dport = :${queryport} or sport = :${queryport} )" | grep -o '[^ ]*$')"
			#shellcheck disable=SC2155
			local listen_on="$( ss -tuplwn "( dport = :${queryport} or sport = :${queryport} )" | grep -o "[^ ]*:${queryport} ")"

			local msg="Found application \"${process_using_port}\" which listens on \"${listen_on}\""
			if ! ss -tuplwn "( dport = :${queryport} or sport = :${queryport} )" | grep -qs '^[^ ]*\s*[^ ]*\s*0\s*'; then
				fn_print_warn_nl "$msg but Recv-Q isn't empty. Server didn't read the message we send, e.g. server is booting, has an issue which prevents correct initialization or the port is in use by another program."
			else
				fn_print_info_nl "$msg and Recv-Q is empty, the application read our send message but didn't answer as expected. Maybe \"${queryport}\" is not the querypot or incorrect query method (e.g. gamedig protocol) used?"
			fi
		fi

		# delay next init
		if [ "${queryattempt}" != "${max_attempts}" ]; then
			local explanation="e.g. maybe it failed because of server starting / map change / workshop download"
			fn_print_info "delayed next attempt for ${wait_between_attempts}s, $explanation"
			for i in $(seq 1 "${wait_between_attempts}"); do
				sleep 1s
				fn_print_info "delayed next attempt for $((wait_between_attempts - i))s, $explanation"
			done
			fn_print_info_nl "monitoring delayed for ${wait_between_attempts}s, $explanation"
		fi
	done
	return 1
}

fn_monitor_await_execution_time() {
	# Add a querydelay of 1 min if var missing.
	querydelay="${querydelay:-"1"}"

	last_execution="$(head -n 1 "${lockdir}/${selfname}.lock")"
	delay_seconds="$((querydelay * 60))"
	next_allowed_execution="$((last_execution + delay_seconds))"
	seconds_to_wait="$((next_allowed_execution - $(date '+%s')))"

	if [ "${seconds_to_wait}" -gt "0" ]; then
		fn_print_dots "monitoring delayed for ${seconds_to_wait}s"
		for i in $(seq "${seconds_to_wait}" -1 1); do
			sleep 1s
			fn_print_info "monitoring delayed for ${i}s"
		done
		fn_print_info_nl "monitoring delayed for ${seconds_to_wait}s"
	fi
}

fn_monitor_loop() {
	is_gamedig_installed="$( command -v gamedig 2>/dev/null 1>&2 && command -v jq 2>/dev/null 1>&2 && echo true || echo false )"

	# loop though query methods selected by querymode.
	if [ "${querymode}" == "2" ]; then
		local query_methods_array=(gamedig gsquery)
	elif [ "${querymode}" == "3" ]; then
		local query_methods_array=(gamedig)
	elif [ "${querymode}" == "4" ]; then
		local query_methods_array=( gsquery )
	elif [ "${querymode}" == "5" ]; then
		local query_methods_array=( tcp )
	else
		fn_print_fail_nl "monitoring function invoced but querymode has an illegal value ${querymode}"
		return 1
	fi

	for querymethod in "${query_methods_array[@]}"; do
		# Will check if gamedig is installed and bypass if not.
		if [ "${querymethod}" == "gamedig" ] && ! "${is_gamedig_installed}"; then
			fn_print_warn_nl "gamedig is not installed"
			fn_print_warn_nl "https://docs.linuxgsm.com/requirements/gamedig"
		elif fn_monitor_query; then
			fn_print_complete_nl "monitoring successful"
			return 0
		fi
	done
	return 1
}

monitorflag=1
check.sh
core_logs.sh
info_game.sh

# query pre-checks
fn_monitor_await_execution_time
fn_monitor_check_lockfile
fn_monitor_check_update
check_only_if_running="$([ "${querymode}" == "1" ] && echo true || echo false )"

exitcode="1" # if not altered below, coding error => FATAL
if ! fn_monitor_is_server_running; then
	fn__restart_server "restart"
	exitcode="3"

# if monitor should only check only session
elif "${check_only_if_running}"; then
	exitcode="0"

elif ! fn_monitor_is_queryport_valid; then
	exitcode="2" # error because maybe unfixable
	# no restart because config issue !

# server could be queried with tcp / gsquery / gamedig
elif fn_monitor_loop; then
	exitcode="0"

else
	fn__restart_server "restartquery"
	exitcode="3"
fi

core_exit.sh
