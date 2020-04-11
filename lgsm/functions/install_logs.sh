#!/bin/bash
# LinuxGSM install_logs.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Creates log directories.

local modulename="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${checklogs}" != "1" ]; then
	echo -e ""
	echo -e "${lightyellow}Creating log directories${default}"
	echo -e "================================="
fi
fn_sleep_time
# Create LinuxGSM logs.
echo -en "installing log dir: ${logdir}..."
mkdir -p "${logdir}"
if [ $? -ne 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi

echo -en "installing LinuxGSM log dir: ${lgsmlogdir}..."
mkdir -p "${lgsmlogdir}"
if [ $? -ne 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
echo -en "creating LinuxGSM log: ${lgsmlog}..."
touch "${lgsmlog}"
if [ $? -ne 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
# Create Console logs.
if [ "${consolelogdir}" ]; then
	echo -en "installing console log dir: ${consolelogdir}..."
	mkdir -p "${consolelogdir}"
	if [ $? -ne 0 ]; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
	echo -en "creating console log: ${consolelog}..."
	if ! touch "${consolelog}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
fi

# Create Game logs.
if [ "${gamelogdir}" ]&&[ ! -d "${gamelogdir}" ]; then
	echo -en "installing game log dir: ${gamelogdir}..."
	if ! mkdir -p "${gamelogdir}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
fi

# Symlink to gamelogdir
# unless gamelogdir is within logdir.
# e.g serverfiles/log is not within log/: symlink created
# log/server is in log/: symlink not created
if [ "${gamelogdir}" ]; then
	if [ "${gamelogdir:0:${#logdir}}" != "${logdir}" ]; then
		echo -en "creating symlink to game log dir: ${logdir}/server -> ${gamelogdir}..."
		if ! ln -nfs "${gamelogdir}" "${logdir}/server"; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	fi
fi

# If server uses SteamCMD create a symbolic link to the Steam logs.
if [ -d "${rootdir}/Steam/logs" ]; then
	if [ ! -L "${logdir}/steamcmd" ]; then
		echo -en "creating symlink to steam log dir: ${logdir}/steamcmd -> ${rootdir}/Steam/logs..."
		if ! ln -nfs "${rootdir}/Steam/logs" "${logdir}/steamcmd"; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	fi
fi
fn_sleep_time
fn_script_log_info "Logs installed"
