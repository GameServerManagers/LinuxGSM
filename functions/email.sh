#!/bin/bash
# LGSM email.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="020216"

# Description: Sends email notification if monitor picks up a failure.

local modulename="Email"
fn_printdots "Sending notification to ${email}"
info_distro.sh
info_config.sh
check_ip.sh
fn_parms
{
	echo -e "========================================\n${servicename} details\n========================================"
	echo -e "Service name: ${servicename}"
	echo -e "Server name: ${servername}"
	echo -e "Game name: ${gamename}"
	echo -e "Server IP: ${ip}:${port}"
	echo -e "Failure reason: ${failurereason}"
	echo -e "Action Taken: ${actiontaken}\n"
	echo -e ""
	echo -e "========================================\nDistro Details\n========================================"
	echo -e "Date: $(date)"
	echo -e "Distro: ${os}"
	echo -e "Arch: ${arch}"
	echo -e "Kernel: ${kernel}"
	echo -e "Hostname: $HOSTNAME"
	echo -e "tmux: ${tmuxv}"
	echo -e "GLIBC: ${glibcv}"
	echo -e ""
	echo -e "========================================\nPerformance\n========================================"
	echo -e "Uptime: ${days}d, ${hours}h, ${minutes}m"
	echo -e "Avg Load: ${load}" 
	echo -e ""
	echo -e "Mem: total used free"
	echo -e "Physical: ${physmemtotal} ${physmemused} ${physmemfree}"
	echo -e "Swap: ${swaptotal}${swapused} ${swapfree}"
	echo -e ""
	echo -e "========================================\nStorage\n========================================"	
	echo -e "\e[34mFilesystem:\t\e[0m${filesystem}"
	echo -e "\e[34mTotal:\t\e[0m${totalspace}"
	echo -e "\e[34mUsed:\t\e[0m${usedspace}"
	echo -e "\e[34mAvailable:\t\e[0m${availspace}"
	echo -e "\e[34mServerfiles:\t\e[0m${filesdirdu}"
	if [ -d "${backupdir}" ]; then
		echo -e "\e[34mBackups:\t\e[0m${backupdirdu}"
	fi
	echo -e ""	
	echo -e "========================================\nLogs\n========================================"
}| sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee "${scriptlogdir}/${servicename}-email.log" > /dev/null 2>&1
echo -e "\n\n	Script log\n===================" >> "${emaillog}"
tail -25 "${scriptlog}" >> "${emaillog}"
if [ ! -z "${consolelog}" ]; then
	echo -e "\n\n	Console log\n====================" >> "${emaillog}"
	tail -25 "${consolelog}" | awk '{ sub("\r$", ""); print }' >> "${emaillog}"
fi
if [ ! -z "${gamelogdir}" ]; then
	echo -e "\n\n	Server log\n====================" >> "${emaillog}"
	tail "${gamelogdir}"/* | grep -v "==>" | sed '/^$/d' | tail -25 >> "${emaillog}"
fi
mail -s "${subject}" ${email} < "${emaillog}"
fn_printok "Sending notification to ${email}"
fn_scriptlog "Sent notification to ${email}"
sleep 1
echo -en "\n"
