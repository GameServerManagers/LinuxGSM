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
sleep 0.5
# Create LinuxGSM logs
echo -ne "installing log dir: ${logdir}..."

if mkdir -p "${logdir}"; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi

echo -ne "installing LinuxGSM log dir: ${lgsmlogdir}..."

if mkdir -p "${lgsmlogdir}"; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
echo -ne "creating LinuxGSM log: ${lgsmlog}..."

if touch "${lgsmlog}"; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
# Create Console logs
if [ -n "${consolelogdir}" ]; then
	echo -ne "installing console log dir: ${consolelogdir}..."

	if mkdir -p "${consolelogdir}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
	echo -ne "creating console log: ${consolelog}..."

	if touch "${consolelog}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
fi

# Create Game logs
if [ -n "${gamelogdir}" ]&&[ ! -d "${gamelogdir}" ]; then
	echo -ne "installing game log dir: ${gamelogdir}..."
	if mkdir -p "${gamelogdir}"; then
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
	if [ "${gamelogdir:0:${#logdir}}" != "${logdir}" ]; then
		echo -ne "creating symlink to game log dir: ${logdir}/server -> ${gamelogdir}..."
		if ln -nfs "${gamelogdir}" "${logdir}/server"; then
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

		if ln -nfs "${rootdir}/Steam/logs" "${logdir}/steamcmd"; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	fi
fi
sleep 0.5
fn_script_log_info "Logs installed"
