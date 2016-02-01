#!/bin/bash
# LGSM email.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="010216"

# Description: Sends email notification if monitor picks up a failure.

local modulename="Email"
fn_printdots "Sending notification to ${email}"
info_distro.sh
{
	echo -e "========================================\n${servicename} details\n========================================"
	echo -e "Service: ${servicename}"
	echo -e "Server: ${servername}"
	echo -e "Game: ${gamename}"
	echo -e "Failure reason: ${failurereason}"
	echo -e "Action Taken: ${actiontaken}\n"
	echo -e "========================================\nServer details\n========================================"
	echo -e "Date: $(date)"
	echo -e "Distro: ${os}"
	echo -e "Arch: ${arch}"
	echo -e "Kernel: ${kernel}"
	echo -e "Hostname: $HOSTNAME"
	echo -e "tmux: ${tmuxv}"
	echo -e "GLIBC: ${glibcv}"	
	echo -e "Uptime: ${days}d, ${hours}h, ${minutes}m"
	echo -e "Avg Load${load}\n"
	echo -e "========================================\nLogs\n========================================"
}| sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee "${scriptlogdir}/${servicename}-email.log" > /dev/null 2>&1
echo -e "Script log\n===================\n" >> "${emaillog}"
tail -25 "${scriptlog}" >> "${emaillog}"
if [ ! -z "${consolelog}" ]; then
	echo -e "\n\nConsole log\n====================\n" >> "${emaillog}"
	tail -25 "${consolelog}" | awk '{ sub("\r$", ""); print }' >> "${emaillog}"
fi
if [ ! -z "${gamelogdir}" ]; then
	echo -e "\n\nServer log\n====================\n" >> "${emaillog}"
	tail "${gamelogdir}"/* | grep -v "==>" | sed '/^$/d' | tail -25 >> "${emaillog}"
fi
mail -s "${subject}" ${email} < "${emaillog}"
fn_printok "Sending notification to ${email}"
fn_scriptlog "Sent notification to ${email}"
sleep 1
echo -en "\n"
