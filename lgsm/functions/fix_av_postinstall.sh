#!/bin/bash
# LinuxGSM fix_av_postinstall.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Generates the map the first time after installation

local commandname="FIX"
local commandaction="Fix"

export LD_LIBRARY_PATH="${serverfiles}/linux64"

fn_parms(){
	parms="--datapath ${avdatapath} --galaxy-name ${avgalaxy} --init-folders-only"
}

fn_print_information "starting ${gamename} server to generate configs."
fn_sleep_time
# go to the executeable dir and start the init of the server
cd "${systemdir}" || return 2
fn_parms
"${executabledir}/${executable}" ${parms} >/dev/null
