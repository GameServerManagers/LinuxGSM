#!/bin/bash
# LGSM command_console.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Gives access to the server tmux console.

local commandname="CONSOLE"
local commandaction="Console"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
fn_print_header
fn_print_information_nl "Press \"CTRL+b\" then \"d\" to exit console."
fn_print_warning_nl "Do NOT press CTRL+c to exit."
echo ""
while true; do
	read -e -i "y" -p "Continue? [Y/n]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo Exiting; return;;
	* ) echo "Please answer yes or no.";;
esac
done
fn_print_dots "Accessing console"
sleep 1
check_status.sh
if [ "${status}" != "0" ]; then
	fn_print_ok_nl "Accessing console"
	fn_script_log_pass "Console accessed"
	sleep 1
	tmux attach-session -t ${servicename}
	fn_print_ok_nl "Closing console"
	fn_script_log_pass "Console closed"
else
	fn_print_error_nl "Server not running"
	fn_script_log_error "Failed to access: Server not running"
	sleep 1
	while true; do
		read -e -i "y" -p  "Do you want to start the server? [Y/n]" yn
		case $yn in
		[Yy]* ) exitbypass=1; command_start.sh; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi

core_exit.sh
