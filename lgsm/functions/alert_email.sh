#!/bin/bash
# LGSM alert_email.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends email alert including server details and logs.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_details_email(){
	#
	# Failure reason: Testing bb2-server email alert
	# Action Taken: Sent test email...hello is this thing on?

	echo -e "${alertbody}" >> "${emaillog}"
}


fn_details_os(){
	#
	# Distro Details
	# =====================================
	# Distro:    Ubuntu 14.04.4 LTS
	# Arch:      x86_64
	# Kernel:    3.13.0-79-generic
	# Hostname:  hostname
	# tmux:      tmux 1.8
	# GLIBC:     2.19

	{
		echo -e ""
		echo -e "Distro Details"
		echo -e "================================="
		echo -e "Distro: ${distroname}"
		echo -e "Arch: ${arch}"
		echo -e "Kernel: ${kernel}"
		echo -e "Hostname: $HOSTNAME"
		echo -e "tmux: ${tmuxv}"
		echo -e "GLIBC: ${glibcversion}"
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1
}

fn_details_performance(){
	#
	# Performance
	# =====================================
	# Uptime:    55d, 3h, 38m
	# Avg Load:  1.00, 1.01, 0.78
	#
	# Mem:       total   used   free
	# Physical:  741M    656M   85M
	# Swap:      0B      0B     0B

	{
		echo -e ""
		echo -e "Performance"
		echo -e "================================="
		echo -e "Uptime: ${days}d, ${hours}h, ${minutes}m"
		echo -e "Avg Load: ${load}"
		echo -e ""
		echo -e "Mem: total  used  free"
		echo -e "Physical: ${physmemtotal} ${physmemused} ${physmemfree}"
		echo -e "Swap: ${swaptotal} ${swapused} ${swapfree}"
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1
}

fn_details_disk(){
	#
	# Storage
	# =====================================
	# Filesystem:   /dev/disk/by-uuid/320c8edd-a2ce-4a23-8c9d-e00a7af2d6ff
	# Total:        15G
	# Used:         8.4G
	# Available:    5.7G
	# Serverfiles:  961M

	{
		echo -e ""
		echo -e "Storage"
		echo -e "================================="
		echo -e "Filesystem: ${filesystem}"
		echo -e "Total: ${totalspace}"
		echo -e "Used: ${usedspace}"
		echo -e "Available: ${availspace}"
		echo -e "Serverfiles: ${filesdirdu}"
		if [ -d "${backupdir}" ]; then
			echo -e "Backups: ${backupdirdu}"
		fi
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1
}



fn_details_gameserver(){
	#
	# Quake Live Server Details
	# =====================================
	# Server name:      ql-server
	# Server IP:        1.2.3.4:27960
	# RCON password:    CHANGE_ME
	# Server password:  NOT SET
	# Slots:            16
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

		# Slots
		if [ -n "${slots}" ]; then
			echo -e "Slots: ${slots}"
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
	{
	echo -e ""
	echo -e "${servicename} Logs"
	echo -e "================================="

	if [ -n "${scriptlog}" ]; then
		echo -e "\nScript log\n==================="
		if [ ! "$(ls -A ${scriptlogdir})" ]; then
			echo "${scriptlogdir} (NO LOG FILES)"
		elif [ ! -s "${scriptlog}" ]; then
			echo "${scriptlog} (LOG FILE IS EMPTY)"
		else
			echo "${scriptlog}"
			tail -25 "${scriptlog}"
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
			tail "${gamelogdir}"/* | grep -v "==>" | sed '/^$/d' | tail -25
		fi
		echo ""
	fi

	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1
}

fn_print_dots "Sending alert: ${email}"
fn_script_log_info "Sending alert: ${email}"
info_distro.sh
info_config.sh
info_glibc.sh
check_ip.sh

emaillog="${emaillog}"
if [ -f "${emaillog}" ]; then
	rm "${emaillog}"
fi
fn_details_email
fn_details_os
fn_details_performance
fn_details_disk
fn_details_gameserver
fn_alert_email_template_logs
mail -s "${alertsubject}" "${email}" < "${emaillog}"
exitcode=$?
if [ "${exitcode}" == "0" ]; then
	fn_print_ok_nl "Sending alert: ${email}"
	fn_script_log_pass "Sending alert: ${email}"
else
	fn_print_fail_nl "Sending alert: ${email}"
	fn_script_log_fatal "Sending alert: ${email}"
fi