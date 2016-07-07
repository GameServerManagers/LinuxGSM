#!/bin/bash
# LGSM command_validate.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Runs a server validation.

local modulename="Validate"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_validation(){
	fn_print_warn_nl "Validating may overwrite some customised files."
	echo -en "https://developer.valvesoftware.com/wiki/SteamCMD#Validate"
	sleep 5
	echo -en "\n"
	fn_print_dots "Checking server files"
	sleep 1
	fn_print_ok "Checking server files"
	fn_script_log_info "Checking server files"
	sleep 1

	cd "${rootdir}/steamcmd"

    if  [ $(command -v stdbuf) ]; then
		unbuffer="stdbuf -i0 -o0 -e0"
	fi

	if [ "${engine}" == "goldsource" ]; then
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" +app_update "${appid}" validate +quit| tee -a "${scriptlog}"
	else
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" validate +quit| tee -a "${scriptlog}"
	fi

	fix.sh
	fn_script_log_info "Checking complete"
}

check_status.sh
if [ "${status}" != "0" ]; then
	exitbypass=1
    command_stop.sh
    fn_validation
    exitbypass=1
    command_start.sh
else
    fn_validation
fi
core_exit.sh