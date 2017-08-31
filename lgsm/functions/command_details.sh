#!/bin/bash
# LinuxGSM command_details.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Displays server information.

local commandname="DETAILS"
local commandaction="Details"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Run checks and gathers details to display.

fn_display_details() {
	check.sh
	info_config.sh
	info_distro.sh
	info_glibc.sh
	info_parms.sh
	info_messages.sh
	info_message_distro
	info_message_performance
	info_message_disk
	info_message_gameserver
	info_message_script
	info_message_backup
	# Some game servers do not have parms.
	if [ "${gamename}" != "TeamSpeak 3" ]&&[ "${engine}" != "avalanche" ]&&[ "${engine}" != "dontstarve" ]&&[ "${engine}" != "projectzomboid" ]&&[ "${engine}" != "renderware" ]; then
		fn_parms
		info_message_commandlineparms
	fi
	info_message_ports

	# Display details depending on game or engine.
	if [ "${engine}" == "avalanche" ]; then
		info_message_avalanche
	elif [ "${engine}" == "refractor" ]; then
		info_message_refractor
	elif [ "${engine}" == "dontstarve" ]; then
		info_message_dontstarve
	elif [ "${engine}" == "goldsource" ]; then
		info_message_goldsource
	elif [ "${engine}" == "lwjgl2" ]; then
		info_message_minecraft
	elif [ "${engine}" == "projectzomboid" ]; then
		info_message_projectzomboid
	elif [ "${engine}" == "realvirtuality" ]; then
		info_message_realvirtuality
	elif [ "${engine}" == "seriousengine35" ]; then
		info_message_seriousengine35
	elif [ "${engine}" == "source" ]; then
		info_message_source
	elif [ "${engine}" == "spark" ]; then
		info_message_spark
	elif [ "${engine}" == "starbound" ]; then
		info_message_starbound
	elif [ "${engine}" == "teeworlds" ]; then
		info_message_teeworlds
	elif [ "${engine}" == "terraria" ]; then
		info_message_terraria
	elif [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
		info_message_unreal
	elif [ "${engine}" == "unreal3" ]; then
		info_message_ut3
	elif [ "${gamename}" == "7 Days To Die" ]; then
		info_message_sdtd
	elif [ "${gamename}" == "ARK: Survival Evolved" ]; then
		info_message_ark
	elif [ "${gamename}" == "Ballistic Overkill" ]; then
		info_message_ballisticoverkill
	elif [ "${gamename}" == "Call of Duty" ]; then
		info_message_cod
	elif [ "${gamename}" == "Call of Duty: United Offensive" ]; then
		info_message_coduo
	elif [ "${gamename}" == "Call of Duty 2" ]; then
		info_message_cod2
	elif [ "${gamename}" == "Call of Duty 4" ]; then
		info_message_cod4
	elif [ "${gamename}" == "Call of Duty: World at War" ]; then
		info_message_codwaw
	elif [ "${gamename}" == "Factorio" ]; then
		info_message_factorio
	elif [ "${gamename}" == "Hurtworld" ]; then
		info_message_hurtworld
	elif [ "${gamename}" == "Project Cars" ]; then
		info_message_projectcars
	elif [ "${gamename}" == "QuakeWorld" ]; then
		info_message_quake
	elif [ "${gamename}" == "Quake 2" ]; then
		info_message_quake2
	elif [ "${gamename}" == "Quake 3: Arena" ]; then
		info_message_quake3
	elif [ "${gamename}" == "Quake Live" ]; then
		info_message_quakelive
	elif [ "${gamename}" == "Squad" ]; then
		info_message_squad
	elif [ "${gamename}" == "TeamSpeak 3" ]; then
		info_message_teamspeak3
	elif [ "${gamename}" == "Tower Unite" ]; then
		info_message_towerunite
	elif [ "${gamename}" == "Multi Theft Auto" ]; then
		info_message_mta
	elif [ "${gamename}" == "Mumble" ]; then
		info_message_mumble
	elif [ "${gamename}" == "Rust" ]; then
		info_message_rust
	elif [ "${gamename}" == "Wolfenstein: Enemy Territory" ]; then
		info_message_wolfensteinenemyterritory
	else
		fn_print_error_nl "Unable to detect server engine."
	fi
	info_message_statusbottom
}

if [ -z "${postdetails}" ] ;
then
  fn_display_details
  core_exit.sh
fi
