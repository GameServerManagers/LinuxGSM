#!/bin/bash
# LinuxGSM check_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if SteamCMD is installed correctly.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_steamcmd(){
	if [ "${shortname}" == "ark" ]&&[ "${installsteamcmd}" == "1" ]; then
		steamcmddir="${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	fi
	if [ ! -d "${steamcmddir}" ]; then
		mkdir -p "${steamcmddir}"
	fi
	remote_fileurl="${1}"
	remote_fileurl_backup="${2}"
	remote_fileurl_name="${3}"
	remote_fileurl_backup_name="${4}"
	local_filedir="${5}"
	local_filename="${6}"
	chmodx="${7:-0}"
	run="${8:-0}"
	forcedl="${9:-0}"
	md5="${10:-0}"
	fn_fetch_file "http://media.steampowered.com/client/steamcmd_linux.tar.gz" "" "" "" "${tmpdir}" "steamcmd_linux.tar.gz" "" "norun" "noforce" "nomd5"
	fn_dl_extract "${tmpdir}" "steamcmd_linux.tar.gz" "${steamcmddir}"
	chmod +x "${steamcmddir}/steamcmd.sh"
}

fn_check_steamcmd_user(){
	# Checks if steamuser is setup.
	if [ "${steamuser}" == "username" ]; then
		fn_print_fail_nl "Steam login not set. Update steamuser in ${configdirserver}"
		echo -e "	* Change steamuser=\"username\" to a valid steam login."
		if [ -d "${lgsmlogdir}" ]; then
			fn_script_log_fatal "Steam login not set. Update steamuser in ${configdirserver}"
		fi
		core_exit.sh
	fi
	# Anonymous user is set if steamuser is missing.
	if [ -z "${steamuser}" ]; then
		if [ -d "${lgsmlogdir}" ]; then
			fn_script_log_info "Using anonymous Steam login"
		fi
		steamuser="anonymous"
		steampass=''
	fi
}

fn_check_steamcmd(){
	# Checks if SteamCMD exists when starting or updating a server.
	# Only install if steamcmd package is missing or steamcmd dir is missing.
	if [ ! -f "${steamcmddir}/steamcmd.sh" ]&&[ -z "$(command -v steamcmd 2>/dev/null)" ]; then
		if [ "${commandname}" == "INSTALL" ]; then
			fn_install_steamcmd
		else
			fn_print_warn_nl "SteamCMD is missing"
			fn_script_log_warn "SteamCMD is missing"
			fn_install_steamcmd
		fi
	elif [ "${commandname}" == "INSTALL" ]; then
		fn_print_information "SteamCMD is already installed..."
		fn_print_ok_eol_nl
	fi
}

fn_check_steamcmd_dir(){
	# Worksround that pre-installs the correct steam directories to ensure all packages use the correct Standard.
	# https://github.com/ValveSoftware/steam-for-linux/issues/6976#issuecomment-610446347

	# Create Steam installation directory.
	if [ ! -d "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam" ]; then
		mkdir -p "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam"
	fi

	# Create common Steam directory.
	if [ ! -d "${HOME}/.steam" ]; then
		mkdir -p "${HOME}/.steam"
	fi

	# Symbolic links to Steam installation directory.
	if [ ! -L "${HOME}/.steam/root" ]; then
		if [ -d "${HOME}/.steam/root" ]; then
			rm "${HOME}/.steam/root"
		fi
		ln -s "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam" "${HOME}/.steam/root"
	fi

	if [ ! -L "${HOME}/.steam/steam" ]; then
		if [ -d "${HOME}/.steam/steam" ]; then
			rm -rf "${HOME}/.steam/steam"
		fi
		ln -s "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam" "${HOME}/.steam/steam"
	fi
}

fn_check_steamcmd_dir_legacy(){
	# Remove old Steam installation directories ~/Steam and ${rootdir}/steamcmd
	if [ -d "${rootdir}/steamcmd" ]&&[ "${steamcmddir}" == "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam" ]; then
		rm -rf "${rootdir:?}/steamcmd"
	fi

	if [ -d "${HOME}/Steam" ]&&[ "${steamcmddir}" == "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam" ]; then
		rm -rf "${HOME}/Steam"
	fi
}

fn_check_steamcmd_ark(){
	# Checks if SteamCMD exists in
	# Engine/Binaries/ThirdParty/SteamCMD/Linux
	# to allow ark mods to work
	if [ ! -f "${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamcmd.sh" ]; then
		installsteamcmd=1
		if [ "${commandname}" == "INSTALL" ]; then
			fn_install_steamcmd
		else
			fn_print_warn_nl "ARK mods SteamCMD is missing"
			fn_script_log_warn "ARK mods SteamCMD is missing"
			fn_install_steamcmd
		fi
	elif [ "${commandname}" == "INSTALL" ]; then
		fn_print_information "ARK mods SteamCMD is already installed..."
		fn_print_ok_eol_nl
	fi
}

fn_check_steamcmd_clear(){
# Will remove steamcmd dir if steamcmd package is installed.
if [ "$(command -v steamcmd 2>/dev/null)" ]&&[ -d "${rootdir}/steamcmd" ]; then
	rm -rf "${steamcmddir:?}"
	exitcode=$?
	if [ "${exitcode}" != 0 ]; then
		fn_script_log_fatal "Removing ${rootdir}/steamcmd"
	else
		fn_script_log_pass "Removing ${rootdir}/steamcmd"
	fi
fi
}

fn_check_steamcmd_exec(){
	if [ "$(command -v steamcmd 2>/dev/null)" ]; then
		steamcmdcommand="steamcmd"
	else
		steamcmdcommand="./steamcmd.sh"
	fi
}

fn_check_steamcmd_clear
fn_check_steamcmd
if [ ${shortname} == "ark" ]; then
	fn_check_steamcmd_ark
fi
fn_check_steamcmd_dir
fn_check_steamcmd_dir_legacy
fn_check_steamcmd_user
fn_check_steamcmd_exec
