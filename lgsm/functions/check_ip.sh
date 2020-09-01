#!/bin/bash
# LinuxGSM check_ip.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Automatically identifies the server interface IP.
# If multiple interfaces are detected the user will need to manually set using ip="0.0.0.0".

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_config.sh
info_distro.sh # for dev
info_parms.sh

if [ ! -f "/bin/ip" ]; then
	ipcommand="/sbin/ip"
else
	ipcommand="ip"
fi
getip=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|sort -u|grep -v 127.0.0)
getipwc=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|sort -u|grep -vc 127.0.0)
# Check if server has m ultiple IP addresses

# If the ip variable is set by user
if [ "${ip}" != "0.0.0.0" ]&&[ "${ip}" != "" ]; then
	queryips=( "${ip}" )
# If ip is not set by user
else
	queryips=( "${getip}" )
fi

echo "###### DEV IP CHECK ######"
echo "IP: ${ip}"
echo "EXTIP: ${extip}"
echo "DISPLAYIP: ${displayip}"
echo "QUERYIP: ${queryip}"
