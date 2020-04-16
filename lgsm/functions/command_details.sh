#!/bin/bash
# LinuxGSM command_details.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Displays server information.

local modulename="DETAILS"
local commandaction="Details"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Run checks and gathers details to display.
check.sh
info_config.sh
info_parms.sh
info_distro.sh
info_messages.sh
query_gamedig.sh
fn_info_message_distro
fn_info_message_server_resource
fn_info_message_gameserver_resource
fn_info_message_gameserver
fn_info_message_script
fn_info_message_backup
# Some game servers do not have parms.
if [ "${shortname}" != "ts3" ]&&[ "${shortname}" != "jc2" ]&&[ "${shortname}" != "dst" ]&&[ "${shortname}" != "pz" ]&&[ "${engine}" != "renderware" ]; then
	fn_parms
	fn_info_message_commandlineparms
fi
fn_info_message_ports
fn_info_message_select_engine
fn_info_message_statusbottom

core_exit.sh
