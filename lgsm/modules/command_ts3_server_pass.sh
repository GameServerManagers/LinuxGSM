#!/bin/bash
# LinuxGSM command_ts3_server_pass.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Changes TS3 serveradmin password.

commandname="CHANGE-PASSWORD"
commandaction="Changing Password"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_serveradmin_password_prompt() {
	fn_print_header
	fn_print_information_nl "You are about to change the ${gamename} ServerAdmin password."
	fn_print_warning_nl "${gamename} will restart during this process."
	echo -e ""
	if ! fn_prompt_yn "Continue?" Y; then
		exitcode=0
		core_exit.sh
	fi
	fn_script_log_info "Initiating ${gamename} ServerAdmin password change"
	read -rp "Enter new password: " newpassword
	fn_print_info_nl "Changing password"
	fn_script_log_info "Changing password"
}

fn_serveradmin_password_set() {
	# Start server in "new password mode".
	ts3serverpass="1"
	exitbypass=1
	command_start.sh
	fn_firstcommand_reset
	fn_print_ok_nl "New password applied"
	fn_script_log_pass "New ServerAdmin password applied"
}

# Running functions.
check.sh
fn_serveradmin_password_prompt
if [ "${status}" != "0" ]; then
	# Stop any running server.
	exitbypass=1
	command_stop.sh
	fn_firstcommand_reset
	fn_serveradmin_password_set
	parms="serveradmin_password=\"${newpassword}\" inifile=\"${servercfgfullpath}\" > /dev/null 2>&1"
	ts3serverpass="0"
	command_restart.sh
	fn_firstcommand_reset
else
	fn_serveradmin_password_set
	command_stop.sh
	fn_firstcommand_reset
fi

core_exit.sh
