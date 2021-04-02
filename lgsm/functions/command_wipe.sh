#!/bin/bash
# LinuxGSM command_backup.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Wipes server data, useful after updates for some games like Rust.

commandname="WIPE"
commandaction="Wiping"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

# Provides an exit code upon error.
fn_wipe_exit_code(){
	exitcode=$?
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
}

# Removes files to wipe server.
fn_wipe_server_files(){
	fn_print_start_nl "Wiping server"
	fn_script_log_info "Wiping server"

	# Remove Map files
	if [ -n "$(find "${serveridentitydir}" -type f -name "*.map")" ]; then
		echo -en "removing *.map file(s)..."
		fn_script_log_info "removing *.map file(s)"
		fn_sleep_time
		find "${serveridentitydir:?}" -type f -name "*.map" -printf "%f\n" >>  "${lgsmlog}"
		find "${serveridentitydir:?}" -type f -name "*.map" -delete | tee -a "${lgsmlog}"
		fn_wipe_exit_code
	else
		echo -e "no *.map file(s) to remove"
		fn_sleep_time
		fn_script_log_pass "no *.map file(s) to remove"
	fi

	# Remove Save files.
	if [ -n "$(find "${serveridentitydir}" -type f -name "*.sav*")" ]; then
		echo -en "removing .sav file(s)..."
		fn_script_log_info "removing .sav file(s)"
		fn_sleep_time
		find "${serveridentitydir:?}" -type f -name "*.sav*" -printf "%f\n" >>  "${lgsmlog}"
		find "${serveridentitydir:?}" -type f -name "*.sav*" -delete
		fn_wipe_exit_code
	else
		echo -e "no .sav file(s) to remove"
		fn_script_log_pass "no .sav file(s) to remove"
		fn_sleep_time
	fi

	# Remove db files for full wipe.
	if [ -n "${fullwipe}" ]; then
		if [ -n "$(find "${serveridentitydir}" -type f -name "*.db")" ]; then
			echo -en "removing .db file(s)..."
			fn_script_log_info "removing .db file(s)"
			fn_sleep_time
			find "${serveridentitydir:?}" -type f -name "*.db" -printf "%f\n" >> "${lgsmlog}"
			find "${serveridentitydir:?}" -type f -name "*.db" -delete
			fn_wipe_exit_code
		else
			echo -e "no .db file(s) to remove"
			fn_sleep_time
			fn_script_log_pass "no .db file(s) to remove"
		fi
	fi
}

fn_wipe_warning(){
	fn_print_warn "Wipe will reset the map and keep player data"
	fn_script_log_warn "Wipe will reset the map and keep player data"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "Wipe will reset the map and keep player data: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		sleep 1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "Wipe will reset the map and keep player data"
}

fn_full_wipe_warning(){
	fn_print_warn "Full wipe will reset the map and remove player data"
	fn_script_log_warn "Full wipe will reset the map and remove player data"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "Full wipe will reset the map and remove player data: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		sleep 1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "Full wipe will reset the map and remove player data"
}

# Will change the seed everytime the wipe is run, if the seed is not defined by the user.
fn_wipe_random_seed(){
	if [ -f "${datadir}/${selfname}-seed.txt" ]; then
		shuf -i 1-2147483647 -n 1 > "${datadir}/${selfname}-seed.txt"
		seed=$(cat "${datadir}/${selfname}-seed.txt")
		echo -en "generating new random seed (${cyan}${seed}${default})..."
		fn_script_log_pass "generating new random seed (${cyan}${seed}${default})"
		fn_sleep_time
		fn_print_ok_eol_nl
	fi
}

fn_print_dots ""
check.sh

# Check if there is something to wipe.
if [ -n "$(find "${serveridentitydir}" -type f -name "*.sav*")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "Log.*.txt")" ]||[ -n "$(find "${serveridentitydir}" -type f -name "*.db")" ]; then
	if [ -n "${fullwipe}" ]; then
		fn_full_wipe_warning
	else
		fn_wipe_warning
	fi
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_restart_warning
		exitbypass=1
		command_stop.sh
		fn_firstcommand_reset
		fn_wipe_server_files
		fn_wipe_random_seed
		fn_print_complete_nl "Wiping ${selfname}"
		fn_script_log_pass "Wiping ${selfname}"
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
	else
		fn_wipe_server_files
		fn_wipe_random_seed
		fn_print_complete_nl "Wiping ${selfname}"
		fn_script_log_pass "Wiping ${selfname}"
	fi
else
	fn_print_ok_nl "Wipe not required"
	fn_script_log_pass "Wipe not required"
fi
core_exit.sh
