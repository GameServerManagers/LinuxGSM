#!/bin/bash
# LinuxGSM check_ip.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Automatically identifies the server interface IP.
# If multiple interfaces are detected the user will need to manually set using ip="0.0.0.0".

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_config.sh
info_parms.sh

if [ ! -f "/bin/ip" ]; then
	ipcommand="/sbin/ip"
else
	ipcommand="ip"
fi
getip=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|sort -u|grep -v 127.0.0)
getipwc=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|sort -u|grep -vc 127.0.0)
# Check if server has m ultiple IP addresses

# If the IP variable has been set by user.
if [ -n "${ip}" ]; then
	queryips=( "${ip}" )
# If game server IP is set IP address in game config.
elif [ -n "${configip}" ]; then
	queryips=( "${configip}" )
	ip="${configip}"
# If IP has not been set by user.
else
	queryips=( $(echo "${getip}") )
fi
