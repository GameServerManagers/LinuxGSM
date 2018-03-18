#!/bin/bash
# LinuxGSM command_details.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Displays server information.

local commandname="DETAILS"
local commandaction="Details"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Run checks and gathers details to display.
check.sh
info_config.sh
info_distro.sh
info_glibc.sh
info_parms.sh
info_messages.sh
fn_info_message_distro
fn_info_message_performance
fn_info_message_disk
fn_info_message_gameserver
fn_info_message_script
fn_info_message_backup
# Some game servers do not have parms.
if [ "${gamename}" != "TeamSpeak 3" ]&&[ "${engine}" != "avalanche2.0" ]&&[ "${engine}" != "dontstarve" ]&&[ "${engine}" != "projectzomboid" ]&&[ "${engine}" != "renderware" ]; then
	fn_parms
	fn_info_message_commandlineparms
fi
fn_info_message_ports
fn_info_message_select_engine
fn_info_message_statusbottom
core_exit.sh

