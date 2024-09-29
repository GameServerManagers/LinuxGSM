#!/bin/bash
# LinuxGSM command_debug.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Runs the server without tmux and directly from the terminal.

commandname="DEBUG"
commandaction="Debuging"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

# Trap to remove lockfile on quit.
fn_lockfile_trap() {
	# Remove lockfile.
	rm -f "${lockdir:?}/${selfname}-started.lock"
	# resets terminal. Servers can sometimes mess up the terminal on exit.
	reset
	fn_print_dots "Stopping debug"
	fn_print_ok_nl "Stopping debug"
	fn_script_log_pass "Stopping debug"
	# remove trap.
	trap - INT
	core_exit.sh
}

check.sh
fix.sh
info_distro.sh
info_game.sh
fn_print_header
{
	echo -e "${lightblue}Distro:\t\t${default}${distroname}"
	echo -e "${lightblue}Architecture:\t\t${default}${arch}"
	echo -e "${lightblue}Kernel:\t\t${default}${kernel}"
	echo -e "${lightblue}Hostname:\t\t${default}${HOSTNAME}"
	echo -e "${lightblue}tmux:\t\t${default}${tmuxversion}"
	echo -e "${lightblue}Avg Load:\t\t${default}${load}"
	echo -e "${lightblue}Free Memory:\t\t${default}${physmemfree}"
	echo -e "${lightblue}Free Disk:\t\t${default}${availspace}"
} | column -s $'\t' -t

# glibc required.
if [ -n "${glibc}" ]; then
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

# Server IP.
echo -e "${lightblue}Game Server IP:\t${default}${ip}:${port}"

# External server IP.
if [ "${publicip}" ]; then
	if [ "${ip}" != "${publicip}" ]; then
		echo -e "${lightblue}Internet IP:\t${default}${publicip}:${port}"
	fi
fi

# Server password.
if [ "${serverpassword}" ]; then
	echo -e "${lightblue}Server password:\t${default}${serverpassword}"
fi

fn_reload_startparameters
echo -e "${lightblue}Start parameters:${default}"
if [ "${engine}" == "source" ] || [ "${engine}" == "goldsrc" ]; then
	echo -e "${executable} ${startparameters} -debug"
elif [ "${engine}" == "quake" ]; then
	echo -e "${executable} ${startparameters} -condebug"
else
	echo -e "${preexecutable} ${executable} ${startparameters}"
fi
echo -e ""
echo -e "Use debug for identifying server issues only!"
echo -e "Press CTRL+c to drop out of debug mode."
fn_print_warning_nl "If ${selfname} is already running it will be stopped."

if ! fn_prompt_yn "Continue?" Y; then
	exitcode=0
	core_exit.sh
fi

fn_print_info_nl "Stopping any running servers"
fn_script_log_info "Stopping any running servers"
exitbypass=1
command_stop.sh
fn_firstcommand_reset
unset exitbypass
fn_print_dots "Starting debug"
fn_script_log_info "Starting debug"
fn_print_ok_nl "Starting debug"

# Create started lockfile.
date '+%s' > "${lockdir:?}/${selfname}-started.lock"
echo "${version}" >> "${lockdir}/${selfname}-started.lock"
echo "${port}" >> "${lockdir}/${selfname}-started.lock"
fn_script_log_info "Lockfile generated"
fn_script_log_info "${lockdir}/${selfname}-started.lock"

if [ "${shortname}" == "av" ]; then
	cd "${systemdir}" || exit
else
	cd "${executabledir}" || exit
fi

# Note: do not add double quotes to ${executable} ${startparameters}.
if [ "${engine}" == "source" ] || [ "${engine}" == "goldsrc" ]; then
	eval "${executable} ${startparameters} -debug"
elif [ "${engine}" == "quake" ]; then
	eval "${executable} ${startparameters} -condebug"
else
	# shellcheck disable=SC2086
	eval "${preexecutable} ${executable} ${startparameters}"
fi

if [ $? -ne 0 ]; then
	fn_print_error_nl "Server has stopped: exit code: $?"
	fn_script_log_error "Server has stopped: exit code: $?"
	fn_print_error_nl "Press ENTER to exit debug mode"
	read -r
else
	fn_print_ok_nl "Server has stopped"
	fn_script_log_pass "Server has stopped"
	fn_print_ok_nl "Press ENTER to exit debug mode"
	read -r
fi

fn_lockfile_trap

fn_print_dots "Stopping debug"
fn_print_ok_nl "Stopping debug"
fn_script_log_info "Stopping debug"

core_exit.sh
