#!/bin/bash
# LinuxGSM command_restart.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Restarts the server.

commandname="MODS-INSTALL"
commandaction="Restarting"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

info_config.sh
exitbypass=1
command_stop.sh
command_start.sh
fn_firstcommand_reset
core_exit.sh
