#!/bin/bash
# LGSM check_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Checks if SteamCMD is installed correctly.

local commandname="CHECK"

fn_install_steamcmd(){
	if [ ! -d "${steamcmddir}" ]; then
		mkdir -v "${steamcmddir}"
	fi
	fn_fetch_file "http://media.steampowered.com/client/steamcmd_linux.tar.gz" "${lgsmdir}/tmp" "steamcmd_linux.tar.gz"
	fn_dl_extract "${lgsmdir}/tmp" "steamcmd_linux.tar.gz" "${steamcmddir}"
	chmod +x "${steamcmddir}/steamcmd.sh"
}

fn_check_steamcmd_user(){
	# Checks if steamuser is setup.
	if [ "${steamuser}" == "username" ]; then
		fn_print_fail_nl "Steam login not set. Update steamuser in ${selfname}."
		echo "	* Change steamuser=\"username\" to a valid steam login."
		if [ -d "${scriptlogdir}" ]; then
			fn_script_log_fatal "Steam login not set. Update steamuser in ${selfname}."
		fi
		core_exit.sh
	fi
	# Anonymous user is set if steamuser is missing
	if [ -z "${steamuser}" ]; then
		fn_print_error_nl "Steam login not set. Using anonymous login."
		if [ -d "${scriptlogdir}" ]; then
			fn_script_log_error "Steam login not set. Using anonymous login."
		fi
		steamuser="anonymous"
		steampass=""
		sleep 2
	fi
}

fn_check_steamcmd_sh(){
	# Checks if SteamCMD exists when starting or updating a server.
	# Installs if missing.
	steamcmddir="${rootdir}/steamcmd"
	if [ ! -f "${steamcmddir}/steamcmd.sh" ]; then
		if [ "${function_selfname}" == "command_install.sh" ]; then
			fn_install_steamcmd
		else
			fn_print_error_nl "SteamCMD is missing"
			fn_script_log_error "SteamCMD is missing"
			sleep 1
			fn_install_steamcmd
		fi
	elif [ "${function_selfname}" == "command_install.sh" ]; then
		fn_print_information "SteamCMD is already installed..."
		fn_print_ok_eol_nl
	fi
}

fn_check_steamcmd_guard(){
	if [ "${function_selfname}" == "command_update.sh" ]||[ "${function_selfname}" == "command_validate.sh" ]; then
		# Checks that SteamCMD is working correctly and will prompt Steam Guard if required.
		"${steamcmddir}"/steamcmd.sh +login "${steamuser}" "${steampass}" +quit
		if [ $? -ne 0 ]; then
			fn_print_failure_nl "Error running SteamCMD"
		fi
	fi
}

fn_check_steamcmd_user
fn_check_steamcmd_sh
# stdbuf has now replaced unbuffer. This should not longer be required.
#fn_check_steamcmd_guard