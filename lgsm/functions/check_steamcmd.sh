#!/bin/bash
# LinuxGSM check_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if SteamCMD is installed correctly.

local commandname="CHECK"

fn_install_steamcmd(){
	if [ ! -d "${steamcmddir}" ]; then
		mkdir -pv "${steamcmddir}"
	fi
	fn_fetch_file "http://media.steampowered.com/client/steamcmd_linux.tar.gz" "${tmpdir}" "steamcmd_linux.tar.gz"
	fn_dl_extract "${tmpdir}" "steamcmd_linux.tar.gz" "${steamcmddir}"
	chmod +x "${steamcmddir}/steamcmd.sh"
}

fn_check_steamcmd_user(){
	# Checks if steamuser is setup.
	if [ "${steamuser}" == "username" ]; then
		if [ "${legacymode}" == "1" ]; then
			fn_print_fail_nl "Steam login not set. Update steamuser in ${selfname}"
		else
			fn_print_fail_nl "Steam login not set. Update steamuser in ${configdirserver}"
		fi
		echo "	* Change steamuser=\"username\" to a valid steam login."
		if [ -d "${lgsmlogdir}" ]; then
			if [ "${legacymode}" == "1" ]; then
				fn_script_log_fatal "Steam login not set. Update steamuser in ${selfname}"
			else
				fn_script_log_fatal "Steam login not set. Update steamuser in ${configdirserver}"
			fi
		fi
		core_exit.sh
	fi
	# Anonymous user is set if steamuser is missing
	if [ -z "${steamuser}" ]; then
		if [ -d "${lgsmlogdir}" ]; then
			fn_script_log_info "Using anonymous Steam login"
		fi
		steamuser="anonymous"
		steampass=''
	fi
}

fn_check_steamcmd_sh(){
	# Checks if SteamCMD exists when starting or updating a server.
	# Installs if missing.
	if [ ! -f "${steamcmddir}/steamcmd.sh" ]; then
		if [ "${function_selfname}" == "command_install.sh" ]; then
			fn_install_steamcmd
		else
			fn_print_error_nl "SteamCMD is missing"
			fn_script_log_error "SteamCMD is missing"
			fn_install_steamcmd
		fi
	elif [ "${function_selfname}" == "command_install.sh" ]; then
		fn_print_information "SteamCMD is already installed..."
		fn_print_ok_eol_nl
	fi
}

fn_check_steamcmd_user
fn_check_steamcmd_sh
