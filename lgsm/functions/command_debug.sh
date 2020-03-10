#!/bin/bash
# LinuxGSM command_debug.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Runs the server without tmux and directly from the terminal.

local modulename="DEBUG"
local commandaction="Debug"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

# Trap to remove lockfile on quit.
fn_lockfile_trap(){
	# Remove lockfile.
	rm -f "${rootdir:?}/${lockselfname}"
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
# NOTE: Check if works with server without parms. Could be intergrated in to info_parms.sh.
fn_parms
fn_print_header
{
	echo -e "${lightblue}Distro:\t\t${default}${distroname}"
	echo -e "${lightblue}Arch:\t\t${default}${arch}"
	echo -e "${lightblue}Kernel:\t\t${default}${kernel}"
	echo -e "${lightblue}Hostname:\t\t${default}${HOSTNAME}"
	echo -e "${lightblue}tmux:\t\t${default}${tmuxv}"
	echo -e "${lightblue}Avg Load:\t\t${default}${load}"
	echo -e "${lightblue}Free Memory:\t\t${default}${physmemfree}"
	echo -e "${lightblue}Free Disk:\t\t${default}${availspace}"
} | column -s $'\t' -t
# glibc required.
if [ "${glibc}" ]; then
	if [ "${glibc}" == "null" ]; then
		# Glibc is not required.
		:
	elif [ -z "${glibc}" ]; then
		echo -e "${lightblue}glibc required:\t${red}UNKNOWN${default}"
	elif [ "$(printf '%s\n'${glibc}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibc}" ]; then
		echo -e "${lightblue}glibc required:\t${red}${glibc} ${default}(${red}distro glibc ${glibcversion} too old${default})"
	else
		echo -e "${lightblue}glibc required:\t${green}${glibc}${default}"
	fi
fi

# Server IP
if [ "${multiple_ip}" == "1" ]; then
	echo -e "${lightblue}Server IP:\t${default}NOT SET"
else
	echo -e "${lightblue}Server IP:\t${default}${ip}:${port}"
fi
# External server IP.
if [ "${extip}" ]; then
	if [ "${ip}" != "${extip}" ]; then
		echo -e "${lightblue}Internet IP:\t${default}${extip}:${port}"
	fi
fi
# Listed on Master Server.
if [ "${displaymasterserver}" ]; then
	if [ "${displaymasterserver}" == "true" ]; then
		echo -e "${lightblue}Master Server:\t${green}${displaymasterserver}${default}"
	else
		echo -e "${lightblue}Master Server:\t${red}${displaymasterserver}${default}"
	fi
fi
# Server password.
if [ "${serverpassword}" ]; then
	echo -e "${lightblue}Server password:\t${default}${serverpassword}"
fi
echo -e "${lightblue}Start parameters:${default}"
if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	echo -e "${executable} ${parms} -debug"
else
	echo -e "${executable} ${parms}"
fi
echo -e ""
echo -e "Use for identifying server issues only!"
echo -e "Press CTRL+c to drop out of debug mode."
fn_print_warning_nl "If ${selfname} is already running it will be stopped."
echo -e ""
if ! fn_prompt_yn "Continue?" Y; then
	return
fi

fn_print_info_nl "Stopping any running servers"
fn_script_log_info "Stopping any running servers"
exitbypass=1
command_stop.sh
fn_print_dots "Starting debug"
fn_script_log_info "Starting debug"
fn_print_ok_nl "Starting debug"

# Create lockfile.
date '+%s' > "${rootdir}/${lockselfname}"
fn_script_log_info "Lockfile generated"
fn_script_log_info "${rootdir}/${lockselfname}"
# trap to remove lockfile on quit.
trap fn_lockfile_trap INT

cd "${executabledir}" || exit
# Note: do not add double quotes to ${executable} ${parms}.
if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	${executable} ${parms} -debug
elif [ "${engine}" == "realvirtuality" ]; then
	# Arma3 requires semicolons in the module list, which need to
	# be escaped for regular (tmux) loading, but need to be
	# stripped when loading straight from the console.
	${executable} ${parms//\\;/;}
elif [ "${engine}" == "quake" ]; then
    ${executable} ${parms} -condebug
else
	${executable} ${parms}
fi

fn_print_dots "Stopping debug"
fn_print_ok_nl "Stopping debug"
# remove trap.
trap - INT

core_exit.sh
