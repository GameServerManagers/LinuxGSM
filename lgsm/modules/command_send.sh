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
		if ! commandtosend=$(fn_prompt_message "send: "); then
			echo -e ""
			fn_print_error_nl "Unable to read a command to send: no input available"
			fn_script_log_error "Unable to read a command to send: no input available"
			# shellcheck disable=SC2034 # Used by core_exit.sh.
			exitcode=2
			core_exit.sh
		fi
	fi
	echo ""
	fn_print_dots "Sending command to console: \"${commandtosend}\""
	fn_print_ok_nl "Sending command to console: \"${commandtosend}\""
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" -l "${commandtosend}"
	TERM=screen tmux -L "${socketname}" send-keys -t "${sessionname}" ENTER
	fn_script_log_pass "Command \"${commandtosend}\" sent to console"
else
	fn_print_error_nl "Unable to send command to console. Server not running"
	fn_script_log_error "Unable to send command to console. Server not running"
fi

core_exit.sh
