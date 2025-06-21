#!/bin/bash
# LinuxGSM fix_ut2.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Unreal Tournament 3.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

startparameters="server VCTF-Suspense?Game=UTGameContent.UTVehicleCTFGame_Content?bIsDedicated=true?bIsLanMatch=false?bUsesStats=false?bShouldAdvertise=false?PureServer=1?bAllowJoinInProgress=true?ConfigSubDir=${selfname} -port=${port} -queryport=${queryport} -multihome=${ip} -nohomedir -unattended -log=${gamelog}"

fn_print_information "starting ${gamename} server to generate configs."
exitbypass=1
command_start.sh
fn_firstcommand_reset
fn_sleep_time_10
exitbypass=1
command_stop.sh
fn_firstcommand_reset
