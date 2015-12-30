#!/bin/bash
# LGSM command_validate.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Runs a server validation.

local modulename="Validate"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_validation(){
fn_printwarn "Validating may overwrite some customised files."
sleep 1
echo -en "\n"
echo -en "https://developer.valvesoftware.com/wiki/SteamCMD#Validate"
sleep 5
echo -en "\n"
fn_printdots "Checking server files"
sleep 1
fn_printok "Checking server files"
fn_scriptlog "Checking server files"
sleep 1

cd "${rootdir}/steamcmd"

if [ $(command -v unbuffer) ]; then
	unbuffer=unbuffer
fi

if [ "${engine}" == "goldsource" ]; then
	${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" +app_update "${appid}" validate +quit|tee -a "${scriptlog}"
else
	${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" validate +quit|tee -a "${scriptlog}"
fi

fix.sh
fn_scriptlog "Checking complete"
}

check.sh
tmuxwc=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -v failed|grep -Ec "^${servicename}:")
if [ "${tmuxwc}" -eq 1 ]; then
    command_stop.sh
    fn_validation
    command_start.sh
else
    fn_validation
fi
