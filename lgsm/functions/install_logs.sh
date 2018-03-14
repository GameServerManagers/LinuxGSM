#!/bin/bash
# LinuxGSM install_logs.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Creates log directories.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${checklogs}" != "1" ]; then
	echo ""
	echo "Creating log directories"
	echo "================================="
fi
sleep 1
# Create LinuxGSM logs
echo -ne "installing log dir: ${logdir}..."
mkdir -p "${logdir}"
if [ $? -ne 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi

echo -ne "installing LinuxGSM log dir: ${lgsmlogdir}..."
mkdir -p "${lgsmlogdir}"
if [ $? -ne 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
echo -ne "creating LinuxGSM log: ${lgsmlog}..."
touch "${lgsmlog}"
if [ $? -ne 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
# Create Console logs
if [ -n "${consolelogdir}" ]; then
	echo -ne "installing console log dir: ${consolelogdir}..."
	mkdir -p "${consolelogdir}"
	if [ $? -ne 0 ]; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
	echo -ne "creating console log: ${consolelog}..."
	touch "${consolelog}"
	if [ $? -ne 0 ]; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
fi

# Create Game logs
if [ -n "${gamelogdir}" ]&&[ ! -d "${gamelogdir}" ]; then
	echo -ne "installing game log dir: ${gamelogdir}..."
	mkdir -p "${gamelogdir}"
	if [ $? -ne 0 ]; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
fi

# Symlink to gamelogdir
# unless gamelogdir is within logdir
# e.g serverfiles/log is not within log/: symlink created
# log/server is in log/: symlink not created
if [ -n "${gamelogdir}" ]; then
	if [ "${gamelogdir:0:${#logdir}}" != "${logdir}" ];then
		echo -ne "creating symlink to game log dir: ${logdir}/server -> ${gamelogdir}..."
		ln -nfs "${gamelogdir}" "${logdir}/server"
		if [ $? -ne 0 ]; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	fi
fi

# If server uses SteamCMD create a symbolic link to the Steam logs
if [ -d "${rootdir}/Steam/logs" ]; then
	if [ ! -L "${logdir}/steamcmd" ]; then
		echo -ne "creating symlink to steam log dir: ${logdir}/steamcmd -> ${rootdir}/Steam/logs..."
		ln -nfs "${rootdir}/Steam/logs" "${logdir}/steamcmd"
		if [ $? -ne 0 ]; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	fi
fi
sleep 1
fn_script_log_info "Logs installed"
