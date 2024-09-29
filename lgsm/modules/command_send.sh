#!/bin/bash
# LinuxGSM command_send.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Send command to the server tmux console.

commandname="SEND"
commandaction="Send"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
if [ -z "${userinput2}" ]; then
	fn_print_header
	fn_print_information_nl "Send a command to the console."
fi

check_status.sh
if [ "${status}" != "0" ]; then
	if [ -n "${userinput2}" ]; then
		commandtosend="${userinput2}"
	else
		echo ""
		commandtosend=$(fn_prompt_message "send: ")
	fi
	echo ""
	fn_print_dots "Sending command to console: \"${commandtosend}\""
	tmux -L "${socketname}" send-keys -t "${sessionname}" "${commandtosend}" ENTER
	fn_print_ok_nl "Sending command to console: \"${commandtosend}\""
	fn_script_log_pass "Command \"${commandtosend}\" sent to console"
else
	fn_print_error_nl "Server not running"
	fn_script_log_error "Failed to access: Server not running"
	if fn_prompt_yn "Do you want to start the server?" Y; then
		exitbypass=1
		command_start.sh
	fi
fi

core_exit.sh
