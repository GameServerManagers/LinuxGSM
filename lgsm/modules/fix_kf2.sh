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

# The KF2 Linux dedicated server does not create KFGame/Cache, the directory it
# uses when loading maps (including Workshop maps). The KF2 wiki lists this as a
# known Linux issue and the remedy as `mkdir -p KFGame/Cache`. Creating it after
# install, only once KFGame exists, keeps it present after every install.
if [ -d "${serverfiles}/KFGame" ] && [ ! -d "${serverfiles}/KFGame/Cache" ]; then
	fixname="KFGame/Cache directory"
	fn_fix_msg_start
	mkdir -p "${serverfiles}/KFGame/Cache"
	fn_fix_msg_end
fi
