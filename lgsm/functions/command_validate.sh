#!/bin/bash
# LinuxGSM command_validate.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Runs a server validation.

local modulename="VALIDATE"
local commandaction="Validate"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_validate(){
	fn_script_log_warn "Validating server: SteamCMD: Validate might overwrite some customised files"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "Validating server: SteamCMD: Validate might overwrite some customised files: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		sleep 1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "Validating server: SteamCMD: Validate might overwrite some customised files"
	fn_print_start_nl "Validating server: SteamCMD"
	fn_script_log_info "Validating server: SteamCMD"
	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi
	# Detects if unbuffer command is available, for 32 bit distributions only.
	info_distro.sh
	if [ "$(command -v stdbuf)" ]&&[ "${arch}" != "x86_64" ]; then
		unbuffer="stdbuf -i0 -o0 -e0"
	fi

	# If GoldSrc (appid 90) servers. GoldSrc (appid 90) require extra commands.
	if [ "${appid}" == "90" ]; then
		# If using a specific branch.
		if [ -n "${branch}" ]; then
			${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_info_print 70 +app_set_config 90 mod "${appidmod}" +app_update "${appid}" "${branch}" +app_update "${appid}" -beta "${branch}" validate +quit | tee -a "${lgsmlog}"
		else
			${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_info_print 70 +app_set_config 90 mod "${appidmod}" +app_update "${appid}" "${branch}" +app_update "${appid}" validate +quit | tee -a "${lgsmlog}"
		fi
	elif [ "${shortname}" == "ac" ]; then
		${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" validate +quit
		local exitcode=$?
	# All other servers.
	elif [ -n "${branch}" ]; then
		${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" -beta "${branch}" validate +quit | tee -a "${lgsmlog}"
	else
		${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" validate +quit | tee -a "${lgsmlog}"
	fi

	exitcode=$?
	fn_print_dots "Validating server: SteamCMD"
	if [ "${exitcode}" != "0" ]; then
		fn_print_fail_nl "Validating server: SteamCMD"
		fn_script_log_fatal "Validating server: SteamCMD: FAIL"
	else
		fn_print_ok_nl "Validating server: SteamCMD"
		fn_script_log_pass "Validating server: SteamCMD: OK"
	fi
	core_exit.sh
}

fn_stop_warning(){
	fn_print_warn "Validating server: SteamCMD: ${selfname} will be stopped during validation"
	fn_script_log_warn "Validating server: SteamCMD: ${selfname} will be stopped during validation"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "Validating server: SteamCMD: ${selfname} will be stopped during validation: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		sleep 1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "Validating server: SteamCMD: ${selfname} will be stopped during validation"
}

fn_print_dots "Validating server"
fn_print_dots "Validating server: SteamCMD"
check.sh
check_status.sh
if [ "${status}" != "0" ]; then
	fn_stop_warning
	exitbypass=1
	command_stop.sh
	fn_validate
	exitbypass=1
	command_start.sh
else
	fn_validate
fi

core_exit.sh
