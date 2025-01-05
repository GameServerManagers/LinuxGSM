#!/bin/bash
# LinuxGSM fix_kf2.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Killing Floor 2.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

startparameters="\"${defaultmap}?Game=KFGameContent.KFGameInfo_VersusSurvival\""

fn_print_information "starting ${gamename} server to generate configs."
exitbypass=1
command_start.sh
fn_firstcommand_reset
fn_sleep_time_10
exitbypass=1
command_stop.sh
fn_firstcommand_reset
