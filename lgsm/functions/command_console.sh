#!/bin/bash
# LGSM command_console.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Gives access to the server tmux console.

local modulename="Console"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
echo ""
echo "${gamename} Console"
echo "================================="
echo ""
echo "Press \"CTRL+b d\" to exit console."
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
fn_print_dots "Starting"
sleep 1
check_status.sh
if [ "${status}" != "0" ]; then
	fn_print_ok_nl "Starting"
	fn_script_log_info "Accessed"
	sleep 1
	tmux attach-session -t ${servicename}
else
	fn_print_fail_nl "Server not running"
	fn_script_log_fatal "Failed to access: Server not running"
	sleep 1
	while true; do
		read -p "Do you want to start the server? [y/N]" yn
		case $yn in
		[Yy]* ) command_start.sh; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi
core_exit.sh
