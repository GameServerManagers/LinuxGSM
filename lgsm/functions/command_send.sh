#!/bin/bash
# LinuxGSM command_send.sh function
# Author: Duval Lucas
# Website: https://linuxgsm.com
# Description: Send command to the server tmux console.

local commandname="SEND"
local commandaction="Send"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh
if [ -z "${userinput2}" ]; then
	fn_print_header
	fn_print_information_nl "Send allows a command to be sent to the console."
fi

check_status.sh
if [ "${status}" != "0" ]; then
	if [ -n "${userinput2}" ]; then
		command_to_send="${userinput2}"
	else
		echo ""
		command_to_send=$( fn_prompt_message "send: " )
	fi
	fn_print_information_nl "Sending \"${command_to_send}\"."
	fn_print_dots "Sending command to console"
	tmux send-keys -t "${servicename}" "${command_to_send}" ENTER
	fn_print_ok_nl "Command sent to console."
	fn_script_log_pass "Command \"${command_to_send}\" sent to console"
else
	fn_print_error_nl "Server not running"
	fn_script_log_error "Failed to access: Server not running"
	if fn_prompt_yn "Do you want to start the server?" Y; then
		exitbypass=1
		command_start.sh
	fi
fi

core_exit.sh
