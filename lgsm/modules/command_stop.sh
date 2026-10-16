#!/bin/bash
# LinuxGSM command_stop.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Stops the server.

commandname="STOP"
commandaction="Stopping"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

# Only stop the server if there are no players online.
# An explicit stop or restart always respects players when the feature is on.
# Other commands that stop the server as a side effect (e.g. update) only respect
# players when stoponlyifnoplayersallcommands is on.
fn_stop_players_online() {
	if [ "${firstcommandname}" == "STOP" ] || [ "${firstcommandname}" == "RESTART" ] || [ "${stoponlyifnoplayersallcommands}" == "on" ]; then
		check_players_online.sh
		if [ -n "${playersonline}" ]; then
			fn_print_info_nl "${playersonline} players are on the server: stop prevented"
			fn_script_log_info "${playersonline} players are on the server: stop prevented"
			echo "${playersonline}" > "${lockdir:?}/${selfname}-player-numbers.lock"
			# Monitor runs the update once the server is empty.
			if [ "${firstcommandname}" == "UPDATE" ]; then
				date '+%s' > "${lockdir:?}/${selfname}-update-request.lock"
				if [ "${forceupdate}" == "1" ]; then
					echo "force" >> "${lockdir:?}/${selfname}-update-request.lock"
				fi
				fn_print_info_nl "Update postponed until the server is empty"
				fn_script_log_info "Update postponed until the server is empty"
			elif [ "${firstcommandname}" == "BACKUP" ]; then
				if [ ! -f "${lockdir}/${selfname}-backup-request.lock" ]; then
					date '+%s' > "${lockdir:?}/${selfname}-backup-request.lock"
				fi
				fn_print_info_nl "Backup postponed until the server is empty"
				fn_script_log_info "Backup postponed until the server is empty"
			fi
			fn_stop_cancel_locks
			# Exit the whole command, including when called by another command (e.g. update) with exitbypass.
			unset exitbypass
			core_exit.sh
		fi
	fi
}

# Removes the lockfiles of the command that called stop when it ends without stopping the server.
fn_stop_cancel_locks() {
	if [ "${firstcommandname}" == "UPDATE" ] || [ "${firstcommandname}" == "WORKSHOP-UPDATE" ]; then
		rm -f "${lockdir:?}/update.lock" "${lockdir:?}/last-updated.lock"
	elif [ "${firstcommandname}" == "VALIDATE" ]; then
		rm -f "${lockdir:?}/update.lock"
	elif [ "${firstcommandname}" == "BACKUP" ]; then
		rm -f "${lockdir:?}/backup.lock"
	fi
}

# Tells players a warning countdown was cancelled, used when CTRL-C is pressed.
fn_stop_warn_players_cancel() {
	if [ "$(cat "${lockdir}/${selfname}-warning.lock" 2> /dev/null)" == "$$" ]; then
		fn_stop_warn_players_send "${warnplayersaction}" "0"
		rm -f "${lockdir:?}/${selfname}-warning.lock"
		fn_stop_cancel_locks
	fi
}

# Sets the game's chat command used to warn players, %s is replaced by the message.
fn_stop_warn_players_command() {
	warncommand=""
	if [ "${shortname}" == "pz" ]; then
		warncommand='servermsg "%s"'
	elif [ "${shortname}" == "dst" ]; then
		warncommand='c_announce("%s")'
	elif [ "${shortname}" == "scpsl" ]; then
		warncommand="/bc 10 %s"
	elif [ "${shortname}" == "vints" ]; then
		warncommand="/announce %s"
	elif [ "${shortname}" == "wmc" ]; then
		warncommand="alert %s"
	elif [ "${shortname}" == "av" ]; then
		warncommand="/say %s"
	elif [ "${shortname}" == "fctr" ]; then
		warncommand="%s"
	elif [ "${engine}" == "source" ] || [ "${engine}" == "source2" ] || [ "${engine}" == "goldsrc" ]; then
		warncommand="say %s"
	else
		local saygames=(bt cod cod2 cod4 coduo codwaw ct etl hyt jk2 mc mcb mohaa mta nec pmc q2 q3 q4 ql qw rtcw rw sof2 terraria unt wet wf xnt)
		local game
		for game in "${saygames[@]}"; do
			if [ "${shortname}" == "${game}" ]; then
				warncommand="say %s"
			fi
		done
	fi
}

# Sends a warning message to players using the game's own chat command.
# A minutes value of 0 sends a cancelled message.
fn_stop_warn_players_send() {
	local message="Server ${1} in ${2} minute"
	if [ "${2}" != "1" ]; then
		message+="s"
	fi
	if [ "${2}" == "0" ]; then
		message="Server ${1} cancelled"
	fi
	local warnmessage="${warncommand//%s/${message}}"
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" -l "${warnmessage}" > /dev/null 2>&1
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" ENTER > /dev/null 2>&1
}

# Waits for another LinuxGSM command that is already warning players on this server.
fn_stop_warn_players_wait() {
	local warnlock="${lockdir}/${selfname}-warning.lock"
	local warnpid
	while [ -f "${warnlock}" ]; do
		warnpid="$(cat "${warnlock}" 2> /dev/null)"
		if [ -z "${warnpid}" ] || ! kill -0 "${warnpid}" 2> /dev/null; then
			rm -f "${warnlock:?}"
			break
		fi
		fn_print_info_nl "Warning players: another command is already warning players: waiting"
		fn_script_log_info "Warning players: another command is already warning players: waiting"
		sleep 30
	done
}

# Counts down to the stop with in-game warnings, e.g. warnplayerstimer="15" warns at 15, 10, 5, 3 and 1 minutes.
# Skipped when the server is empty, and ends early if the server empties during the countdown.
fn_stop_warn_players() {
	if [ "${firstcommandname}" == "STOP" ]; then
		warnplayersaction="stopping"
	elif [ "${firstcommandname}" == "RESTART" ] || [ "${firstcommandname}" == "BACKUP" ]; then
		warnplayersaction="restarting"
	elif [ "${firstcommandname}" == "UPDATE" ] || [ "${firstcommandname}" == "WORKSHOP-UPDATE" ]; then
		warnplayersaction="updating"
	else
		return
	fi
	if [ -z "${warnplayerstimer}" ] || [ "${forceupdate}" == "1" ]; then
		return
	fi
	if ! [[ "${warnplayerstimer}" =~ ^[0-9]+$ ]]; then
		fn_print_warn_nl "Warning players: warnplayerstimer must be a number of minutes: skipped"
		fn_script_log_warn "Warning players: warnplayerstimer \"${warnplayerstimer}\" is not a number of minutes: skipped"
		return
	fi
	local timer="$((10#${warnplayerstimer}))"
	if [ "${timer}" -eq 0 ]; then
		return
	fi
	fn_stop_warn_players_command
	if [ "${consoleinteract}" != "yes" ] || [ -z "${warncommand}" ]; then
		fn_print_info_nl "Warning players: not supported by ${gamename}: skipped"
		fn_script_log_info "Warning players: not supported by ${gamename}: skipped"
		return
	fi

	fn_stop_warn_players_wait
	check_status.sh
	if [ "${status}" == "0" ]; then
		return
	fi

	local steps=("${timer}")
	local step
	for step in 60 30 15 10 5 3 1; do
		if [ "${step}" -lt "${timer}" ]; then
			steps+=("${step}")
		fi
	done

	echo "$$" > "${lockdir:?}/${selfname}-warning.lock"
	local i next
	for i in "${!steps[@]}"; do
		check_status.sh
		if [ "${status}" == "0" ]; then
			break
		fi
		# shellcheck disable=SC2034 # Used by check_players_online.sh.
		playercheckforce=1
		check_players_online.sh
		unset playercheckforce
		if [ "${playerscounted}" == "1" ] && [ -z "${playersonline}" ]; then
			fn_print_info_nl "Warning players: no players on the server"
			fn_script_log_info "Warning players: no players on the server"
			break
		fi
		if [ "${i}" == "0" ] && [ -n "${playercountunavailable}" ]; then
			fn_print_info_nl "Warning players: unable to check for players (${playercountunavailable}): warning anyway"
			fn_script_log_info "Warning players: unable to check for players (${playercountunavailable}): warning anyway"
		fi
		fn_stop_warn_players_send "${warnplayersaction}" "${steps[i]}"
		fn_print_info_nl "Warning players: ${warnplayersaction} in ${steps[i]} minute(s)"
		fn_script_log_info "Warning players: ${warnplayersaction} in ${steps[i]} minute(s)"
		next="${steps[i + 1]:-0}"
		local waitseconds=$(((steps[i] - next) * 60))
		while [ "${waitseconds}" -gt 0 ]; do
			sleep 10
			waitseconds=$((waitseconds - 10))
			check_status.sh
			if [ "${status}" == "0" ]; then
				break 2
			fi
		done
	done
	unset warnplayersaction
	rm -f "${lockdir:?}/${selfname}-warning.lock"
}

# Attempts graceful shutdown by sending 'CTRL+c'.
fn_stop_graceful_ctrlc() {
	fn_print_dots "Graceful: CTRL+c"
	fn_script_log_info "Graceful: CTRL+c"
	# Sends CTRL+c.
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" C-c > /dev/null 2>&1
	# Waits up to 30 seconds giving the server time to shutdown gracefully.
	for seconds in {1..30}; do
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_ok "Graceful: CTRL+c: ${seconds}"
			fn_print_ok_eol_nl
			fn_script_log_pass "Graceful: CTRL+c: OK: ${seconds} seconds"
			if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "STOP" ]; then
				alert="stopped"
				alert.sh
			fi
			break
		fi
		fn_sleep_time_1
		fn_print_dots "Graceful: CTRL+c: ${seconds}"
	done
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_error "Graceful: CTRL+c: "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: CTRL+c: FAIL"
	fi
}

# Attempts graceful shutdown by sending a specified command.
# Usage: fn_stop_graceful_cmd "console_command" "timeout_in_seconds"
# e.g.: fn_stop_graceful_cmd "quit" "30"
fn_stop_graceful_cmd() {
	fn_print_dots "Graceful: sending \"${1}\""
	fn_script_log_info "Graceful: sending \"${1}\""
	# Sends specific stop command.
	TERM=screen tmux -L "${socketname}" send -t "${sessionname}" ENTER "${1}" ENTER > /dev/null 2>&1
	# Waits up to ${seconds} seconds giving the server time to shutdown gracefully.
	for ((seconds = 1; seconds <= ${2}; seconds++)); do
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_ok "Graceful: sending \"${1}\": ${seconds}"
			fn_print_ok_eol_nl
			fn_script_log_pass "Graceful: sending \"${1}\": OK: ${seconds} seconds"
			if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "STOP" ]; then
				alert="stopped"
				alert.sh
			fi
			break
		fi
		fn_sleep_time_1
		fn_print_dots "Graceful: sending \"${1}\": ${seconds}"
	done
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_error "Graceful: sending \"${1}\": "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: sending \"${1}\": FAIL"
	fi
}

# Attempts graceful shutdown of goldsrc using rcon 'quit' command.
# There is only a 3 second delay before a forced a tmux shutdown
# as GoldSrc servers 'quit' command does a restart rather than shutdown.
fn_stop_graceful_goldsrc() {
	fn_print_dots "Graceful: sending \"quit\""
	fn_script_log_info "Graceful: sending \"quit\""
	# sends quit
	TERM=screen tmux -L "${socketname}" send -t "${sessionname}" quit ENTER > /dev/null 2>&1
	# Waits 3 seconds as goldsrc servers restart with the quit command.
	for seconds in {1..3}; do
		fn_sleep_time_1
		fn_print_dots "Graceful: sending \"quit\": ${seconds}"
	done
	fn_print_ok "Graceful: sending \"quit\": ${seconds}"
	fn_print_ok_eol_nl
	fn_script_log_pass "Graceful: sending \"quit\": OK: ${seconds} seconds"
	if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "STOP" ]; then
		alert="stopped"
		alert.sh
	fi
}

# Opens a telnet connection using bash /dev/tcp.
# Usage: fn_stop_telnet_open "ip"
fn_stop_telnet_open() {
	telnetoutput=""
	exec {telnetfd}<> "/dev/tcp/${1}/${telnetport}"
} 2> /dev/null

# Closes the telnet connection.
fn_stop_telnet_close() {
	if [ -n "${telnetfd}" ]; then
		exec {telnetfd}>&-
		unset telnetfd
	fi
}

# Reads from the telnet connection until the text is received, ignoring case.
# Fails if the connection closes or nothing is received for the timeout.
# Usage: fn_stop_telnet_expect "text" "timeout_in_seconds"
fn_stop_telnet_expect() {
	local char
	while IFS= read -r -N 1 -t "${2:-10}" -u "${telnetfd}" char; do
		telnetoutput+="${char}"
		if [[ "${telnetoutput,,}" == *"${1,,}"* ]]; then
			return 0
		fi
	done
	return 1
}

# Reads from the telnet connection until the server closes it.
fn_stop_telnet_read_to_close() {
	local char
	while IFS= read -r -N 1 -t 10 -u "${telnetfd}" char; do
		telnetoutput+="${char}"
	done
}

# Sends a line to the telnet connection.
# Usage: fn_stop_telnet_send "text"
fn_stop_telnet_send() {
	(printf '%s\r\n' "${1}" >&"${telnetfd}") 2> /dev/null
}

# Telnet session for 7 Days to Die graceful shutdown.
# Usage: fn_stop_graceful_sdtd_telnet "ip"
fn_stop_graceful_sdtd_telnet() {
	fn_stop_telnet_open "${1}" || return 1
	if [ -n "${telnetpassword}" ] && [ "${telnetpassword}" != "NOT SET" ]; then
		if ! fn_stop_telnet_expect "password:" || ! fn_stop_telnet_send "${telnetpassword}"; then
			fn_stop_telnet_close
			return 1
		fi
	fi
	if fn_stop_telnet_expect "session." && fn_stop_telnet_send "shutdown"; then
		fn_stop_telnet_read_to_close
		fn_stop_telnet_close
		return 0
	fi
	fn_stop_telnet_close
	return 1
}

# Telnet session for Soulmask graceful shutdown.
# Usage: fn_stop_graceful_sm_telnet "ip"
fn_stop_graceful_sm_telnet() {
	fn_stop_telnet_open "${1}" || return 1
	if fn_stop_telnet_send "saveworld 1" && fn_stop_telnet_expect "world is saved" 120 && fn_stop_telnet_send "quit 1"; then
		fn_stop_telnet_read_to_close
		fn_stop_telnet_close
		return 0
	fi
	fn_stop_telnet_close
	return 1
}

# Attempts graceful shutdown using a telnet session.
# Tries localhost first, then the telnet and server IPs.
# Usage: fn_stop_graceful_telnet "session_function" "timeout_in_seconds"
# e.g.: fn_stop_graceful_telnet "fn_stop_graceful_sdtd_telnet" "60"
fn_stop_graceful_telnet() {
	fn_print_dots "Graceful: telnet"
	fn_script_log_info "Graceful: telnet"
	if [ "${telnetenabled}" == "false" ]; then
		fn_print_info_nl "Graceful: telnet: DISABLED: Enable in ${servercfg}"
		fn_script_log_info "Graceful: telnet: DISABLED"
		return
	fi
	local telnetaddresses=("127.0.0.1")
	local telnetaddress telnetsent
	for telnetaddress in "${telnetip[@]}" ${ip}; do
		if [ -n "${telnetaddress}" ] && [[ " ${telnetaddresses[*]} " != *" ${telnetaddress} "* ]]; then
			telnetaddresses+=("${telnetaddress}")
		fi
	done
	for telnetaddress in "${telnetaddresses[@]}"; do
		fn_print_dots "Graceful: telnet: ${telnetaddress}:${telnetport}"
		fn_script_log_info "Graceful: telnet: ${telnetaddress}:${telnetport}"
		if "${1}" "${telnetaddress}"; then
			telnetsent=1
			break
		fi
		fn_print_error "Graceful: telnet: ${telnetaddress}:${telnetport}: "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: telnet: ${telnetaddress}:${telnetport}: FAIL"
		if [ -n "${telnetoutput}" ]; then
			fn_script_log_error "Graceful: telnet: output: ${telnetoutput//$'\r'/}"
		fi
	done
	if [ -z "${telnetsent}" ]; then
		return
	fi
	# Waits up to ${seconds} seconds giving the server time to shutdown gracefully.
	for ((seconds = 1; seconds <= ${2}; seconds++)); do
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_ok "Graceful: telnet: ${telnetaddress}:${telnetport}: ${seconds}"
			fn_print_ok_eol_nl
			fn_script_log_pass "Graceful: telnet: ${telnetaddress}:${telnetport}: OK: ${seconds} seconds"
			if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "STOP" ]; then
				alert="stopped"
				alert.sh
			fi
			break
		fi
		fn_sleep_time_1
		fn_print_dots "Graceful: telnet: ${telnetaddress}:${telnetport}: ${seconds}"
	done
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_error "Graceful: telnet: ${telnetaddress}:${telnetport}: "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: telnet: ${telnetaddress}:${telnetport}: FAIL"
	fi
}

# Attempts graceful shutdown by sending /save /stop.
fn_stop_graceful_avorion() {
	fn_print_dots "Graceful: /save /stop"
	fn_script_log_info "Graceful: /save /stop"
	# Sends /save.
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" /save ENTER > /dev/null 2>&1
	fn_sleep_time_5
	# Sends /quit.
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" /stop ENTER > /dev/null 2>&1
	# Waits up to 30 seconds giving the server time to shutdown gracefully.
	for seconds in {1..30}; do
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_ok "Graceful: /save /stop: ${seconds}"
			fn_print_ok_eol_nl
			fn_script_log_pass "Graceful: /save /stop: OK: ${seconds} seconds"
			if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "STOP" ]; then
				alert="stopped"
				alert.sh
			fi
			break
		fi
		fn_sleep_time_1
		fn_print_dots "Graceful: /save /stop: ${seconds}"
	done
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_error "Graceful: /save /stop: "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: /save /stop: FAIL"
	fi
}

fn_stop_graceful_rwr() {
	fn_print_dots "Graceful: save_profiles stop_server"
	fn_script_log_info "Graceful: save_profiles stop_server"
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" save_profiles ENTER > /dev/null 2>&1
	fn_sleep_time_5
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" stop_server ENTER > /dev/null 2>&1
	fn_sleep_time_5
	fn_stop_graceful_ctrlc
}

# Attempts graceful shutdown of Rising World using 'shutdown'.
# Its console can miss input, so the command is sent again every 10 seconds until the server stops.
fn_stop_graceful_rw() {
	fn_print_dots "Graceful: sending \"shutdown\""
	fn_script_log_info "Graceful: sending \"shutdown\""
	for ((seconds = 1; seconds <= 120; seconds++)); do
		if [ $((seconds % 10)) -eq 1 ]; then
			TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" ENTER > /dev/null 2>&1
			sleep 1
			TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" -l "shutdown" > /dev/null 2>&1
			TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" ENTER > /dev/null 2>&1
		fi
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_ok "Graceful: sending \"shutdown\": ${seconds}"
			fn_print_ok_eol_nl
			fn_script_log_pass "Graceful: sending \"shutdown\": OK: ${seconds} seconds"
			if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "STOP" ]; then
				alert="stopped"
				alert.sh
			fi
			break
		fi
		fn_sleep_time_1
		fn_print_dots "Graceful: sending \"shutdown\": ${seconds}"
	done
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_error "Graceful: sending \"shutdown\": "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: sending \"shutdown\": FAIL"
	fi
}

fn_stop_graceful_select() {
	if [ "${stopmode}" == "1" ]; then
		fn_stop_tmux
	elif [ "${stopmode}" == "2" ]; then
		fn_stop_graceful_ctrlc
	elif [ "${stopmode}" == "3" ]; then
		fn_stop_graceful_cmd "quit" 30
	elif [ "${stopmode}" == "4" ]; then
		fn_stop_graceful_cmd "quit" 120
	elif [ "${stopmode}" == "5" ]; then
		fn_stop_graceful_cmd "stop" 30
	elif [ "${stopmode}" == "6" ]; then
		fn_stop_graceful_cmd "q" 30
	elif [ "${stopmode}" == "7" ]; then
		fn_stop_graceful_cmd "exit" 30
	elif [ "${stopmode}" == "8" ]; then
		fn_stop_graceful_telnet "fn_stop_graceful_sdtd_telnet" "60"
	elif [ "${stopmode}" == "9" ]; then
		fn_stop_graceful_goldsrc
	elif [ "${stopmode}" == "10" ]; then
		fn_stop_graceful_avorion
	elif [ "${stopmode}" == "11" ]; then
		fn_stop_graceful_cmd "end" 30
	elif [ "${stopmode}" == "12" ]; then
		fn_stop_graceful_cmd "shutdown" 30
	elif [ "${stopmode}" == "13" ]; then
		fn_stop_graceful_telnet "fn_stop_graceful_sm_telnet" "30"
	elif [ "${stopmode}" == "14" ]; then
		fn_stop_graceful_rwr
	elif [ "${stopmode}" == "15" ]; then
		fn_stop_graceful_rw
	fi
}

fn_stop_tmux() {
	fn_print_dots "${servername}"
	fn_script_log_info "tmux kill-session: ${sessionname}: ${servername}"
	# Kill tmux session.
	TERM=screen tmux -L "${socketname}" kill-session -t "${sessionname}" > /dev/null 2>&1
	fn_sleep_time_1
	check_status.sh
	if [ "${status}" == "0" ]; then
		fn_print_ok_nl "${servername}"
		fn_script_log_pass "Stopped ${servername}"
		if [ "${statusalert}" == "on" ] && [ "${firstcommandname}" == "STOP" ]; then
			alert="stopped"
			alert.sh
		fi
	else
		fn_print_fail_nl "Unable to stop ${servername}"
		fn_script_log_fail "Unable to stop ${servername}"
	fi
}

# Checks if the server is already stopped.
fn_stop_pre_check() {
	if [ "${status}" == "0" ]; then
		fn_print_skip_nl "${servername} is already stopped"
		fn_script_log_info "${servername} is already stopped"
	else
		# Select graceful shutdown.
		fn_stop_graceful_select
		# Check status again, a kill tmux session if graceful shutdown failed.
		check_status.sh
		if [ "${status}" != "0" ]; then
			fn_stop_tmux
		fi
	fi
}

fn_print_dots ""
check.sh
info_game.sh

# Players are checked and warned before the stopping lockfile is created,
# as a warning countdown can outlast monitor's stale lockfile check.
if [ "${status}" != "0" ]; then
	fn_stop_players_online
	fn_stop_warn_players
	check_status.sh
fi

# Create a stopping lockfile that only exists while the stop command is running.
date '+%s' > "${lockdir:?}/${selfname}-stopping.lock"

fn_print_dots "${servername}"

fn_stop_pre_check

# Remove started lockfile.
rm -f "${lockdir:?}/${selfname}-started.lock"

# If user ran the stop command monitor will become disabled.
if [ "${firstcommandname}" == "STOP" ]; then
	rm -f "${lockdir:?}/${selfname}-monitoring.lock"
fi

# Remove stopping lockfile.
rm -f "${lockdir:?}/${selfname}-stopping.lock"

if [ -z "${exitbypass}" ]; then
	core_exit.sh
fi
