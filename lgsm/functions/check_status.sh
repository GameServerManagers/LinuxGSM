#!/bin/bash
# LinuxGSM check_status.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Checks the process status of the server. Either online or offline.

local commandname="CHECK"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${gamename}" == "TeamSpeak 3" ]; then
	# 1: Server is running
	# 0: Server seems to have died
	# 0: No server running (ts3server.pid is missing)
	status=$("${executabledir}/ts3server_startscript.sh" status servercfgfullpathfile=${servercfgfullpath})
	if [ "${status}" == "Server is running" ]; then
		status=1
	else
		ts3error="${status}"
		status=0
	fi

elif [ "${gamename}" == "Mumble" ]; then
	# Get config info
	info_config.sh
	# 1: Server is listening
	# 0: Server is not listening, considered closed
	mumblepid=$(netstat -nap  2>/dev/null | grep udp | grep "${port}" | grep murmur | awk '{ print $6 }' | awk -F'/' '{ print $1 }')
	if [ -z "${mumblepid}" ]; then
		status=0
	else
		status=1
	fi
else
	status=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -Ecx "^${servicename}")
	serverpid=$(ps -ef | grep $(whoami) | grep "tmux new-session" |  grep -w "${servicename}" | awk '{print $2}' 2>/dev/null)
fi
