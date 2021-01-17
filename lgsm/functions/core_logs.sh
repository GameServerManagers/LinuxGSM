#!/bin/bash
# LinuxGSM core_logs.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Acts as a log rotator, removing old logs.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Check if logfile variable and file exist, create logfile if it doesn't exist.
if [ "${consolelog}" ]; then
	if [ ! -f "${consolelog}" ]; then
		touch "${consolelog}"
	fi
fi

# For games not displaying a console, and having logs into their game directory.
check_status.sh
if [ "${status}" != "0" ]&&[ "${commandname}" == "START" ]&&[ -n "${gamelogfile}" ]; then
	if [ "$(find "${systemdir}" -name "gamelog*.log")" ]; then
		fn_print_info "Moving game logs to ${gamelogdir}"
		fn_script_log_info "Moving game logs to ${gamelogdir}"
		echo -en "\n"
		fn_sleep_time
		mv "${systemdir}"/gamelog*.log "${gamelogdir}"
	fi
fi

# Log manager will start the cleanup if it finds logs older than "${logdays}".
if [ "$(find "${lgsmlogdir}"/ -type f -mtime +"${logdays}" | wc -l)" -ne "0" ]; then
	fn_print_dots "Starting"
	# Set common logs directories
	commonlogs="${systemdir}/logs"
	commonsourcelogs="${systemdir}/*/logs"
	# Set addon logs directories
	sourcemodlogdir="${systemdir}/addons/sourcemod/logs"
	ulxlogdir="${systemdir}/data/ulx_logs"
	darkrplogdir="${systemdir}/data/darkrp_logs"
	legacyserverlogdir="${logdir}/server"
	# Setting up counting variables
	scriptcount="0" ; consolecount="0" ; gamecount="0" ; srcdscount="0" ; smcount="0" ; ulxcount="0" ; darkrpcount="0" ; legacycount="0"
	fn_sleep_time
	fn_print_info "Removing logs older than ${logdays} days"
	fn_script_log_info "Removing logs older than ${logdays} days"
	# Logging logfiles to be removed according to "${logdays}", counting and removing them.
	# Script logfiles.
	find "${lgsmlogdir}"/ -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
	scriptcount=$(find "${lgsmlogdir}"/ -type f -mtime +"${logdays}" | wc -l)
	find "${lgsmlogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
	# SRCDS and unreal logfiles.
	if [ "${engine}" == "unreal2" ]||[ "${engine}" == "source" ]; then
		find "${gamelogdir}"/ -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
		gamecount=$(find "${gamelogdir}"/ -type f -mtime +"${logdays}" | wc -l)
		find "${gamelogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
	fi
	# Console logfiles.
	if [ "${consolelog}" ]; then
		find "${consolelogdir}"/ -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
		consolecount=$(find "${consolelogdir}"/ -type f -mtime +"${logdays}" | wc -l)
		find "${consolelogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
	fi
	# Common logfiles.
	if [ -d "${commonlogs}" ]; then
		find "${commonlogs}"/ -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
		smcount=$(find "${commonlogs}"/ -type f -mtime +"${logdays}" | wc -l)
		find "${commonlogs}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
	fi
	if [ -d "${commonsourcelogs}" ]; then
		find "${commonsourcelogs}"/* -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
		smcount=$(find "${commonsourcelogs}"/* -type f -mtime +"${logdays}" | wc -l)
		find "${commonsourcelogs}"/* -mtime +"${logdays}" -type f -exec rm -f {} \;
	fi
	# Source addons logfiles.
	if [ "${engine}" == "source" ]; then
		# SourceMod logfiles.
		if [ -d "${sourcemodlogdir}" ]; then
			find "${sourcemodlogdir}"/ -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
			smcount=$(find "${sourcemodlogdir}"/ -type f -mtime +"${logdays}" | wc -l)
			find "${sourcemodlogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
		fi
		# Garry's Mod logfiles.
		if [ "${shortname}" == "gmod" ]; then
			# ULX logfiles.
			if [ -d "${ulxlogdir}" ]; then
				find "${ulxlogdir}"/ -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
				ulxcount=$(find "${ulxlogdir}"/ -type f -mtime +"${logdays}" | wc -l)
				find "${ulxlogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
			fi
			# DarkRP logfiles.
			if [ -d "${darkrplogdir}" ]; then
				find "${darkrplogdir}"/ -type f -mtime +"${logdays}" | tee >> "${lgsmlog}"
				darkrpcount=$(find "${darkrplogdir}"/ -type f -mtime +"${logdays}" | wc -l)
				find "${darkrplogdir}"/ -mtime +"${logdays}" -type f -exec rm -f {} \;
			fi
		fi
	fi

	# Count total amount of files removed.
	countlogs=$((scriptcount + consolecount + gamecount + srcdscount + smcount + ulxcount + darkrpcount))
	# Job done.
	fn_print_ok "Removed ${countlogs} log files"
	fn_script_log "Removed ${countlogs} log files"
fi
