#!/bin/bash
# LinuxGSM command_validate.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Runs a server validation.

local commandname="VALIDATE"
local commandaction="Validate"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_validation(){
	fn_print_info "Validating files: SteamCMD"
	echo -e ""
	echo -e "* Validating may overwrite some customised files."
	echo -e "* https://docs.linuxgsm.com/commands/validate"
	fn_script_log_info "Validating files: SteamCMD"
	sleep 3
	cd "${steamcmddir}" || exit
	# Detects if unbuffer command is available for 32 bit distributions only.
	info_distro.sh
	if [ -n "$(command -v stdbuf)" ]&&[ "${arch}" != "x86_64" ]; then
		unbuffer="stdbuf -i0 -o0 -e0"
	fi

	if [ "${appid}" == "90" ]; then
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_info_print 70 +app_set_config 90 mod "${appidmod}" +app_update "${appid}" "${branch}" +app_update "${appid}" -beta "${branch}" validate +quit | tee -a "${lgsmlog}"
	else
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" -beta "${branch}" validate +quit | tee -a "${lgsmlog}"
	fi
	if [ $? != 0 ]; then
		fn_print_fail_nl "Validating files: SteamCMD"
		fn_script_log_fatal "Validating files: SteamCMD: FAIL"
	else
		fn_print_ok_nl "Validating files: SteamCMD"
		fn_script_log_pass "Validating files: SteamCMD: OK"
	fi
	fix.sh

}

fn_print_dots "Validating files:"
fn_print_dots "Validating files: SteamCMD"
check.sh
check_status.sh
if [ "${status}" != "0" ]; then
	exitbypass=1
	command_stop.sh
	fn_validation "${appid}"
	exitbypass=1
	command_start.sh
else
	fn_validation
fi

core_exit.sh
