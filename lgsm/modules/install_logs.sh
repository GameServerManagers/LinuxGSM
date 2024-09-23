#!/bin/bash
# LinuxGSM install_logs.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates log directories.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${checklogs}" != "1" ]; then
	echo -e ""
	echo -e "${bold}${lightyellow}Creating Log Directories${default}"
	fn_messages_separator
fi
# Create LinuxGSM logs.
echo -en "installing log dir: ${logdir}..."
mkdir -p "${logdir}"
if [ $? != 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi

echo -en "installing LinuxGSM log dir: ${lgsmlogdir}..."
mkdir -p "${lgsmlogdir}"
if [ $? != 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
echo -en "creating LinuxGSM log: ${lgsmlog}..."
touch "${lgsmlog}"
if [ $? != 0 ]; then
	fn_print_fail_eol_nl
	core_exit.sh
else
	fn_print_ok_eol_nl
fi
# Create Console logs.
if [ "${consolelogdir}" ]; then
	echo -en "installing console log dir: ${consolelogdir}..."
	mkdir -p "${consolelogdir}"
	if [ $? != 0 ]; then
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
if [ "${gamelogdir}" ] && [ ! -d "${gamelogdir}" ]; then
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
if [ -d "${HOME}/.steam/steam/logs" ]; then
	if [ ! -L "${logdir}/steam" ]; then
		echo -en "creating symlink to steam log dir: ${logdir}/steam -> ${HOME}/.steam/steam/logs..."
		if ! ln -nfs "${HOME}/.steam/steam/logs" "${logdir}/steam"; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	fi
fi
fn_script_log_info "Logs installed"
