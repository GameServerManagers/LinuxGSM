#!/bin/bash
# LinuxGSM core_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Core modules for SteamCMD

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_steamcmd() {
	if [ "${shortname}" == "ark" ] && [ "${installsteamcmd}" == "1" ]; then
		steamcmddir="${serverfiles}/Engine/Binaries/ThirdParty/SteamCMD/Linux"
	fi
	if [ ! -d "${steamcmddir}" ]; then
		mkdir -p "${steamcmddir}"
	fi
	fn_fetch_file "http://media.steampowered.com/client/steamcmd_linux.tar.gz" "" "" "" "${tmpdir}" "steamcmd_linux.tar.gz" "nochmodx" "norun" "noforce" "nohash"
	fn_dl_extract "${tmpdir}" "steamcmd_linux.tar.gz" "${steamcmddir}"
	chmod +x "${steamcmddir}/steamcmd.sh"
}

fn_check_steamcmd_user() {
	# Checks if steamuser is setup.
	if [ "${steamuser}" == "username" ]; then
		fn_print_fail_nl "Steam login not set. Update steamuser in ${configdirserver}"
		echo -e "	* Change steamuser=\"username\" to a valid steam login."
		if [ -d "${lgsmlogdir}" ]; then
			fn_script_log_fail "Steam login not set. Update steamuser in ${configdirserver}"
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

fn_check_steamcmd() {
	# Checks if SteamCMD exists when starting or updating a server.
	# Only install if steamcmd package is missing or steamcmd dir is missing.
	if [ ! -f "${steamcmddir}/steamcmd.sh" ] && [ -z "$(command -v steamcmd 2> /dev/null)" ]; then
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

fn_check_steamcmd_dir() {
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
			rm -f "${HOME:?}/.steam/root"
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

fn_check_steamcmd_dir_legacy() {
	# Remove old Steam installation directories ~/Steam and ${rootdir}/steamcmd
	if [ -d "${rootdir}/steamcmd" ] && [ "${steamcmddir}" == "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam" ]; then
		rm -rf "${rootdir:?}/steamcmd"
	fi

	if [ -d "${HOME}/Steam" ] && [ "${steamcmddir}" == "${XDG_DATA_HOME:="${HOME}/.local/share"}/Steam" ]; then
		rm -rf "${HOME}/Steam"
	fi
}

fn_check_steamcmd_steamapp() {
	# Check that steamapp directory fixes issue #3481
	if [ ! -d "${serverfiles}/steamapps" ]; then
		mkdir -p "${serverfiles}/steamapps"
	fi
}

fn_check_steamcmd_ark() {
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

fn_check_steamcmd_clear() {
	# Will remove steamcmd dir if steamcmd package is installed.
	if [ "$(command -v steamcmd 2> /dev/null)" ] && [ -d "${rootdir}/steamcmd" ]; then
		rm -rf "${steamcmddir:?}"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_script_log_fail "Removing ${rootdir}/steamcmd"
		else
			fn_script_log_pass "Removing ${rootdir}/steamcmd"
		fi
	fi
}

fn_check_steamcmd_exec() {
	if [ "$(command -v steamcmd 2> /dev/null)" ]; then
		steamcmdcommand="steamcmd"
	else
		steamcmdcommand="./steamcmd.sh"
	fi
}

fn_update_steamcmd_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	fn_check_steamcmd_appmanifest
	# Uses appmanifest to find local build.
	localbuild=$(grep buildid "${appmanifestfile}" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)

	# Checks if localbuild variable has been set.
	if [ -z "${localbuild}" ]; then
		fn_print_fail "Checking local build: ${remotelocation}: missing local build info"
		fn_script_log_fail "Missing local build info"
		core_exit.sh
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_steamcmd_remotebuild() {
	# Get remote build info.
	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi

	# Removes appinfo.vdf as a fix for not always getting up to date version info from SteamCMD.
	if [ "$(find "${HOME}" -type f -name "appinfo.vdf" 2> /dev/null | wc -l)" -ne "0" ]; then
		find "${HOME}" -type f -name "appinfo.vdf" -exec rm -f {} \; 2> /dev/null
	fi

	# Set branch to public if no custom branch.
	if [ -z "${branch}" ]; then
		branch="public"
	fi

	# added as was failing GitHub Actions test. Running SteamCMD twice seems to fix it.
	if [ "${CI}" ]; then
		${steamcmdcommand} +login "${steamuser}" "${steampass}" +app_info_update 1 +quit > /dev/null 2>&1
	fi
	# password for branch not needed to check the buildid
	remotebuildversion=$(${steamcmdcommand} +login "${steamuser}" "${steampass}" +app_info_update 1 +app_info_print "${appid}" +quit | sed -e '/"branches"/,/^}/!d' | sed -n "/\"${branch}\"/,/}/p" | grep -m 1 buildid | tr -cd '[:digit:]')

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuildversion variable has been set.
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuildversion}" ] || [ "${remotebuildversion}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_steamcmd_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	# Update has been found or force update.
	if [ "${localbuild}" != "${remotebuildversion}" ] || [ "${forceupdate}" == "1" ]; then
		# Create update lockfile.
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuildversion}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		if [ -n "${betapassword}" ]; then
			echo -e "* Branch password: ${betapassword}"
		fi
		echo -e "https://steamdb.info/app/${appid}/"
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuildversion}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		if [ -n "${betapassword}" ]; then
			fn_script_log_info "Branch password: ${betapassword}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuildversion}"

		if [ "${commandname}" == "UPDATE" ]; then
			unset updateonstart
			check_status.sh
			# If server stopped.
			if [ "${status}" == "0" ]; then
				fn_dl_steamcmd
			# If server started.
			else
				fn_print_restart_warning
				exitbypass=1
				command_stop.sh
				fn_firstcommand_reset
				exitbypass=1
				fn_dl_steamcmd
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
			fi
			unset exitbypass
			date +%s > "${lockdir:?}/last-updated.lock"
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuildversion}${default}"
		if [ -n "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		if [ -n "${betapassword}" ]; then
			echo -e "* Branch password: ${betapassword}"
		fi
		echo -e "https://steamdb.info/app/${appid}/"
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuildversion}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		if [ -n "${betapassword}" ]; then
			fn_script_log_info "Branch password: ${betapassword}"
		fi
	fi
}

fn_appmanifest_info() {
	appmanifestfile=$(find -L "${serverfiles}/steamapps" -type f -name "appmanifest_${appid}.acf")
	appmanifestfilewc=$(find -L "${serverfiles}/steamapps" -type f -name "appmanifest_${appid}.acf" | wc -l)
}

fn_check_steamcmd_appmanifest() {
	fn_appmanifest_info
	# Multiple or no matching appmanifest files may sometimes be present.
	if [ "${appmanifestfilewc}" -ge "2" ]; then
		fn_print_error "Multiple appmanifest_${appid}.acf files found"
		fn_script_log_error "Multiple appmanifest_${appid}.acf files found"
		fn_print_dots "Removing x${appmanifestfilewc} appmanifest_${appid}.acf files"
		for appfile in ${appmanifestfile}; do
			rm -f "${appfile:?}"
		done
		appmanifestfilewc1="${appmanifestfilewc}"
		fn_appmanifest_info
		# if error can not be resolved.
		if [ "${appmanifestfilewc}" -ge "2" ]; then
			fn_print_fail "Unable to remove x${appmanifestfilewc} appmanifest_${appid}.acf files"
			fn_script_log_fail "Unable to remove x${appmanifestfilewc} appmanifest_${appid}.acf files"
			echo -e "* Check user permissions"
			for appfile in ${appmanifestfile}; do
				echo -e "	${appfile}"
			done
			core_exit.sh
		else
			fn_print_ok "Removed x${appmanifestfilewc1} appmanifest_${appid}.acf files"
			fn_script_log_pass "Removed x${appmanifestfilewc1} appmanifest_${appid}.acf files"
			fn_print_info_nl "Forcing update to correct issue"
			fn_script_log_info "Forcing update to correct issue"
			fn_dl_steamcmd
		fi
	elif [ "${appmanifestfilewc}" -eq "0" ]; then
		fn_print_error_nl "No appmanifest_${appid}.acf found"
		fn_script_log_error "No appmanifest_${appid}.acf found"
		fn_print_info_nl "Forcing update to correct issue"
		fn_script_log_info "Forcing update to correct issue"
		fn_dl_steamcmd
		fn_appmanifest_info
		if [ "${appmanifestfilewc}" -eq "0" ]; then
			fn_print_fail_nl "Still no appmanifest_${appid}.acf found"
			fn_script_log_fail "Still no appmanifest_${appid}.acf found"
			core_exit.sh
		fi
	fi

	# Checking for half completed updates.
	bytesdownloaded=$(grep BytesDownloaded "${appmanifestfile}" | tr -cd '[:digit:]')
	bytestodownload=$(grep BytesToDownload "${appmanifestfile}" | tr -cd '[:digit:]')
	if [ "${bytesdownloaded}" != "${bytestodownload}" ]; then
		fn_print_error_nl "BytesDownloaded and BytesToDownload do not match"
		fn_script_log_error "BytesDownloaded and BytesToDownload do not match"
		fn_print_info_nl "Forcing update to correct issue"
		fn_script_log_info "Forcing update to correct issue"
		fn_dl_steamcmd
	fi

	bytesstaged=$(grep BytesStaged "${appmanifestfile}" | tr -cd '[:digit:]')
	bytestostage=$(grep BytesToStage "${appmanifestfile}" | tr -cd '[:digit:]')
	if [ "${bytesstaged}" != "${bytestostage}" ]; then
		fn_print_error_nl "BytesStaged and BytesToStage do not match"
		fn_script_log_error "BytesStaged and BytesToStage do not match"
		fn_print_info_nl "Forcing update to correct issue"
		fn_script_log_info "Forcing update to correct issue"
		fn_dl_steamcmd
	fi

	# if engine is GoldSrc check SharedDepots exists in appmanifest_90.acf
	if [ "${engine}" == "goldsrc" ]; then
		shareddepotsexists=$(grep -c SharedDepots "${serverfiles}/steamapps/appmanifest_90.acf")
		if [ ! -f "${serverfiles}/steamapps/appmanifest_90.acf" ] || [ "${shareddepotsexists}" == "0" ]; then
			fn_print_error_nl "SharedDepots missing from appmanifest_90.acf"
			fn_script_log_error "SharedDepots missing from appmanifest_90.acf"
			fn_print_info_nl "Forcing update to correct issue"
			fn_script_log_info "Forcing update to correct issue"
			if [ "${shortname}" == "ahl" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "bb" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "cscz" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_80.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "css" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "dmc" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_40.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "dod" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_30.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "hldm" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "ns" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "opfor" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_50.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "ricochet" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_60.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "tfc" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_20.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "ts" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			elif [ "${shortname}" == "vs" ]; then
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_90.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_10.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
				fn_fetch_file_github "lgsm/data/appmanifest/${shortname}" "appmanifest_70.acf" "${serverfiles}/steamapps" "nochmodx" "norun" "noforce" "nohash"
			fi
			fn_dl_steamcmd
		fi
	fi
}
