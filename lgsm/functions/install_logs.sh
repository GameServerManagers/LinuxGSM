#!/bin/bash
# LinuxGSM install_logs.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates log directories.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ "${checklogs}" != "1" ]; then
	echo ""
	echo "Creating log directories"
	echo "================================="
fi
sleep 1
# Create dir's for the script and console logs
if [ ! -d "${rootdir}/log" ]; then
	mkdir -v "${rootdir}/log"
fi
if [ ! -d "${scriptlogdir}" ]; then
	mkdir -v "${scriptlogdir}"
fi
if [ ! -f "${scriptlog}" ]; then
	touch "${scriptlog}"
fi
if [ -n "${consolelogdir}" ]; then
	if [ ! -d "${consolelogdir}" ]; then
		mkdir -v "${consolelogdir}"
	fi
	if [ ! -f "${consolelog}" ]; then
		touch "${consolelog}"
	fi
fi

# If a server is source or goldsource, TeamSpeak 3, Starbound, Project Zomhoid create a symbolic link to the game server logs.
if [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]||[ "${gamename}" == "TeamSpeak 3" ]||[ "${engine}" == "starbound" ]||[ "${engine}" == "projectzomboid" ]||[ "${engine}" == "unreal" ]; then
	if [ ! -h "${rootdir}/log/server" ]; then
		ln -nfsv "${gamelogdir}" "${rootdir}/log/server"
	fi
fi

# If a server is unreal2 or unity3d create a dir.
if [ "${engine}" == "unreal2" ]||[ "${engine}" == "unity3d" ]||[ "${gamename}" == "Teeworlds" ]||[ "${gamename}" == "seriousengine35" ]; then
	if [ ! -d "${gamelogdir}" ]; then
		mkdir -pv "${gamelogdir}"
	fi
fi

# If server uses SteamCMD create a symbolic link to the Steam logs.
if [ -d "${rootdir}/Steam/logs" ]; then
	if [ ! -h "${rootdir}/log/steamcmd" ]; then
		ln -nfsv "${rootdir}/Steam/logs" "${rootdir}/log/steamcmd"
	fi
fi
sleep 1
fn_script_log_info "Logs installed"
