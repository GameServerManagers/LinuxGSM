#!/bin/bash
# LGSM logs.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="100215"

# Description: Acts as a log rotater, removing old logs.

local modulename="Log Manager"

# Check if logfile variable and file exist, create logfile if it doesn't exist
if [ -n "${consolelog}" ]; then
	if [ ! -e "${consolelog}" ]; then
		touch "${consolelog}"
	fi
fi

# Set source log directory
if [ -z "${systemdir}" && "${engine}" == "source" ]; then
	srcdslogdir="${systemdir}/logs"
	# Set addons directories
	sourcemodlogdir="${systemdir}/addons/sourcemod/logs"
	# Set gmod addons directories
	if [ "${gamename}" == "Garry's Mod" ]; then
		ulxlogdir="${systemdir}/data/ulx_logs"
		darkrplogdir="${systemdir}/data/darkrp_logs"
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
	# Retrocompatibility, for logs directly in /log folder 
	# Find game logfiles older than ${logdays} and write that list to the current script log
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		find "${gamelogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
	fi
	# Find script logfiles older than ${logdays} and write that list to the current script log
	find "${scriptlogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
	# Find console logfiles older than ${logdays} and write that list to the current script log
	if [ -n "${consolelog}" ]; then
		find "${consolelogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
	fi
	# Counting
	# Setting up variables
	scriptcount="0" ; consolecount="0" ; gamecount="0" ; srcdscount="0" ; smcount="0" ; ulxcount="0" ; darkrpcount="0"
	# Retrocompatibility, for logs directly in /log folder 
	# Count how many script logfiles will be removed
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		gamecount=$(find "${gamelogdir}"/ -type f -mtime +${logdays}|wc -l)
	fi
	# Count how many script logfiles will be removed
	scriptcount=$(find "${scriptlogdir}"/ -type f -mtime +${logdays}|wc -l)
	echo "${consolelog}"
	# Count how many console logfiles will be removed, if those logs exist
	if [ -n "${consolelog}" ]; then
		consolecount=$(find "${consolelogdir}"/ -type f -mtime +${logdays}|wc -l)
	fi
	# Count total amount of files to remove
	count=$((${scriptcount} + ${consolecount} + ${gamecount} + ${srcdscount} + ${smcount} + ${ulxcount} + ${darkrpcount}))

	# Removing logfiles
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
