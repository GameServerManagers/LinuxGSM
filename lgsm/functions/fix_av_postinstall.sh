#!/bin/bash
# LinuxGSM fix_av_postinstall.sh function
# Author: Christian Birk
# Website: https://linuxgsm.com
# Description: Generates the map the first time after installation

local commandname="FIX"
local commandaction="Fix"

export LD_LIBRARY_PATH="${serverfiles}/linux64"

fn_parms(){
	parms="--datapath ${avdatapath} --galaxy-name ${avgalaxy} --stderr-to-log --stdout-to-log --init-folders-only"
}

fn_print_information "starting ${gamename} server to generate configs."
fn_sleep_time
exitbypass=1
command_start.sh
sleep 10
exitbypass=1
command_stop.sh
