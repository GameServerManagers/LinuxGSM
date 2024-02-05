#!/bin/bash
# LinuxGSM command_rcon.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Send rcon commands to different gameservers.

commandname="RCON"
commandaction="Rcon"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
if [ "${status}" == "0" ]; then
	fn_print_error_nl "Server not running"
	fn_script_log_error "Failed to access: Server not running"
	if fn_prompt_yn "Do you want to start the server?" Y; then
		exitbypass=1
		command_start.sh
	fi
fi


if [ -n "${userinput2}" ]; then
	rconcommandtosend="${userinput2}"
else
	fn_print_header
	fn_print_information_nl "Send a RCON command to the server."
	echo ""
	rconcommandtosend=$(fn_prompt_message "RCON command: ")
fi

fn_print_dots "Sending RCON command to server: \"${rconcommandtosend}\""

if [ ! -f "${modulesdir}/rcon.py" ]; then
	fn_fetch_file_github "lgsm/modules" "rcon.py" "${modulesdir}" "chmodx" "norun" "noforce" "nohash"
fi

"${modulesdir}"/rcon.py -a "${telnetip}" -p "${rconport}" -P "${rconpassword}" -c "${rconcommandtosend}" > /dev/null 2>&1

fn_print_ok_nl "Sending RCON command to server: \"${rconcommandtosend}\""
fn_script_log_pass "RCON command \"${rconcommandtosend}\" sent to server"

core_exit.sh
