#!/bin/bash
# LinuxGSM command_ts3_server_pass.sh function
# Author: Daniel Gibbs
# Contributor : UltimateByte
# Website: https://linuxgsm.com
# Description: Changes TS3 serveradmin password.

local commandname="TS3-CHANGE-PASS"
local commandaction="ServerAdmin Password Change"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_serveradmin_password_prompt(){
	fn_print_header
	echo "Press \"CTRL+b d\" to exit console."
	fn_print_information_nl "You are about to change the ${gamename} ServerAdmin password."
	fn_print_warning_nl "${gamename} will restart during this process."
	echo ""
	if ! fn_prompt_yn "Continue?" Y; then
		echo Exiting; exit
	fi
	fn_script_log_info "Initiating ${gamename} ServerAdmin password change"
	read -rp "Enter new password : " newpassword
}

fn_serveradmin_password_set(){
	fn_print_info_nl "Starting server with new password..."
	fn_script_log_info "Starting server with new password"
	sleep 0.5
	# Start server in "new password mode"
	ts3serverpass="1"
	exitbypass="1"
	command_start.sh
	fn_print_ok_nl "Password applied"
	fn_script_log_pass "New ServerAdmin password applied"
	sleep 0.5
}

# Running functions
check.sh
fn_serveradmin_password_prompt
check_status.sh
if [ "${status}" != "0" ]; then
	# Stop any running server
	exitbypass="1"
	command_stop.sh
	fn_serveradmin_password_set
	ts3serverpass="0"
	fn_print_info_nl "Restarting server normally"
	fn_script_log_info "Restarting server normally"
	command_restart.sh
else
	fn_serveradmin_password_set
	command_stop.sh
fi
core_exit.sh
