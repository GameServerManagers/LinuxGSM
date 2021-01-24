#!/bin/bash
# LinuxGSM check_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if SteamCMD is installed correctly.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# init steamcmd functions
core_steamcmd.sh

fn_check_steamcmd_clear
fn_check_steamcmd
if [ ${shortname} == "ark" ]; then
	fn_check_steamcmd_ark
fi
fn_check_steamcmd_dir
fn_check_steamcmd_dir_legacy
fn_check_steamcmd_user
fn_check_steamcmd_exec
