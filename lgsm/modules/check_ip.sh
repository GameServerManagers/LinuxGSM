#!/bin/bash
# LinuxGSM check_ip.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Automatically identifies the server interface IP.
# If multiple interfaces are detected the user will need to manually set using ip="0.0.0.0".

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_game.sh

ip_commands_array=("ip" "/bin/ip" "/usr/sbin/ip")
for ip_command in "${ip_commands_array[@]}"; do
	if [ "$(command -v "${ip_command}" 2> /dev/null)" ]; then
		ipcommand="${ip_command}"
		break
	fi
done

ethtool_commands_array=("ethtool" "/bin/ethtool" "/usr/sbin/ethtool")
for ethtool_command in "${ethtool_commands_array[@]}"; do
	if [ "$(command -v "${ethtool_command}" 2> /dev/null)" ]; then
		ethtoolcommand="${ethtool_command}"
		break
	fi
done

mapfile -t current_ips < <(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}' | sort -u | grep -v 127.0.0)

function fn_is_valid_ip() {
	local ip="${1}"
	# excluding 0.* ips also
	grep -qEe '^[1-9]+[0-9]*\.[0-9]+\.[0-9]+\.[0-9]+$' <<< "${ip}"
}

# Check if server has multiple IP addresses.

# If the IP variable has been set by user.
if fn_is_valid_ip "${ip}"; then
	queryips=("${ip}" "${publicip}")
	httpip=("${ip}")
	telnetip=("${ip}")
# If the game config has an IP set.
elif fn_is_valid_ip "${configip}"; then
	queryips=("${configip}" "${publicip}")
	ip="${configip}"
	httpip=("${configip}")
	telnetip=("${configip}")
# If there is only 1 server IP address.
# Some IP details can automatically use the one IP.
elif [ "${#current_ips[@]}" == "1" ]; then
	queryips=("127.0.0.1" "${current_ips[@]}" "${publicip}")
	ip="0.0.0.0"
	httpip=("${current_ips[@]}")
	telnetip=("${current_ips[@]}")
# If no ip is set by the user and server has more than one IP.
else
	queryips=("127.0.0.1" "${current_ips[@]}" "${publicip}")
	ip="0.0.0.0"
	httpip=("${ip}")
	telnetip=("${ip}")
fi
