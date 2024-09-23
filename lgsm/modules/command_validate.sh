#!/bin/bash
# LinuxGSM command_validate.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Runs a server validation.

commandname="VALIDATE"
commandaction="Validating"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_validate() {
	fn_print_warn "Validate might overwrite some customised files"
	fn_script_log_warn "${commandaction} server: Validate might overwrite some customised files"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "Validate might overwrite some customised files: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		fn_sleep_time_1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "Validate might overwrite some customised files"
	date '+%s' > "${lockdir:?}/update.lock"
	fn_dl_steamcmd
}

fn_print_dots ""
check.sh
core_logs.sh

fn_print_dots "SteamCMD"

if [ "${status}" != "0" ]; then
	fn_print_restart_warning
	exitbypass=1
	command_stop.sh
	fn_firstcommand_reset
	fn_validate
	exitbypass=1
	command_start.sh
	fn_firstcommand_reset
else
	fn_validate
fi

# remove update lockfile
rm -f "${lockdir:?}/update.lock"

core_exit.sh
