#!/bin/bash
# LinuxGSM command_backup.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Wipes server data, useful after updates for some games like Rust

local modulename="WIPE"
local commandaction="Wipe"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

check.sh
fn_print_header
fn_script_log "Entering ${gamename} ${commandaction}"

# Process to server wipe.
fn_wipe_server_process(){
	check_status.sh
	if [ "${status}" != "0" ]; then
		exitbypass=1
		command_stop.sh
		fn_wipe_server_remove_files
		exitbypass=1
		command_start.sh
	else
		fn_wipe_server_remove_files
	fi
	echo -e "server data wiped"
	fn_script_log "server data wiped."
}

# Provides an exit code upon error.
fn_wipe_exit_code(){
	((exitcode=$?))
	if [ ${exitcode} -ne 0 ]; then
		fn_script_log_fatal "${currentaction}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
}

# Removes files to wipe server.
fn_wipe_server_remove_files(){
	# Rust Wipe.
	if [ "${shortname}" == "rust" ]; then
		# Wipe pocedural map.
		if [ "$(find "${serveridentitydir}" -type f -name "proceduralmap.*.map")" ]; then
			currentaction="Removing map file(s): ${serveridentitydir}/proceduralmap.*.map"
			echo -en "Removing procedural map proceduralmap.*.map file(s)..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			find "${serveridentitydir:?}" -type f -name "proceduralmap.*.map" -delete
			fn_wipe_exit_code
			fn_sleep_time
		else
			fn_print_information_nl "No procedural map file to remove"
			fn_script_log_info "No procedural map file to remove."
		fi
		# Wipe procedural map save.
		if [ "$(find "${serveridentitydir}" -type f -name "proceduralmap.*.sav")" ]; then
			currentaction="Removing procedural map save(s): ${serveridentitydir}/proceduralmap.*.sav"
			echo -en "Removing map saves proceduralmap.*.sav file(s)..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			find "${serveridentitydir:?}" -type f -name "proceduralmap.*.sav" -delete
			fn_wipe_exit_code
			fn_sleep_time
		else
			fn_print_information_nl "No procedural map save to remove"
			fn_script_log_info "No procedural map save to remove."
		fi
		# Wipe Barren map.
		if [ "$(find "${serveridentitydir}" -type f -name "barren*.map")" ]; then
			currentaction="Removing map file(s): ${serveridentitydir}/barren*.map"
			echo -en "Removing barren map barren*.map file(s)..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			find "${serveridentitydir:?}" -type f -name "barren*.map" -delete
			fn_wipe_exit_code
			fn_sleep_time
		else
			fn_print_information_nl "No barren map file to remove"
			fn_script_log_info "No barren map file to remove."
		fi
		# Wipe barren map save.
		if [ "$(find "${serveridentitydir}" -type f -name "barren*.sav")" ]; then
			currentaction="Removing barren map save(s): ${serveridentitydir}/barren*.sav"
			echo -en "Removing barren map saves barren*.sav file(s)..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			find "${serveridentitydir:?}" -type f -name "barren*.sav" -delete
			fn_wipe_exit_code
			fn_sleep_time
		else
			fn_print_information_nl "No barren map save to remove"
			fn_script_log_info "No barren map save to remove."
		fi
		# Wipe user dir, might be a legacy thing, maybe to be removed.
		if [ -d "${serveridentitydir}/user" ]; then
			currentaction="Removing user directory: ${serveridentitydir}/user"
			echo -en "Removing user directory..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			rm -rf "${serveridentitydir:?}/user"
			fn_wipe_exit_code
			fn_sleep_time
		# We do not print additional information if there is nothing to remove since this might be obsolete.
		fi
		# Wipe storage dir, might be a legacy thing, maybe to be removed.
		if [ -d "${serveridentitydir}/storage" ]; then
			currentaction="Removing storage directory: ${serveridentitydir}/storage"
			echo -en "Removing storage directory..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			rm -rf "${serveridentitydir:?}/storage"
			fn_wipe_exit_code
			fn_sleep_time
		# We do not print additional information if there is nothing to remove since this might be obsolete.
		fi
		# Wipe sv.files.
		if [ "$(find "${serveridentitydir}" -type f -name "sv.files.*.db")" ]; then
			currentaction="Removing server misc files: ${serveridentitydir}/sv.files.*.db"
			echo -en "Removing server misc srv.files*.db file(s)..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			find "${serveridentitydir:?}" -type f -name "sv.files.*.db" -delete
			fn_wipe_exit_code
			fn_sleep_time
		# No further information if not found because it should I could not get this file showing up.
		fi
		# Wipe player death files.
		if [ "$(find "${serveridentitydir}" -type f -name "player.deaths.*.db")" ]; then
			currentaction="Removing player death files: ${serveridentitydir}/player.deaths.*.db"
			echo -en "Removing player deaths player.deaths.*.db file(s)..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			find "${serveridentitydir:?}" -type f -name "player.deaths.*.db" -delete
			fn_wipe_exit_code
			fn_sleep_time
		else
			fn_print_information_nl "No player death to remove"
			fn_script_log_info "No player death to remove."
		fi
		# Wipe blueprints only if wipeall command was used.
		if [ "${wipeall}" == "1" ]; then
			if [ "$(find "${serveridentitydir}" -type f -name "player.blueprints.*.db")" ]; then
				currentaction="Removing blueprint file(s): ${serveridentitydir}/player.blueprints.*.db"
				echo -en "Removing blueprints player.blueprints.*.db file(s)..."
				fn_sleep_time
				fn_script_log "${currentaction}"
				find "${serveridentitydir:?}" -type f -name "player.blueprints.*.db" -delete
				fn_wipe_exit_code
				fn_sleep_time
			else
				fn_print_information_nl "No blueprint file to remove"
				fn_script_log_info "No blueprint file to remove."
			fi
		elif [ "$(find "${serveridentitydir}" -type f -name "player.blueprints.*.db")" ]; then
				fn_print_information_nl "Keeping blueprints"
				fn_script_log_info "Keeping blueprints."
		else
				fn_print_information_nl "No blueprints found"
				fn_script_log_info "No blueprints found."
				fn_sleep_time
		fi
		# Wipe some logs that might be there.
		if [ "$(find "${serveridentitydir}" -type f -name "Log.*.txt")" ]; then
			currentaction="Removing log files: ${serveridentitydir}/Log.*.txt"
			echo -en "Removing Log files..."
			fn_sleep_time
			fn_script_log "${currentaction}"
			find "${serveridentitydir:?}" -type f -name "Log.*.txt" -delete
			fn_wipe_exit_code
			fn_sleep_time
		# We do not print additional information if there are no logs to remove.
		fi
	# You can add an "elif" here to add another game or engine.
	fi
}

# Check if there is something to wipe, prompt the user, and call appropriate functions.
# Rust Wipe.
if [ "${shortname}" == "rust" ]; then
	if [ -d "${serveridentitydir}/storage" ]||[ -d "${serveridentitydir}/user" ]||[ -n "$(find "${serveridentitydir}" -type f -name "proceduralmap*.sav")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "barren*.sav")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "Log.*.txt")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "player.deaths.*.db")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "player.blueprints.*.db")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "sv.files.*.db")" ]; then
		fn_print_warning_nl "Any user, storage, log and map data from ${serveridentitydir} will be erased."
		if ! fn_prompt_yn "Continue?" Y; then
				core_exit.sh
		fi
		fn_script_log_info "User selects to erase any user, storage, log and map data from ${serveridentitydir}"
		fn_sleep_time
		fn_wipe_server_process
	else
		fn_print_information_nl "No data to wipe was found"
		fn_script_log_info "No data to wipe was found."
		core_exit.sh
	fi
# You can add an "elif" here to add another game or engine.
else
	# Game not listed.
	fn_print_information_nl "Wipe is not available for this game"
	fn_script_log_info "Wipe is not available for this game."
	core_exit.sh
fi

core_exit.sh
