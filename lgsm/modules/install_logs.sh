#!/bin/bash
# LinuxGSM install_logs.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates log directories.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -z "${checklogs}" ]; then
	echo -e ""
	echo -e "${bold}${lightyellow}Creating Log Directories${default}"
	fn_messages_separator
fi

echo -en "creating log directory [ ${italic}${logdir}${default} ]"
if [ ! -d "${logdir}" ]; then
	if ! mkdir -p "${logdir}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
else
	fn_print_skip_eol_nl
fi

echo -en "creating script log directory [ ${italic}${lgsmlogdir}${default} ]"
if [ ! -d "${lgsmlogdir}" ]; then
	if ! mkdir -p "${lgsmlogdir}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
else
	fn_print_skip_eol_nl
fi

echo -en "creating script log [ ${italic}${lgsmlog}${default} ]"
if [ ! -f "${lgsmlog}" ]; then
	if ! touch "${lgsmlog}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
else
	fn_print_skip_eol_nl
fi

echo -en "creating console log directory [ ${italic}${consolelogdir}${default} ]"
if [ ! -d "${consolelogdir}" ]; then
	if ! mkdir -p "${consolelogdir}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
else
	fn_print_skip_eol_nl
fi

echo -en "creating console log [ ${italic}${consolelog}${default} ]"
if [ ! -f "${consolelog}" ]; then
	if ! touch "${consolelog}"; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
else
	fn_print_skip_eol_nl
fi

if [ -n "${gamelogdir}" ]; then
	echo -en "creating game log directory [ ${italic}${gamelogdir}${default} ]"
	if [ ! -d "${gamelogdir}" ]; then
		if ! mkdir -p "${gamelogdir}"; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	else
		fn_print_skip_eol_nl
	fi
fi

# Symlink to gamelogdir
# unless gamelogdir is within logdir.
# e.g serverfiles/log is not within log/: symlink created
# log/server is in log/: symlink not created
if [ -n "${gamelogdir}" ] && [ "${gamelogdir:0:${#logdir}}" != "${logdir}" ]; then
	echo -en "creating symlink to game log directory [ ${italic}${logdir}/server -> ${gamelogdir}${default} ]"
	# if path does not exist or does not match gamelogdir
	if [ ! -h "${logdir}/server" ] || [ "$(readlink -f "${logdir}/server")" != "${gamelogdir}" ]; then
		if ! ln -nfs "${gamelogdir}" "${logdir}/server"; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	else
		fn_print_skip_eol_nl
	fi
fi

# If server uses SteamCMD create a symbolic link to the Steam logs.
if [ -d "${HOME}/.steam/steam/logs" ]; then
	echo -en "creating symlink to steam log directory [ ${italic}${logdir}/steam -> ${HOME}/.steam/steam/logs${default} ]"
	if [ ! -L "${logdir}/steam" ]; then
		if ! ln -nfs "${HOME}/.steam/steam/logs" "${logdir}/steam"; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
	else
		fn_print_skip_eol_nl
	fi
fi
fn_script_log_info "Logs installed"
