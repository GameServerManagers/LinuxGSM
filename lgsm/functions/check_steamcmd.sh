#!/bin/bash
# LinuxGSM check_steamcmd.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
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
