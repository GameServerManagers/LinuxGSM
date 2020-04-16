#!/bin/bash
# LinuxGSM command_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Overall function for the installer.

local modulename="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh
if [ "$(whoami)" = "root" ]; then
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
		installer=1
		install_server_files.sh
	elif [ "${appid}" ]; then
		install_steamcmd.sh
		install_server_files.sh
	fi

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
	fi

	fix.sh
	install_stats.sh
	install_complete.sh
fi
core_exit.sh
