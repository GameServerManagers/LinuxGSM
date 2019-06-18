#!/usr/bin/env bash
# LinuxGSM command_debug.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Runs the server without tmux and directly from the terminal.

local commandname="DEBUG"
local commandaction="Debug"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Trap to remove lockfile on quit.
fn_lockfile_trap(){
	# Remove lockfile.
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
# NOTE: Check if works with server without parms. Could be intergrated in to info_parms.sh.
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

# glibc required.
if [ -n "${glibc}" ]; then
	if [ "${glibc}" == "null" ]; then
		# Glibc is not required.
		:
	elif [ -z "${glibc}" ]; then
		echo -e "${blue}glibc required:\t${red}UNKNOWN${default}"
	elif [ "$(printf '%s\n'${glibc}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibc}" ]; then
		echo -e "${blue}glibc required:\t${red}${glibc} ${default}(${red}distro glibc ${glibcversion} too old${default})"
	else
		echo -e "${blue}glibc required:\t${green}${glibc}${default}"
	fi
fi

# Server IP
if [ "${multiple_ip}" == "1" ]; then
	echo -e "${blue}Server IP:\t${default}NOT SET"
else
	echo -e "${blue}Server IP:\t${default}${ip}:${port}"
fi
# External server IP.
if [ -n "${extip}" ]; then
	if [ "${ip}" != "${extip}" ]; then
		echo -e "${blue}Internet IP:\t${default}${extip}:${port}"
	fi
fi
# Listed on Master Server.
if [ "${masterserver}" ];then
	if [ "${masterserver}" == "true" ];then
		echo -e "${blue}Master Server:\t${green}${masterserver}${default}"
	else
		echo -e "${blue}Master Server:\t${red}${masterserver}${default}"
	fi
fi
# Server password.
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
