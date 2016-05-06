#!/bin/bash
# LGSM check_status function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="060516"

# Description: Checks the proccess status of the server. Either online or offline.

if [ "${gamename}" == "Teamspeak 3" ]; then
	# 1: Server is running
	# 0: Server seems to have died
	# 0: No server running (ts3server.pid is missing)
	status=$(${executabledir}/ts3server_startscript.sh status servercfgfullpathfile=${servercfgfullpath})
	if [ "${status}" == "Server is running" ]; then
		status=1
	else
		ts3error="${status}"
		status=0
	fi
else
	status=$(tmux list-sessions 2>&1 | awk '{print $1}' | grep -Ec "^${servicename}:")
fi
