#!/bin/bash
# LGSM check_ip.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Automatically identifies the server interface IP.
# If multiple interfaces are detected the user will need to manually set using ip="0.0.0.0".

local commandname="CHECK"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ "${gamename}" != "TeamSpeak 3" ] && [ "${gamename}" != "Mumble" ]; then
	if [ ! -f "/bin/ip" ]; then
		ipcommand="/sbin/ip"
	else
		ipcommand="ip"
	fi
	getip=$(${ipcommand} -o -4 addr|awk '{print $4}'|grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|grep -v 127.0.0)
	getipwc=$(${ipcommand} -o -4 addr|awk '{print $4}'|grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|grep -vc 127.0.0)

	if [ "${ip}" == "0.0.0.0" ]||[ "${ip}" == "" ]; then
		if [ "${getipwc}" -ge "2" ]; then
			fn_print_dots "Check IP"
			sleep 1
			fn_print_fail "Check IP: Multiple active network interfaces found."
			sleep 1
			echo -en "\n"
			fn_print_information "Specify the IP you want to use within the ${selfname} script.\n"
			echo -en "Set ip=\"0.0.0.0\" to one of the following:\n"
			echo -en "${getip}\n"
			echo -en ""
			echo -en "https://gameservermanagers.com/network-interfaces\n"
			echo -en ""
			fn_script_log_fatal "Multiple active network interfaces found."
			fn_script_log_fatal "Manually specify the IP you want to use within the ${selfname} script."
			fn_script_log_fatal "https://gameservermanagers.com/network-interfaces\n"
			core_exit.sh
		else
			ip=${getip}
		fi
	fi
fi
