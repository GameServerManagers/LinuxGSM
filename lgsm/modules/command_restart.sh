#!/bin/bash
# LinuxGSM command_restart.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Restarts the server.

commandname="RESTART"
commandaction="Restarting"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
info_game.sh
exitbypass=1
command_stop.sh
command_start.sh
fn_firstcommand_reset
core_exit.sh
