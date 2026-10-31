#!/bin/bash
# LinuxGSM command_workshop_update.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Downloads, updates and removes Steam Workshop mods set in workshopmods.

commandname="WORKSHOP-UPDATE"
commandaction="Updating Workshop Mods"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots ""
check.sh
core_logs.sh
check_update_lock.sh

if [ -z "${workshopmods}" ] && [ ! -f "${datadir}/${selfname}-workshop.txt" ]; then
	fn_print_info_nl "No Workshop mods set. Add Workshop IDs to workshopmods in ${configdirserver}"
	fn_script_log_info "No Workshop mods set"
	core_exit.sh
fi

workshop_core.sh
fn_workshop_update

rm -f "${lockdir:?}/update.lock"

core_exit.sh
