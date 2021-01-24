#!/bin/bash
# LinuxGSM command_check_update.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of servers.

commandname="CHECK-UPDATE"
commandaction="check for Update"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots ""
check.sh
core_logs.sh

core_steamcmd.sh

check_steamcmd.sh

fn_update_steamcmd_localbuild
fn_update_steamcmd_remotebuild
fn_update_steamcmd_compare

core_exit.sh
