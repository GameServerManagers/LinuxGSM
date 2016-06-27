#!/bin/bash
# LGSM command_debug.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Runs the server without tmux. Runs direct from the terminal.

local modulename="Debug"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Trap to remove lockfile on quit.
fn_lockfile_trap(){
	# Remove lock file
	rm -f "${rootdir}/${lockselfname}"
	core_exit.sh
}

check.sh
fix.sh
info_distro.sh
# NOTE: Check if works with server without parms. Could be intergrated in to info_parms.sh
fn_parms
echo ""
echo "${gamename} Debug"
echo "================================="
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
fn_print_warning_nl "If ${servicename} is already running it will be stopped."
echo ""
while true; do
	read -e -i "y" -p "Continue? [Y/n]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo Exiting; return;;
	* ) echo "Please answer yes or no.";;
esac
done

fn_print_info_nl "Stopping any running servers"
fn_script_log_info "Stopping any running servers"
sleep 1
exitbypass=1
command_stop.sh
fn_print_dots "Starting debug"
fn_script_log_info "Starting debug"
sleep 1
fn_print_ok_nl "Starting debug"

# create lock file.
date > "${rootdir}/${lockselfname}"
# trap to remove lockfile on quit.
trap fn_lockfile_trap INT

cd "${executabledir}"
if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	${executable} ${parms} -debug
else
	${executable} ${parms}
fi

# remove trap.
trap - INT
core_exit.sh