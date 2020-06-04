#!/bin/bash
# LinuxGSM command_restart.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Restarts the server.

fn_commandname(){
commandname="MODS-INSTALL"
commandaction="Restarting"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
}
fn_commandname

info_config.sh
exitbypass=1
command_stop.sh
command_start.sh
fn_commandname
core_exit.sh
