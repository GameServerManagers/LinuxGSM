#!/bin/bash
# LinuxGSM command_send.sh function
# Author: Duval Lucas
# Website: https://linuxgsm.com
# Description: Send command to the server tmux console.

local commandname="SEND"
local commandaction="Send"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh
fn_print_header
if [ "${shortname}" == "rust" ]||[ "${shortname}" == "hw" ]||[ "${shortname}" == "ark" ]||[ "${shortname}" == "ts3" ]; then
        fn_print_information_nl "${gamename} does not allow server commands to be entered in to the console"
        core_exit.sh
fi

sleep 0.5
check_status.sh
if [ "${status}" != "0" ]; then
	if [ -n "${userinput2}" ]; then
		command_to_send="${userinput2}"
    else
    	command_to_send=$( fn_prompt_message "Write the command you want to send: " )
    fi
    fn_print_info_nl "Sending \"${command_to_send}\""
	fn_print_dots "Sending command to console"
	fn_script_log_pass "Sending command \"${command_to_send}\" to console"
	sleep 0.5
    tmux send-keys -t "${servicename}" "${command_to_send}" ENTER
    fn_print_ok_nl "Command sended to console"
    fn_script_log_pass "Sended command \"${command_to_send}\" to console"
else
    fn_print_error_nl "Server not running"
    fn_script_log_error "Failed to access: Server not running"
    sleep 0.5
fi

core_exit.sh
