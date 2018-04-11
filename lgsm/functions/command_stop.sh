#!/bin/bash
# LinuxGSM command_stop.sh function
# Author: Daniel Gibbs
# Contributors: UltimateByte
# Website: https://linuxgsm.com
# Description: Stops the server.

local commandname="STOP"
local commandaction="Stopping"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Attempts graceful shutdown by sending the 'CTRL+c'.
fn_stop_graceful_ctrlc(){
	fn_print_dots "Graceful: CTRL+c"
	fn_script_log_info "Graceful: CTRL+c"
	# sends quit
	tmux send-keys C-c -t="${servicename}" > /dev/null 2>&1
	# waits up to 30 seconds giving the server time to shutdown gracefuly
	for seconds in {1..30}; do
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_ok "Graceful: CTRL+c: ${seconds}: "
			fn_print_ok_eol_nl
			fn_script_log_pass "Graceful: CTRL+c: OK: ${seconds} seconds"
			break
		fi
		sleep 1
		fn_print_dots "Graceful: CTRL+c: ${seconds}"
	done
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_error "Graceful: CTRL+c: "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: CTRL+c: FAIL"
	fi
	sleep 0.5
	fn_stop_tmux
}

# Attempts graceful shutdown by sending a specified command.
# Usage: fn_stop_graceful_cmd "console_command" "timeout_in_seconds"
#  e.g.: fn_stop_graceful_cmd "quit" "30"
fn_stop_graceful_cmd(){
	fn_print_dots "Graceful: sending \"${1}\""
	fn_script_log_info "Graceful: sending \"${1}\""
	# sends specific stop command
	tmux send -t="${servicename}" "${1}" ENTER > /dev/null 2>&1
	# waits up to given seconds giving the server time to shutdown gracefully
	for ((seconds=1; seconds<=${2}; seconds++)); do
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_ok "Graceful: sending \"${1}\": ${seconds}: "
			fn_print_ok_eol_nl
			fn_script_log_pass "Graceful: sending \"${1}\": OK: ${seconds} seconds"
			break
		fi
		sleep 1
		fn_print_dots "Graceful: sending \"${1}\": ${seconds}"
	done
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_error "Graceful: sending \"${1}\": "
		fn_print_fail_eol_nl
		fn_script_log_error "Graceful: sending \"${1}\": FAIL"
	fi
	sleep 0.5
	fn_stop_tmux
}

# Attempts graceful of goldsource using rcon 'quit' command.
# Goldsource 'quit' command restarts rather than shutdown
# this function will only wait 3 seconds then force a tmux shutdown.
# preventing the server from coming back online.
fn_stop_graceful_goldsource(){
	fn_print_dots "Graceful: sending \"quit\""
	fn_script_log_info "Graceful: sending \"quit\""
	# sends quit
	tmux send -t="${servicename}" quit ENTER > /dev/null 2>&1
	# waits 3 seconds as goldsource servers restart with the quit command
	for seconds in {1..3}; do
		sleep 1
		fn_print_dots "Graceful: sending \"quit\": ${seconds}"
	done
	fn_print_ok "Graceful: sending \"quit\": ${seconds}: "
	fn_print_ok_eol_nl
	fn_script_log_pass "Graceful: sending \"quit\": OK: ${seconds} seconds"
	sleep 0.5
	fn_stop_tmux
}

# Attempts graceful of 7 Days To Die using telnet.
fn_stop_telnet_sdtd(){
	if [ -z "${telnetpass}" ]; then
		telnetpass="NOTSET"
	fi
	sdtd_telnet_shutdown=$( expect -c '
	proc abort {} {
		puts "Timeout or EOF\n"
		exit 1
	}
	spawn telnet '"${telnetip}"' '"${telnetport}"'
	expect {
		"password:"     { send "'"${telnetpass}"'\r" }
		default         abort
	}
	expect {
		"session."  { send "shutdown\r" }
		default         abort
	}
	expect { eof }
	puts "Completed.\n"
	')
}

fn_stop_graceful_sdtd(){
	fn_print_dots "Graceful: telnet"
	fn_script_log_info "Graceful: telnet"
	sleep 0.5
	if [ "${telnetenabled}" == "false" ]; then
		fn_print_info_nl "Graceful: telnet: DISABLED: Enable in ${servercfg}"
	elif [ "$(command -v expect 2>/dev/null)" ]; then
		# Tries to shutdown with both localhost and server IP.
		for telnetip in 127.0.0.1 ${ip}; do
			fn_print_dots "Graceful: telnet: ${telnetip}"
			fn_script_log_info "Graceful: telnet: ${telnetip}"
			sleep 0.5
			fn_stop_telnet_sdtd
			completed=$(echo -en "\n ${sdtd_telnet_shutdown}" | grep "Completed.")
			refused=$(echo -en "\n ${sdtd_telnet_shutdown}" | grep "Timeout or EOF")
			if [ -n "${refused}" ]; then
				fn_print_error "Graceful: telnet: ${telnetip}: "
				fn_print_fail_eol_nl
				fn_script_log_error "Graceful: telnet: ${telnetip}: FAIL"
				sleep 1
			elif [ -n "${completed}" ]; then
				break
			fi
		done

		# If telnet was successful will use telnet again to check the connection has closed
		# This confirms that the tmux session can now be killed.
		if [ -n "${completed}" ]; then
			for seconds in {1..30}; do
				fn_stop_telnet_sdtd
				refused=$(echo -en "\n ${sdtd_telnet_shutdown}" | grep "Timeout or EOF")
				if [ -n "${refused}" ]; then
					fn_print_ok "Graceful: telnet: ${telnetip}: "
					fn_print_ok_eol_nl
					fn_script_log_pass "Graceful: telnet: ${telnetip}: ${seconds} seconds"
					break
				fi
				sleep 1
				fn_print_dots "Graceful: telnet: ${seconds}"
			done
		# If telnet failed will go straight to tmux shutdown.
		# If cannot shutdown correctly world save may be lost
		else
			if [ -n "${refused}" ]; then
				fn_print_error "Graceful: telnet: "
				fn_print_fail_eol_nl
				fn_script_log_error "Graceful: telnet: ${telnetip}: FAIL"
			else
				fn_print_error_nl "Graceful: telnet: Unknown error"
				fn_script_log_error "Graceful: telnet: Unknown error"
			fi
			echo -en "\n" | tee -a "${lgsmlog}"
			echo -en "Telnet output:" | tee -a "${lgsmlog}"
			echo -en "\n ${sdtd_telnet_shutdown}" | tee -a "${lgsmlog}"
			echo -en "\n\n" | tee -a "${lgsmlog}"
		fi
	else
		fn_print_warn "Graceful: telnet: expect not installed: "
		fn_print_fail_eol_nl
		fn_script_log_warn "Graceful: telnet: expect not installed: FAIL"
	fi
	sleep 0.5
	fn_stop_tmux
}

fn_stop_graceful_select(){
	if [ "${gamename}" == "7 Days To Die" ]; then
		fn_stop_graceful_sdtd
	elif [ "${engine}" == "Spark" ]; then
		fn_stop_graceful_cmd "q" 30
	elif [ "${gamename}" == "Terraria" ]; then
		fn_stop_graceful_cmd "exit" 30
	elif [ "${gamename}" == "Minecraft" ]; then
		fn_stop_graceful_cmd "stop" 30
	elif [ "${gamename}" == "Multi Theft Auto" ]; then
		# we need a long wait time here as resources are stopped individually and process their own shutdowns
		fn_stop_graceful_cmd "quit" 120
	elif [ "${engine}" == "goldsource" ]; then
		fn_stop_graceful_goldsource
	elif [ "${engine}" == "avalanche2.0" ]||[ "${engine}" == "avalanche3.0" ]||[ "${gamename}" == "Factorio" ]||[ "${engine}" == "unity3d" ]||[ "${engine}" == "unreal4" ]||[ "${engine}" == "unreal3" ]||[ "${engine}" == "unreal2" ]||[ "${engine}" == "unreal" ]||[ "${gamename}" == "Mumble" ]; then
		fn_stop_graceful_ctrlc
	elif  [ "${engine}" == "source" ]||[ "${engine}" == "quake" ]||[ "${engine}" == "idtech2" ]||[ "${engine}" == "idtech3" ]||[ "${engine}" == "idtech3_ql" ]||[ "${engine}" == "Just Cause 2" ]||[ "${engine}" == "projectzomboid" ]||[ "${shortname}" == "rw" ]; then
		fn_stop_graceful_cmd "quit" 30
	else
		fn_stop_tmux
	fi
}

fn_stop_ark(){
	maxpiditer=15 # The maximum number of times to check if the ark pid has closed gracefully.
	info_config.sh
	if [ -z "${queryport}" ]; then
		fn_print_warn "No queryport found using info_config.sh"
		fn_script_log_warn "No queryport found using info_config.sh"
		userconfigfile="${serverfiles}"
		userconfigfile+="/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini"
		queryport=$(grep ^QueryPort= ${userconfigfile} | cut -d= -f2 | sed "s/[^[:digit:].*].*//g")
	fi
	if [ -z "${queryport}" ]; then
		fn_print_warn "No queryport found in the GameUsersettings.ini file"
		fn_script_log_warn "No queryport found in the GameUsersettings.ini file"
		return
	fi

	if [ "${#queryport}" -gt 0 ] ; then
		for (( pidcheck=0 ; pidcheck < ${maxpiditer} ; pidcheck++ )) ; do
			pid=$(netstat -nap 2>/dev/null | grep "^udp[[:space:]]" |\
				grep ":${queryport}[[:space:]]" | rev | awk '{print $1}' |\
				rev | cut -d\/ -f1)
			#
			# check for a valid pid
			pid=${pid//[!0-9]/}
			let pid+=0 # turns an empty string into a valid number, '0',
			# and a valid numeric pid remains unchanged.
			if [ "${pid}" -gt 1 ]&&[ "${pid}" -le "$(cat "/proc/sys/kernel/pid_max")" ]; then
			fn_print_dots "Process still bound. Awaiting graceful exit: ${pidcheck}"
				sleep 0.5
			else
				break # Our job is done here
			fi # end if for pid range check
		done
		if [[ ${pidcheck} -eq ${maxpiditer} ]] ; then
			# The process doesn't want to close after 20 seconds.
			# kill it hard.
			fn_print_error "Terminating reluctant Ark process: ${pid}"
			kill -9 ${pid}
		fi
	fi # end if for port check
} # end of fn_stop_ark

fn_stop_teamspeak3(){
	fn_print_dots "${servername}"
	sleep 0.5
	"${serverfiles}"/ts3server_startscript.sh stop > /dev/null 2>&1
	check_status.sh
	if [ "${status}" == "0" ]; then
		# Remove lockfile
		rm -f "${rootdir}/${lockselfname}"
		fn_print_ok_nl "${servername}"
		fn_script_log_pass "Stopped ${servername}"
	else
		fn_print_fail_nl "Unable to stop ${servername}"
		fn_script_log_error "Unable to stop ${servername}"
	fi
}

fn_stop_tmux(){
	fn_print_dots "${servername}"
	fn_script_log_info "tmux kill-session: ${servername}"
	sleep 0.5
	# Kill tmux session
	tmux kill-session -t="${servicename}" > /dev/null 2>&1
	sleep 0.5
	check_status.sh
	if [ "${status}" == "0" ]; then
		# Remove lockfile
		rm -f "${rootdir}/${lockselfname}"
		# ARK doesn't clean up immediately after tmux is killed.
		# Make certain the ports are cleared before continuing.
		if [ "${gamename}" == "ARK: Survival Evolved" ]; then
			fn_stop_ark
		fi
		fn_print_ok_nl "${servername}"
		fn_script_log_pass "Stopped ${servername}"
	else
		fn_print_fail_nl "Unable to stop${servername}"
		fn_script_log_fatal "Unable to stop${servername}"
	fi
}

# checks if the server is already stopped before trying to stop.
fn_stop_pre_check(){
	if [ "${gamename}" == "TeamSpeak 3" ]; then
		check_status.sh
		if [ "${status}" == "0" ]; then
			fn_print_info_nl "${servername} is already stopped"
			fn_script_log_error "${servername} is already stopped"
		else
			fn_stop_teamspeak3
		fi
	else
		if [ "${status}" == "0" ]; then
			fn_print_info_nl "${servername} is already stopped"
			fn_script_log_error "${servername} is already stopped"
		else
			fn_stop_graceful_select
		fi
	fi
}

fn_print_dots "${servername}"
sleep 0.5
check.sh
info_config.sh
fn_stop_pre_check
core_exit.sh
