#!/bin/bash
# LinuxGSM alert_email.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends email alert.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_details_gameserver(){
	#
	# Quake Live Server Details
	# =====================================
	# Server name:      ql-server
	# Server IP:        1.2.3.4:27960
	# RCON password:    CHANGE_ME
	# Server password:  NOT SET
	# Maxplayers:		16
	# Status:           OFFLINE

	{
		echo -e ""
		echo -e "${gamename} Server Details"
		echo -e "================================="
		# Server name
		echo -e "Server name: ${servername}"

		# Server ip
		echo -e "Server IP: ${ip}:${port}"

		# Server password
		if [ -n "${serverpassword}" ]; then
			echo -e "Server password: ********"
		fi

		# RCON password
		if [ -n "${rconpassword}" ]; then
			echo -e "RCON password: ********"
		fi

		# Admin password
		if [ -n "${adminpassword}" ]; then
			echo -e "Admin password: ********"
		fi

		# Stats password (Quake Live)
		if [ -n "${statspassword}" ]; then
			echo -e "Stats password: ********"
		fi

		# Maxplayers
		if [ -n "${maxplayers}" ]; then
			echo -e "Maxplayers: ${maxplayers}"
		fi

		# Game mode
		if [ -n "${gamemode}" ]; then
			echo -e "Game mode: ${gamemode}"
		fi

		# Game world
		if [ -n "${gameworld}" ]; then
			echo -e "Game world: ${gameworld}"
		fi

		# Tick rate
		if [ -n "${tickrate}" ]; then
			echo -e "Tick rate: ${tickrate}"
		fi

		# TeamSpeak dbplugin
		if [ -n "${dbplugin}" ]; then
			echo -e "dbplugin: ${dbplugin}"
		fi

		# Online status
		if [ "${status}" == "0" ]; then
			echo -e "Status: OFFLINE"
		else
			echo -e "Status: ONLINE"
		fi
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1
}

fn_alert_email_template_logs(){
	echo -e ""
	echo -e "${servicename} Logs"
	echo -e "================================="

	if [ -n "${lgsmlog}" ]; then
		echo -e "\nScript log\n==================="
		if [ ! "$(ls -A ${lgsmlogdir})" ]; then
			echo "${lgsmlogdir} (NO LOG FILES)"
		elif [ ! -s "${lgsmlog}" ]; then
			echo "${lgsmlog} (LOG FILE IS EMPTY)"
		else
			echo "${lgsmlog}"
			tail -25 "${lgsmlog}"
		fi
		echo ""
	fi

	if [ -n "${consolelog}" ]; then
		echo -e "\nConsole log\n===================="
		if [ ! "$(ls -A ${consolelogdir})" ]; then
			echo "${consolelogdir} (NO LOG FILES)"
		elif [ ! -s "${consolelog}" ]; then
			echo "${consolelog} (LOG FILE IS EMPTY)"
		else
			echo "${consolelog}"
			tail -25 "${consolelog}" | awk '{ sub("\r$", ""); print }'
		fi
		echo ""
	fi

	if [ -n "${gamelogdir}" ]; then
		echo -e "\nServer log\n==================="
		if [ ! "$(ls -A ${gamelogdir})" ]; then
			echo "${gamelogdir} (NO LOG FILES)"
		else
			echo "${gamelogdir}"
			# dos2unix sed 's/\r//'
			tail "${gamelogdir}"/* 2>/dev/null | grep -v "==>" | sed '/^$/d' | sed 's/\r//'| tail -25
		fi
		echo ""
	fi
}

fn_print_dots "Sending Email alert: ${email}"
sleep 0.5
fn_script_log_info "Sending Email alert: ${email}"
info_distro.sh
info_config.sh
info_glibc.sh

check_ip.sh
postdetails=1
info_messages.sh
emaillog="${emaillog}"
if [ -f "${emaillog}" ]; then
	rm "${emaillog}"
fi

{
	fn_details_head
	fn_message_os
	fn_message_performance
	fn_message_disk
	fn_message_gameserver
	fn_alert_email_template_logs
} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1

if [ -n "${emailfrom}" ]; then
	mail -s "${alertsubject}" -r "${emailfrom}" "${email}" < "${emaillog}"
else
	mail -s "${alertsubject}" "${email}" < "${emaillog}"
fi
exitcode=$?
if [ "${exitcode}" == "0" ]; then
	fn_print_ok_nl "Sending Email alert: ${email}"
	fn_script_log_pass "Sending Email alert: ${email}"
else
	fn_print_fail_nl "Sending Email alert: ${email}"
	fn_script_log_fatal "Sending Email alert: ${email}"
fi