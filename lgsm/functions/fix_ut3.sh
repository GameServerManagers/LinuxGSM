#!/bin/bash
# LinuxGSM fix_ut2.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with Unreal Tournament 3.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_parms(){
parms="server VCTF-Suspense?Game=UTGameContent.UTVehicleCTFGame_Content?bIsDedicated=true?bIsLanMatch=false?bUsesStats=false?bShouldAdvertise=false?PureServer=1?bAllowJoinInProgress=true?ConfigSubDir=${selfname} -port=${port} -queryport=${queryport} -multihome=${ip} -nohomedir -unattended -log=${gamelog}"
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
