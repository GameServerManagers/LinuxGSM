#!/bin/bash
# LinuxGSM check_ip.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Automatically identifies the server interface IP.
# If multiple interfaces are detected the user will need to manually set using ip="0.0.0.0".

local modulename="CHECK"

if [ "${travistest}" != "1" ]; then
	if [ ! -f "/bin/ip" ]; then
		ipcommand="/sbin/ip"
	else
		ipcommand="ip"
	fi
	getip=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|sort -u|grep -v 127.0.0)
	getipwc=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}'|sort -u|grep -vc 127.0.0)
	info_config.sh
	info_parms.sh

	# IP is not set to specific IP.
	if [ "${ip}" == "0.0.0.0" ]||[ "${ip}" == "" ]; then
		fn_print_dots "Check IP"
		# Multiple interfaces.
		if [ "${getipwc}" -ge "2" ]; then
			if [ "${function_selfname}" == "command_details.sh" ]; then
			    fn_print_warn "Check IP: Multiple IP addresses found."
			else
			    fn_print_fail "Check IP: Multiple IP addresses found."
			fi
			echo -en "\n"
			# IP is set within game config.
			if [ "${ipsetinconfig}" == "1" ]; then
				fn_print_information "Specify the IP you want to bind within ${servercfg}.\n"
				echo -en "	* location: ${servercfgfullpath}\n"
				echo -en "\n"
				echo -en "Set ${ipinconfigvar} to one of the following:\n"
				fn_script_log_fatal "Multiple IP addresses found."
				fn_script_log_fatal "Specify the IP you want to bind within: ${servercfgfullpath}."
			# IP is set within LinuxGSM config.
			else
				fn_print_information_nl "Specify the IP you want to bind within a LinuxGSM config file.\n"
				echo -en "	* location: ${configdirserver}\n"
				echo -en "\n"
				echo -en "Set ip=\"0.0.0.0\" to one of the following:\n"
				fn_script_log_fatal "Multiple IP addresses found."
				if [ "${legacymode}" == "1" ]; then
					fn_script_log_fatal "Specify the IP you want to bind within the ${selfname} script."
				else
					fn_script_log_fatal "Specify the IP you want to bind within: ${configdirserver}."
				fi
			fi
			echo -en "${getip}\n"
			echo -en "\n"
			echo -en "https://linuxgsm.com/network-interfaces\n"
			echo -en ""
			# Do not exit for details and postdetails commands.
			if [ "${function_selfname}" != "command_details.sh" ]||[ "${function_selfname}" != "command_postdetails.sh" ]; then
				fn_script_log_fatal "https://linuxgsm.com/network-interfaces\n"
				core_exit.sh
			else
				ip="NOT SET"
			fi
		# Single interface.
		elif [ "${ipsetinconfig}" == "1" ]; then
			fn_print_fail "Check IP: IP address not set in game config."
			echo -en "\n"
			fn_print_information "Specify the IP you want to bind within ${servercfg}.\n"
			echo -en "	* location: ${servercfgfullpath}\n"
			echo -en "\n"
			echo -en "Set ${ipinconfigvar} to the following:\n"
			echo -en "${getip}\n"
			echo -en "\n"
			echo -en "https://linuxgsm.com/network-interfaces\n"
			echo -en ""
			fn_script_log_fatal "IP address not set in game config."
			fn_script_log_fatal "Specify the IP you want to bind within: ${servercfgfullpath}."
			fn_script_log_fatal "https://linuxgsm.com/network-interfaces\n"
			if [ "${function_selfname}" != "command_details.sh" ]; then
			    core_exit.sh
			fi
		else
			fn_print_info_nl "Check IP: ${getip}"
			fn_script_log_info "IP automatically set as: ${getip}"
			ip="${getip}"
		fi
	fi
fi
