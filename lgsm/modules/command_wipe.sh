#!/bin/bash
# LinuxGSM command_backup.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Wipes server data, useful after updates for some games like Rust.

commandname="WIPE"
commandaction="Wiping"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

# Provides an exit code upon error.
fn_wipe_exit_code() {
	exitcode=$?
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol_nl
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
}

# Removes files to wipe server.
fn_wipe_files() {
	fn_print_start_nl "${wipetype}"
	fn_script_log_info "${wipetype}"

	# Remove Map files
	if [ -n "${serverwipe}" ] || [ -n "${mapwipe}" ]; then
		if [ -n "$(find "${serveridentitydir}" -type f -name "*.map")" ]; then
			echo -en "removing .map file(s)..."
			fn_script_log_info "Removing *.map file(s)"
			fn_sleep_time
			find "${serveridentitydir:?}" -type f -name "*.map" -printf "%f\n" >> "${lgsmlog}"
			find "${serveridentitydir:?}" -type f -name "*.map" -delete | tee -a "${lgsmlog}"
			fn_wipe_exit_code
		else
			echo -e "no .map file(s) to remove"
			fn_sleep_time
			fn_script_log_pass "no .map file(s) to remove"
		fi
	fi
	# Remove Save files.
	if [ -n "${serverwipe}" ] || [ -n "${mapwipe}" ]; then
		if [ -n "$(find "${serveridentitydir}" -type f -name "*.sav*")" ]; then
			echo -en "removing .sav file(s)..."
			fn_script_log_info "Removing .sav file(s)"
			fn_sleep_time
			find "${serveridentitydir:?}" -type f -name "*.sav*" -printf "%f\n" >> "${lgsmlog}"
			find "${serveridentitydir:?}" -type f -name "*.sav*" -delete
			fn_wipe_exit_code
		else
			echo -e "no .sav file(s) to remove"
			fn_script_log_pass "no .sav file(s) to remove"
			fn_sleep_time
		fi
	fi
	# Remove db files for full wipe.
	# Excluding player.tokens.db for Rust+.
	if [ -n "${serverwipe}" ]; then
		if [ -n "$(find "${serveridentitydir}" -type f ! -name 'player.tokens.db' -name "*.db")" ]; then
			echo -en "removing .db file(s)..."
			fn_script_log_info "Removing .db file(s)"
			fn_sleep_time
			find "${serveridentitydir:?}" -type f ! -name 'player.tokens.db' -name "*.db" -printf "%f\n" >> "${lgsmlog}"
			find "${serveridentitydir:?}" -type f ! -name 'player.tokens.db' -name "*.db" -delete
			fn_wipe_exit_code
		else
			echo -e "no .db file(s) to remove"
			fn_sleep_time
			fn_script_log_pass "no .db file(s) to remove"
		fi
	fi
}

fn_map_wipe_warning() {
	fn_print_warn "Map wipe will reset the map data and keep blueprint data"
	fn_script_log_warn "Map wipe will reset the map data and keep blueprint data"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "map wipe will reset the map data and keep blueprint data: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		fn_sleep_time_1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "Map wipe will reset the map data and keep blueprint data"
}

fn_full_wipe_warning() {
	fn_print_warn "Server wipe will reset the map data and remove blueprint data"
	fn_script_log_warn "Server wipe will reset the map data and remove blueprint data"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "server wipe will reset the map data and remove blueprint data: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		fn_sleep_time_1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "Server wipe will reset the map data and remove blueprint data"
}

# Will change the seed if the seed is not defined by the user.
fn_wipe_random_seed() {
	if [ -f "${datadir}/${selfname}-seed.txt" ] && [ -n "${randomseed}" ]; then
		shuf -i 1-2147483647 -n 1 > "${datadir}/${selfname}-seed.txt"
		seed=$(cat "${datadir}/${selfname}-seed.txt")
		randomseed=1
		echo -en "generating new random seed (${cyan}${seed}${default})..."
		fn_script_log_pass "Generating new random seed (${cyan}${seed}${default})"
		fn_sleep_time
		fn_print_ok_eol_nl
	fi
}

# A summary of what wipe is going to do.
fn_wipe_details() {
	fn_print_information_nl "Wipe does not remove Rust+ data."
	echo -en "* Wipe map data: "
	if [ -n "${serverwipe}" ] || [ -n "${mapwipe}" ]; then
		fn_print_yes_eol_nl
	else
		fn_print_no_eol_nl
	fi

	echo -en "* Wipe blueprint data: "
	if [ -n "${serverwipe}" ]; then
		fn_print_yes_eol_nl
	else
		fn_print_no_eol_nl
	fi

	echo -en "* Change Procedural Map seed: "
	if [ -n "${randomseed}" ]; then
		fn_print_yes_eol_nl
	else
		fn_print_no_eol_nl
	fi
}

fn_print_dots ""
check.sh
fix_rust.sh

# Check if there is something to wipe.
if [ -n "$(find "${serveridentitydir}" -type f -name "*.map")" ] || [ -n "$(find "${serveridentitydir}" -type f -name "*.sav*")" ] && [ -n "$(find "${serveridentitydir}" -type f ! -name 'player.tokens.db' -name "*.db")" ]; then
	if [ -n "${serverwipe}" ]; then
		wipetype="Full wipe"
		fn_full_wipe_warning
		fn_wipe_details
	elif [ -n "${mapwipe}" ]; then
		wipetype="Map wipe"
		fn_map_wipe_warning
		fn_wipe_details
	fi
	check_status.sh
	if [ "${status}" != "0" ]; then
		fn_print_restart_warning
		exitbypass=1
		command_stop.sh
		fn_firstcommand_reset
		fn_wipe_files
		fn_wipe_random_seed
		fn_print_complete_nl "${wipetype}"
		fn_script_log_pass "${wipetype}"
		alert="wipe"
		alert.sh
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
	else
		fn_wipe_files
		fn_wipe_random_seed
		fn_print_complete_nl "${wipetype}"
		fn_script_log_pass "${wipetype}"
		alert="wipe"
		alert.sh
	fi
else
	fn_print_ok_nl "Wipe not required"
	fn_script_log_pass "Wipe not required"
fi
core_exit.sh
