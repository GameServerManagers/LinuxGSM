#!/bin/bash
# LGSM command_console.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Gives access to the server tmux console.

local modulename="Console"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
echo ""
echo "${gamename} Console"
echo "============================"
echo ""
echo "Press \"CTRL+b d\" to exit console."
fn_printwarningnl "Do NOT press CTRL+c to exit."
echo ""
while true; do
	read -e -i "y" -p "Continue? [y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo Exiting; return;;
	* ) echo "Please answer yes or no.";;
esac
done
fn_printdots "Starting"
sleep 1
tmuxwc=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -v failed|grep -Ec "^${servicename}:")
if [ "${tmuxwc}" -eq 1 ]; then
	fn_printoknl "Starting"
	fn_scriptlog "accessed"
	sleep 1
	tmux attach-session -t ${servicename}
else
	fn_printfailnl "Server not running"
	fn_scriptlog "Failed to access: Server not running"
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
