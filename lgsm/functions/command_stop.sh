#!/bin/bash
# LinuxGSM command_stop.sh function
# Author: Daniel Gibbs
# Contributors: UltimateByte
# Website: https://linuxgsm.com
# Description: Stops the server.

local commandname="STOP"
local commandaction="Stopping"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Attempts graceful shutdown by sending 'CTRL+c'.
fn_stop_graceful_ctrlc(){
	fn_print_dots "Graceful: CTRL+c"
	fn_script_log_info "Graceful: CTRL+c"
	# Sends quit.
	tmux send-keys -t "${servicename}" C-c  > /dev/null 2>&1
	# Waits up to 30 seconds giving the server time to shutdown gracefuly.
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
	fn_sleep_time
}

# Attempts graceful shutdown by sending a specified command.
# Usage: fn_stop_graceful_cmd "console_command" "timeout_in_seconds"
# e.g.: fn_stop_graceful_cmd "quit" "30"
fn_stop_graceful_cmd(){
	fn_print_dots "Graceful: sending \"${1}\""
	fn_script_log_info "Graceful: sending \"${1}\""
	# Sends specific stop command.
	tmux send -t "${servicename}" "${1}" ENTER > /dev/null 2>&1
	# Waits up to ${seconds} seconds giving the server time to shutdown gracefully.
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
	fn_sleep_time
}

# Attempts graceful shutdown of goldsource using rcon 'quit' command.
# There is only a 3 second delay before a forced a tmux shutdown
# as Goldsource servers 'quit' command does a restart rather than shutdown.
fn_stop_graceful_goldsource(){
	fn_print_dots "Graceful: sending \"quit\""
	fn_script_log_info "Graceful: sending \"quit\""
	# sends quit
	tmux send -t "${servicename}" quit ENTER > /dev/null 2>&1
	# Waits 3 seconds as goldsource servers restart with the quit command.
	for seconds in {1..3}; do
		sleep 1
		fn_print_dots "Graceful: sending \"quit\": ${seconds}"
	done
	fn_print_ok "Graceful: sending \"quit\": ${seconds}: "
	fn_print_ok_eol_nl
	fn_script_log_pass "Graceful: sending \"quit\": OK: ${seconds} seconds"
}

fn_stop_telnet_sdtd(){
	if [ -z "${telnetpass}" ]||[ "${telnetpass}" == "NOT SET" ]; then
		sdtd_telnet_shutdown=$( expect -c '
		proc abort {} {
			puts "Timeout or EOF\n"
			exit 1
		}
		spawn telnet '"${telnetip}"' '"${telnetport}"'
		expect {
			"session."  { send "shutdown\r" }
			default         abort
		}
		expect { eof }
		puts "Completed.\n"
		')
	else
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
	fi
}

# Attempts graceful shutdown of 7 Days To Die using telnet.
fn_stop_graceful_sdtd(){
	fn_print_dots "Graceful: telnet"
	fn_script_log_info "Graceful: telnet"
	if [ "${telnetenabled}" == "false" ]; then
		fn_print_info_nl "Graceful: telnet: DISABLED: Enable in ${servercfg}"
	elif [ "$(command -v expect 2>/dev/null)" ]; then
		# Tries to shutdown with both localhost and server IP.
		for telnetip in 127.0.0.1 ${ip}; do
			fn_print_dots "Graceful: telnet: ${telnetip}:${telnetport}"
			fn_script_log_info "Graceful: telnet: ${telnetip}:${telnetport}"
			fn_stop_telnet_sdtd
			completed=$(echo -en "\n ${sdtd_telnet_shutdown}" | grep "Completed.")
			refused=$(echo -en "\n ${sdtd_telnet_shutdown}" | grep "Timeout or EOF")
			if [ -n "${refused}" ]; then
				fn_print_error "Graceful: telnet: ${telnetip}:${telnetport} : "
				fn_print_fail_eol_nl
				fn_script_log_error "Graceful: telnet:  ${telnetip}:${telnetport} : FAIL"
			elif [ -n "${completed}" ]; then
				break
			fi
		done

		# If telnet shutdown was successful will use telnet again to check
		# the connection has closed, confirming that the tmux session can now be killed.
		if [ -n "${completed}" ]; then
			for seconds in {1..30}; do
				fn_stop_telnet_sdtd
				refused=$(echo -en "\n ${sdtd_telnet_shutdown}" | grep "Timeout or EOF")
				if [ -n "${refused}" ]; then
					fn_print_ok "Graceful: telnet: ${telnetip}:${telnetport} : "
					fn_print_ok_eol_nl
					fn_script_log_pass "Graceful: telnet: ${telnetip}:${telnetport} : ${seconds} seconds"
					break
				fi
				sleep 1
				fn_print_dots "Graceful: telnet: ${seconds}"
			done
		# If telnet shutdown fails tmux shutdown will be used, this risks loss of world save.
		else
			if [ -n "${refused}" ]; then
				fn_print_error "Graceful: telnet: "
				fn_print_fail_eol_nl
				fn_script_log_error "Graceful: telnet: ${telnetip}:${telnetport} : FAIL"
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
	fn_sleep_time
}

fn_stop_graceful_select(){
	if [ "${shortname}" == "sdtd" ]; then
		fn_stop_graceful_sdtd
	elif [ "${engine}" == "spark" ]; then
		fn_stop_graceful_cmd "q" 30
	elif [ "${shortname}" == "terraria" ]; then
		fn_stop_graceful_cmd "exit" 30
	elif [ "${shortname}" == "mc" ]; then
		fn_stop_graceful_cmd "stop" 30
	elif [ "${shortname}" == "mta" ]; then
		# Long wait time required for mta
		# as resources shutdown individually.
		fn_stop_graceful_cmd "quit" 120
	elif [ "${engine}" == "goldsource" ]; then
		fn_stop_graceful_goldsource
	elif [ "${engine}" == "unity3d" ]||[ "${engine}" == "unreal4" ]||[ "${engine}" == "unreal3" ]||[ "${engine}" == "unreal2" ]||[ "${engine}" == "unreal" ]||[ "${shortname}" == "fctr" ]||[ "${shortname}" == "mumble" ]||[ "${shortname}" == "wurm" ]||[ "${shortname}" == "jc2" ]||[ "${shortname}" == "jc3" ]||[ "${shortname}" == "av" ]; then
		fn_stop_graceful_ctrlc
	elif  [ "${engine}" == "source" ]||[ "${engine}" == "quake" ]||[ "${engine}" == "idtech2" ]||[ "${engine}" == "idtech3" ]||[ "${engine}" == "idtech3_ql" ]||[ "${shortname}" == "pz" ]||[ "${shortname}" == "rw" ]; then
		fn_stop_graceful_cmd "quit" 30
	fi
}

fn_stop_ark(){
	# The maximum number of times to check if the ark pid has closed gracefully.
	maxpiditer=15
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
			pid=$(netstat -nap 2>/dev/null | grep "^udp[[:space:]]" | grep ":${queryport}[[:space:]]" | rev | awk '{print $1}' | rev | cut -d\/ -f1)
			# Check for a valid pid.
			pid=${pid//[!0-9]/}
			let pid+=0 # turns an empty string into a valid number, '0',
			# and a valid numeric pid remains unchanged.
			if [ "${pid}" -gt 1 ]&&[ "${pid}" -le "$(cat "/proc/sys/kernel/pid_max")" ]; then
			fn_print_dots "Process still bound. Awaiting graceful exit: ${pidcheck}"
			else
				break
			fi
		done
		if [[ ${pidcheck} -eq ${maxpiditer} ]] ; then
			# The process doesn't want to close after 20 seconds.
			# kill it hard.
			fn_print_error "Terminating reluctant Ark process: ${pid}"
			kill -9 ${pid}
		fi
	fi
}

fn_stop_teamspeak3(){
	fn_print_dots "${servername}"
	"${serverfiles}"/ts3server_startscript.sh stop > /dev/null 2>&1
	check_status.sh
	if [ "${status}" == "0" ]; then
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
	# Kill tmux session
	tmux kill-session -t "${servicename}" > /dev/null 2>&1
	fn_sleep_time
	check_status.sh
	if [ "${status}" == "0" ]; then
		# ARK does not clean up immediately after tmux is killed.
		# Make certain the ports are cleared before continuing.
		if [ "${shortname}" == "ark" ]; then
			fn_stop_ark
		fi
		fn_print_ok_nl "${servername}"
		fn_script_log_pass "Stopped ${servername}"
	else
		fn_print_fail_nl "Unable to stop ${servername}"
		fn_script_log_fatal "Unable to stop ${servername}"
	fi
}

# Checks if the server is already stopped.
fn_stop_pre_check(){
	if [ "${status}" == "0" ]; then
		fn_print_info_nl "${servername} is already stopped"
		fn_script_log_error "${servername} is already stopped"
	elif [ "${shortname}" == "ts3" ]; then
		fn_stop_teamspeak3
	else
		fn_stop_graceful_select
	fi
	# Check status again, a stop tmux session if needed.
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_stop_tmux
	fi
}

fn_print_dots "${servername}"
check.sh
info_config.sh
fn_stop_pre_check
# Remove lockfile.
if [ -f "${rootdir}/${lockselfname}" ]; then
	rm -f "${rootdir}/${lockselfname}"
fi
if [ -z "${exitbypass}" ]; then
	core_exit.sh
fi
