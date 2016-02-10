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

# Set source logs directories
if [ -z "${systemdir}" ]&&[ "${engine}" == "source" ]; then
	srcdslogdir="${systemdir}/logs"
	# Set addons directories
	sourcemodlogdir="${systemdir}/addons/sourcemod/logs"
	# Set gmod addons directories
	if [ "${gamename}" == "Garry's Mod" ]; then
		ulxlogdir="${systemdir}/data/ulx_logs"
		darkrplogdir="${systemdir}/data/darkrp_logs"
	fi
fi

# Setting up counting variables
scriptcount="0" ; consolecount="0" ; gamecount="0" ; srcdscount="0" ; smcount="0" ; ulxcount="0" ; darkrpcount="0"

# Log manager will start the cleanup if it finds logs older than ${logdays}
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
	# Logging logfiles to be removed according to ${logdays}, counting and removing them
	# Script logfiles
	find "${scriptlogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
	scriptcount=$(find "${scriptlogdir}"/ -type f -mtime +${logdays}|wc -l)
	find "${scriptlogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
	# Retrocompatibility, for logs directly in /log folder 
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		find "${gamelogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
		gamecount=$(find "${gamelogdir}"/ -type f -mtime +${logdays}|wc -l)
		find "${gamelogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
	fi
	# Console logfiles
	if [ -n "${consolelog}" ]; then
		find "${consolelogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
		consolecount=$(find "${consolelogdir}"/ -type f -mtime +${logdays}|wc -l)
		find "${consolelogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
	fi
	# SRCDS logfiles
	if [ "${engine}" == "source" ]; then
		if [ -d "${srcdslogdir}" ]; then
			find "${srcdslogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
			srcdscount=$(find "${srcdslogdir}"/ -type f -mtime +${logdays}|wc -l)
			find "${srcdslogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
		fi
		# SourceMod logfiles
		if [ -d "${sourcemodlogdir}" ]; then
			find "${sourcemodlogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
			smcount=$(find "${sourcemodlogdir}"/ -type f -mtime +${logdays}|wc -l)
			find "${sourcemodlogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
		fi
		# ULX logfiles
		if [ "${gamename}" == "Garry's Mod" ]; then
			if [ -d "${ulxlogdir}" ]; then
				find "${ulxlogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
				ulxcount=$(find "${ulxlogdir}"/ -type f -mtime +${logdays}|wc -l)
				find "${ulxlogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
			fi
			if [ -d "${darkrplogdir}" ]; then
				find "${darkrplogdir}"/ -type f -mtime +${logdays}|tee >> "${scriptlog}"
				darkrpcount=$(find "${darkrplogdir}"/ -type f -mtime +${logdays}|wc -l)
				find "${darkrplogdir}"/ -mtime +${logdays} -type f -exec rm -f {} \;
			fi
		fi
	fi
	
	# Count total amount of files removed
	count=$((${scriptcount} + ${consolecount} + ${gamecount} + ${srcdscount} + ${smcount} + ${ulxcount} + ${darkrpcount}))
	# Job done
	fn_printok "Removed ${count} log files"
	fn_scriptlog "Removed ${count} log files"
	sleep 1
	echo -en "\n"
fi
