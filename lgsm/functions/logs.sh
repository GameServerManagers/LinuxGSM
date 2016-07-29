#!/bin/bash
# LGSM logs.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Acts as a log rotater, removing old logs.

local commandname="LOGS"
local commandaction="Log-Manager"

# Check if logfile variable and file exist, create logfile if it doesn't exist
if [ -n "${consolelog}" ]; then
	if [ ! -e "${consolelog}" ]; then
		touch "${consolelog}"
	fi
fi

# For games not displaying a console, and having logs into their game folder
if [ "${function_selfname}" == "command_start.sh" ] && [ -n "${gamelogfile}" ]; then
	if [ -n "$(find "${systemdir}" -name "gamelog*.log")" ]; then
		fn_print_info "Moving game logs to ${gamelogdir}"
		fn_script_log_info "Moving game logs to ${gamelogdir}"
		echo -en "\n"
		sleep 1
		mv "${systemdir}"/gamelog*.log "${gamelogdir}"
	fi
fi

# Log manager will start the cleanup if it finds logs older than "${logdays}"
if [ $(find "${scriptlogdir}"/ -type f -mtime +"${logdays}"|wc -l) -ne "0" ]; then
	fn_print_dots "Starting"
	# Set addon logs directories
	sourcemodlogdir="${systemdir}/addons/sourcemod/logs"
	ulxlogdir="${systemdir}/data/ulx_logs"
	darkrplogdir="${systemdir}/data/darkrp_logs"
	legacyserverlogdir="${rootdir}/log/server"
	# Setting up counting variables
	scriptcount="0" ; consolecount="0" ; gamecount="0" ; srcdscount="0" ; smcount="0" ; ulxcount="0" ; darkrpcount="0" ; legacycount="0"
	sleep 1
	fn_print_ok_nl "Starting"
	fn_print_info_nl "Removing logs older than "${logdays}" days"
	fn_script_log_info "Removing logs older than "${logdays}" days"
	# Logging logfiles to be removed according to "${logdays}", counting and removing them
	# Script logfiles
	find "${scriptlogdir}"/ -type f -mtime +"${logdays}"| tee >> "${scriptlog}"
	scriptcount=$(find "${scriptlogdir}"/ -type f -mtime +"${logdays}"|wc -l)
	find "${scriptlogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
	# SRCDS and unreal logfiles
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		find "${gamelogdir}"/ -type f -mtime +"${logdays}"| tee >> "${scriptlog}"
		gamecount=$(find "${gamelogdir}"/ -type f -mtime +"${logdays}"|wc -l)
		find "${gamelogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
	fi
	# Console logfiles
	if [ -n "${consolelog}" ]; then
		find "${consolelogdir}"/ -type f -mtime +"${logdays}"| tee >> "${scriptlog}"
		consolecount=$(find "${consolelogdir}"/ -type f -mtime +"${logdays}"|wc -l)
		find "${consolelogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
	fi
	# Source addons logfiles
	if [ "${engine}" == "source" ]; then
		# SourceMod logfiles
		if [ -d "${sourcemodlogdir}" ]; then
			find "${sourcemodlogdir}"/ -type f -mtime +"${logdays}"| tee >> "${scriptlog}"
			smcount=$(find "${sourcemodlogdir}"/ -type f -mtime +"${logdays}"|wc -l)
			find "${sourcemodlogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
		fi
		# Garry's Mod logfiles
		if [ "${gamename}" == "Garry's Mod" ]; then
			# ULX logfiles
			if [ -d "${ulxlogdir}" ]; then
				find "${ulxlogdir}"/ -type f -mtime +"${logdays}"| tee >> "${scriptlog}"
				ulxcount=$(find "${ulxlogdir}"/ -type f -mtime +"${logdays}"|wc -l)
				find "${ulxlogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
			fi
			# DarkRP logfiles
			if [ -d "${darkrplogdir}" ]; then
				find "${darkrplogdir}"/ -type f -mtime +"${logdays}"| tee >> "${scriptlog}"
				darkrpcount=$(find "${darkrplogdir}"/ -type f -mtime +"${logdays}"|wc -l)
				find "${darkrplogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
			fi
		fi
	fi
	# Legacy support
	if [ -d "${legacyserverlogdir}" ]; then
		find "${legacyserverlogdir}"/ -type f -mtime +"${logdays}"| tee >> "${scriptlog}"
		legacycount=$(find "${legacyserverlogdir}"/ -type f -mtime +"${logdays}"|wc -l)
		find "${legacyserverlogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
		# Remove folder if empty
		if [ ! "$(ls -A "${legacyserverlogdir}")" ]; then
		rm -rf "${legacyserverlogdir}"
		fi
	fi

	# Count total amount of files removed
	count=$((${scriptcount} + ${consolecount} + ${gamecount} + ${srcdscount} + ${smcount} + ${ulxcount} + ${darkrpcount} + ${legacycount}))
	# Job done
	fn_print_ok_nl "Removed ${count} log files"
	fn_script_log "Removed ${count} log files"
fi
