#!/bin/bash
# LinuxGSM update_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating using SteamCMD.

local commandname="UPDATE"
local commandaction="Update"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh

fn_update_steamcmd_dl(){
	info_config.sh
	fn_print_dots "SteamCMD"
	sleep 0.5
	fn_print_ok_nl "SteamCMD"
	fn_script_log_info "Starting SteamCMD"

	cd "${steamcmddir}" || exit

	# Detects if unbuffer command is available for 32 bit distributions only.
	info_distro.sh
	if [ "$(command -v stdbuf)" ]&&[ "${arch}" != "x86_64" ]; then
		unbuffer="stdbuf -i0 -o0 -e0"
	fi

	cd "${steamcmddir}" || exit
	if [ "${engine}" == "goldsource" ]; then
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_info_print 70 +app_set_config 90 mod "${appidmod}" +app_update "${appid}" ${branch} +quit | tee -a "${lgsmlog}"
	else
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" ${branch} +quit | tee -a "${lgsmlog}"
		if [ "${gamename}" == "Classic Offensive" ]; then
			${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid_co}" ${branch} +quit | tee -a "${lgsmlog}"
		fi
	fi

	fix.sh
}

fn_appmanifest_info(){
	appmanifestfile=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf")
	appmanifestfilewc=$(find "${serverfiles}" -type f -name "appmanifest_${appid}.acf" | wc -l)
}

fn_appmanifest_check(){
	fn_appmanifest_info
	# Multiple or no matching appmanifest files may sometimes be present.
	# This error is corrected if required.
	if [ "${appmanifestfilewc}" -ge "2" ]; then
		sleep 0.5
		fn_print_error "Multiple appmanifest_${appid}.acf files found"
		fn_script_log_error "Multiple appmanifest_${appid}.acf files found"
		sleep 2
		fn_print_dots "Removing x${appmanifestfilewc} appmanifest_${appid}.acf files"
		sleep 0.5
		for appfile in ${appmanifestfile}; do
			rm "${appfile}"
		done
		sleep 0.5
		appmanifestfilewc1="${appmanifestfilewc}"
		fn_appmanifest_info
		if [ "${appmanifestfilewc}" -ge "2" ]; then
			fn_print_fail "Unable to remove x${appmanifestfilewc} appmanifest_${appid}.acf files"
			fn_script_log_fatal "Unable to remove x${appmanifestfilewc} appmanifest_${appid}.acf files"
			sleep 0.5
			echo "	* Check user permissions"
			for appfile in ${appmanifestfile}; do
				echo "	${appfile}"
			done
			core_exit.sh
		else
			fn_print_ok "Removed x${appmanifestfilewc1} appmanifest_${appid}.acf files"
			fn_script_log_pass "Removed x${appmanifestfilewc1} appmanifest_${appid}.acf files"
			sleep 0.5
			fn_print_info_nl "Forcing update to correct issue"
			fn_script_log_info "Forcing update to correct issue"
			sleep 0.5
			fn_update_steamcmd_dl
			fn_update_request_log
		fi
	elif [ "${appmanifestfilewc}" -eq "0" ]; then
		fn_print_error_nl "No appmanifest_${appid}.acf found"
		fn_script_log_error "No appmanifest_${appid}.acf found"
		sleep 0.5
		fn_print_info_nl "Forcing update to correct issue"
		fn_script_log_info "Forcing update to correct issue"
		sleep 0.5
		fn_update_steamcmd_dl
		fn_update_request_log
		fn_appmanifest_info
		if [ "${appmanifestfilewc}" -eq "0" ]; then
			fn_print_fail_nl "Still no appmanifest_${appid}.acf found"
			fn_script_log_fatal "Still no appmanifest_${appid}.acf found"
			core_exit.sh
		fi
	fi
}

fn_update_request_log(){
	# Checks for server update requests from server logs.
	fn_print_dots "Checking for update: Server logs"
	fn_script_log_info "Checking for update: Server logs"
	sleep 0.5
	if [ -f "${consolelog}" ]; then
		requestrestart=$(grep -Ec "MasterRequestRestart" "${consolelog}")
	else
		requestrestart="0"
	fi
	if [ "${requestrestart}" -ge "1" ]; then
		fn_print_ok_nl "Checking for update: Server logs: Update requested"
		fn_script_log_pass "Checking for update: Server logs: Update requested"
		sleep 0.5
		echo ""
		echo -en "Applying update.\r"
		sleep 1
		echo -en "Applying update..\r"
		sleep 1
		echo -en "Applying update...\r"
		sleep 1
		echo -en "\n"

		unset updateonstart
		check_status.sh
		if [ "${status}" != "0" ]; then
			exitbypass=1
			command_stop.sh
			fn_update_steamcmd_dl
			exitbypass=1
			command_start.sh
		else
			fn_update_steamcmd_dl
		fi
		alert="update"
		alert.sh
	else
		fn_print_ok "Checking for update: Server logs: No update requested"
		sleep 0.5
	fi
}

fn_update_steamcmd_check(){
	appid="${1}"
	fn_appmanifest_check
	# Checks for server update from SteamCMD
	fn_print_dots "Checking for update: SteamCMD"
	fn_script_log_info "Checking for update: SteamCMD"
	sleep 0.5

	# Gets currentbuild
	currentbuild=$(grep buildid "${appmanifestfile}" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)

	# Removes appinfo.vdf as a fix for not always getting up to date version info from SteamCMD

	if [ -f "${HOME}/Steam/appcache/appinfo.vdf" ]; then
		rm -f "${HOME}/Steam/appcache/appinfo.vdf"
	fi

	# Set branch for updateinfo
	IFS=' ' read -ra branchsplits <<< ${branch}
	if [ "${#branchsplits[@]}" -gt 1 ]; then
		branchname="${branchsplits[1]}"
	else
		branchname="public"
	fi

	# Gets availablebuild info
	cd "${steamcmddir}" || exit
	availablebuild=$(./steamcmd.sh +login "${steamuser}" "${steampass}" +app_info_update 1 +app_info_print "${appid}" +app_info_print "${appid}" +quit | sed -n '/branch/,$p' | grep -m 1 buildid | tr -cd '[:digit:]')
	if [ -z "${availablebuild}" ]; then
		fn_print_fail "Checking for update: SteamCMD"
		sleep 0.5
		fn_print_fail_nl "Checking for update: SteamCMD: Not returning version info"
		fn_script_log_fatal "Checking for update: SteamCMD: Not returning version info"
		core_exit.sh
	else
		fn_print_ok "Checking for update: SteamCMD"
		fn_script_log_pass "Checking for update: SteamCMD"
		sleep 0.5
	fi

	if [ "${currentbuild}" != "${availablebuild}" ]; then
		fn_print_ok "Checking for update: SteamCMD: Update available"
		fn_script_log_pass "Checking for update: SteamCMD: Update available"
		echo -e "\n"
		echo -e "Update available:"
		sleep 0.5
		echo -e "	Current build: ${red}${currentbuild}${default}"
		echo -e "	Available build: ${green}${availablebuild}${default}"
		echo -e "	https://steamdb.info/app/${appid}/"
		sleep 0.5
		echo ""
		echo -en "Applying update.\r"
		sleep 1
		echo -en "Applying update..\r"
		sleep 1
		echo -en "Applying update...\r"
		sleep 1
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Current build: ${currentbuild}"
		fn_script_log_info "Available build: ${availablebuild}"
		fn_script_log_info "${currentbuild} > ${availablebuild}"

		unset updateonstart
		check_status.sh
		if [ "${status}" != "0" ]; then
			exitbypass=1
			command_stop.sh
			fn_update_steamcmd_dl
			exitbypass=1
			command_start.sh
		else
			fn_update_steamcmd_dl
		fi
		alert="update"
		alert.sh
	else
		fn_print_ok "Checking for update: SteamCMD: No update available"
		fn_script_log_pass "Checking for update: SteamCMD: No update available"
		echo -e "\n"
		echo -e "No update available:"
		echo -e "	Current version: ${green}${currentbuild}${default}"
		echo -e "	Available version: ${green}${availablebuild}${default}"
		echo -e "	https://steamdb.info/app/${appid}/"
		echo -e ""
		fn_script_log_info "Current build: ${currentbuild}"
		fn_script_log_info "Available build: ${availablebuild}"
	fi
}

if [ "${engine}" == "goldsource" ]||[ "${forceupdate}" == "1" ]; then
	# Goldsource servers bypass checks as fn_update_steamcmd_check does not work for appid 90 servers.
	# forceupdate bypasses checks
	check_status.sh
	if [ "${status}" != "0" ]; then
		exitbypass=1
		command_stop.sh
		fn_update_steamcmd_dl
		exitbypass=1
		command_start.sh
	else
		fn_update_steamcmd_dl
	fi
else
	fn_update_request_log
	fn_update_steamcmd_check "${appid}"
	# will also check for second appid
	if [ "${gamename}" == "Classic Offensive" ]; then
		fn_update_steamcmd_check "${appid_co}"
	fi
fi
