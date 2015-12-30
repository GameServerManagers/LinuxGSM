#!/bin/bash
# LGSM command_debug.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Runs the server without tmux. Runs direct from the terminal.

local modulename="Debug"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
fix.sh
info_distro.sh
fn_parms
echo ""
echo "${gamename} Debug"
echo "============================"
echo ""
echo -e "Distro: ${os}"
echo -e "Arch: ${arch}"
echo -e "Kernel: ${kernel}"
echo -e "Hostname: $HOSTNAME"
echo ""
echo "Start parameters:"
if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	echo "${executable} ${parms} -debug"
else
	echo "${executable} ${parms}"
fi
echo ""
echo -e "Use for identifying server issues only!"
echo -e "Press CTRL+c to drop out of debug mode."
fn_printwarningnl "If ${servicename} is already running it will be stopped."
echo ""
while true; do
	read -e -i "y" -p "Continue? [Y/n]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo Exiting; return;;
	* ) echo "Please answer yes or no.";;
esac
done
fn_scriptlog "Starting debug"
fn_printinfonl "Stopping any running servers"
fn_scriptlog "Stopping any running servers"
sleep 1
command_stop.sh
fn_printdots "Starting debug"
sleep 1
fn_printok "Starting debug"
fn_scriptlog "Started debug"
sleep 1
echo -en "\n"
cd "${executabledir}"
fix.sh
if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	${executable} ${parms} -debug
else
	${executable} ${parms}
fi