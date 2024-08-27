#!/bin/bash
# LinuxGSM command_install.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Overall module for the installer.

commandname="INSTALL"
commandaction="Installing"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
if [ "$(whoami)" == "root" ]; then
	check_deps.sh
else
	install_header.sh
	install_server_dir.sh
	install_logs.sh
	check_deps.sh
	installflag=1
	# Download and install.
	if [ "${shortname}" == "ut2k4" ]; then
		install_server_files.sh
		install_ut2k4_key.sh
	elif [ -z "${appid}" ]; then
		install_server_files.sh
	elif [ "${appid}" ]; then
		install_steamcmd.sh
		install_server_files.sh
	fi

	# Install gamedig
	check_gamedig.sh

	# Configuration.
	install_config.sh
	if [ -v gslt ]; then
		install_gslt.sh
	elif [ "${shortname}" == "dst" ]; then
		install_dst_token.sh
	elif [ "${shortname}" == "squad" ]; then
		install_squad_license.sh
	elif [ "${shortname}" == "ts3" ]; then
		install_ts3db.sh
	elif [ "${shortname}" == "mta" ]; then
		command_install_resources_mta.sh
		fn_firstcommand_reset
	fi

	fix.sh
	install_stats.sh
	install_complete.sh
fi
core_exit.sh
