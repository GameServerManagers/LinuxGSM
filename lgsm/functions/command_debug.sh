#!/bin/bash
# LinuxGSM command_debug.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Runs the server without tmux and directly from the terminal.

local commandname="DEBUG"
local commandaction="Debug"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Trap to remove lockfile on quit.
fn_lockfile_trap(){
	# Remove lockfile
	rm -f "${rootdir}/${lockselfname}"
	# resets terminal. Servers can sometimes mess up the terminal on exit.
	reset
	fn_print_ok_nl "Closing debug"
	fn_script_log_pass "Debug closed"
	core_exit.sh
}

check.sh
fix.sh
info_distro.sh
info_config.sh
# NOTE: Check if works with server without parms. Could be intergrated in to info_parms.sh
fn_parms
fn_print_header
echo -e "${blue}Distro:\t${default}${distroname}"
echo -e "${blue}Arch:\t${default}${arch}"
echo -e "${blue}Kernel:\t${default}${kernel}"
echo -e "${blue}Hostname:\t${default}${HOSTNAME}"
echo -e "${blue}tmux:\t${default}${tmuxv}"
echo -e "${blue}Avg Load:\t${default}${load}"
echo -e "${blue}Free Memory:\t${default}${physmemfree}"
echo -e "${blue}Free Disk:\t${default}${availspace}"
# GLIBC required
if [ -n "${glibcrequired}" ]; then
	if [ "${glibcrequired}" == "NOT REQUIRED" ]; then
			:
	elif [ "${glibcrequired}" == "UNKNOWN" ]; then
		echo -e "${blue}GLIBC required:\t${red}${glibcrequired}"
	elif [ "$(printf '%s\n'${glibcrequired}'\n' "${glibcversion}" | sort -V | head -n 1)" != "${glibcrequired}" ]; then
		if [ "${glibcfix}" == "yes" ]; then
			echo -e "${blue}GLIBC required:\t${red}${glibcrequired} ${default}(${green}Using GLIBC fix${default})"
		else
			echo -e "${blue}GLIBC required:\t${red}${glibcrequired} ${default}(${red}GLIBC distro version ${glibcversion} too old${default})"
		fi
	else
		echo -e "${blue}GLIBC required:\t${green}${glibcrequired}${default}"
	fi
fi
# Server ip
if [ "${multiple_ip}" == "1" ]; then
	echo -e "${blue}Server IP:\t${default}NOT SET"
else
	echo -e "${blue}Server IP:\t${default}${ip}:${port}"
fi
echo -e "${blue}Server IP:\t${default}${ip}:${port}"
# External server ip
if [ -n "${extip}" ]; then
	if [ "${ip}" != "${extip}" ]; then
		echo -e "${blue}Internet IP:\t${default}${extip}:${port}"
	fi
fi
# Server password
if [ -n "${serverpassword}" ]; then
	echo -e "${blue}Server password:\t${default}${serverpassword}"
fi
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
if ! fn_prompt_yn "Continue?" Y; then
	echo Exiting; return
fi

fn_print_info_nl "Stopping any running servers"
fn_script_log_info "Stopping any running servers"
sleep 0.5
exitbypass=1
command_stop.sh
fn_print_dots "Starting debug"
fn_script_log_info "Starting debug"
sleep 0.5
fn_print_ok_nl "Starting debug"

# Create lockfile
date > "${rootdir}/${lockselfname}"
fn_script_log_info "Lockfile generated"
fn_script_log_info "${rootdir}/${lockselfname}"
# trap to remove lockfile on quit.
trap fn_lockfile_trap INT

cd "${executabledir}" || exit
# Note: do not add double quotes to ${executable} ${parms}
if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	${executable} ${parms} -debug
elif [ "${engine}" == "realvirtuality" ]; then
	# Arma3 requires semicolons in the module list, which need to
	# be escaped for regular (tmux) loading, but need to be
	# stripped when loading straight from the console.
	${executable} ${parms//\\;/;}
else
	${executable} ${parms}
fi

fn_print_dots "Stopping debug"
sleep 1
fn_print_ok_nl "Stopping debug"
# remove trap.
trap - INT
core_exit.sh
