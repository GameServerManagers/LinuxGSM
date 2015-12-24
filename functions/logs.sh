#!/bin/bash
# LGSM fn_logs function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

# Description: Acts as a log rotater, removing old logs.

local modulename="Log Manager"

if [ -n "${consolelog}" ]; then
	if [ ! -e "${consolelog}" ]; then
		touch "${consolelog}"
	fi
fi
# log manager will active if finds logs older than ${logdays}
if [ $(find "${scriptlogdir}"/ -type f -mtime +${logdays}|wc -l) -ne "0" ]; then
	fn_printdots "Starting"
	sleep 1
	fn_printok "Starting"
	fn_scriptlog "Starting"
	sleep 1
	echo -en "\n"
	fn_printinfo "Removing logs older than ${logdays} days"
	fn_scriptlog "Removing logs older than ${logdays} days"
	sleep 1
	echo -en "\n"
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		find "${gamelogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
	fi
	find "${scriptlogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
	if [ -n "${consolelog}" ]; then
		find "${consolelogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
	fi
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		gamecount=$(find "${scriptlogdir}"/ -type f -mtime +${logdays}|wc -l)
	fi
	scriptcount=$(find "${scriptlogdir}"/ -type f -mtime +${logdays}|wc -l)
	echo "${consolelog}"
	if [ -n "${consolelog}" ]; then
		consolecount=$(find "${consolelogdir}"/ -type f -mtime +${logdays}|wc -l)
	else
		consolecount=0
	fi

	count=$((${scriptcount} + ${consolecount}))
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		count=$((${scriptcount} + ${consolecount} + ${gamecount}))
	else
		count=$((${scriptcount} + ${consolecount}))
	fi


	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		find "${gamelogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
	fi
	find "${scriptlogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
	if [ -n "${consolelog}" ]; then
		find "${consolelogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
	fi
	fn_printok "Removed ${count} log files"
	fn_scriptlog "Removed ${count} log files"
	sleep 1
	echo -en "\n"
fi
