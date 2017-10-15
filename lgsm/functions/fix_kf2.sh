#!/usr/bin/env bash
# LinuxGSM fix_kf3.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Resolves various issues with Killing Floor 2.

local commandname="FIX"
local commandaction="Fix"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_parms(){
parms="\"${defaultmap}?Game=KFGameContent.KFGameInfo_VersusSurvival\""
}

fn_print_information "starting Killing Floor 2 server to generate configs."
sleep 1
exitbypass=1
command_start.sh
sleep 10
command_stop.sh