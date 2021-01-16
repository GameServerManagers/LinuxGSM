#!/bin/bash
# LinuxGSM fix_kf2.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Killing Floor 2.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_parms(){
parms="\"${defaultmap}?Game=KFGameContent.KFGameInfo_VersusSurvival\""
}

fn_print_information "starting ${gamename} server to generate configs."
fn_sleep_time
exitbypass=1
command_start.sh
fn_firstcommand_reset
sleep 10
exitbypass=1
command_stop.sh
fn_firstcommand_reset
