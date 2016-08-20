#!/bin/bash
# LGSM update_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Handles updating using SteamCMD.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_update_steamcmd_dl(){
	check.sh
	info_config.sh
	fn_print_dots "SteamCMD"
	sleep 1
	fn_print_ok_nl "SteamCMD"
	fn_script_log_info "Starting SteamCMD"

	cd "${rootdir}/steamcmd"

	# Detects if unbuffer command is available.
	if [ $(command -v stdbuf) ]; then
		unbuffer="stdbuf -i0 -o0 -e0"
	fi

	if [ "${engine}" == "goldsource" ]; then
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" ${branch} +quit | tee -a "${scriptlog}"
	else
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" ${branch} +quit | tee -a "${scriptlog}"
	fi

	fix.sh
}

fn_appmanifest_info(){
	appmanifestfile=$(find "${filesdir}" -type f -name "appmanifest_${appid}.acf")
	appmanifestfilewc=$(find "${filesdir}" -type f -name "appmanifest_${appid}.acf"|wc -l)
}

fn_appmanifest_check(){
	fn_appmanifest_info
	# Multiple or no matching appmanifest files may sometimes be present.
	# This error is corrected if required.
	if [ "${appmanifestfilewc}" -ge "2" ]; then
		sleep 1
		fn_print_error "Multiple appmanifest_${appid}.acf files found"
		fn_script_log_error "Multiple appmanifest_${appid}.acf files found"
		sleep 2
		fn_print_dots "Removing x${appmanifestfilewc} appmanifest_${appid}.acf files"
		sleep 1
		for appfile in ${appmanifestfile}; do
			rm "${appfile}"
		done
		sleep 1
		appmanifestfilewc1="${appmanifestfilewc}"
		fn_appmanifest_info
		if [ "${appmanifestfilewc}" -ge "2" ]; then
			fn_print_fail "Unable to remove x${appmanifestfilewc} appmanifest_${appid}.acf files"
			fn_script_log_fatal "Unable to remove x${appmanifestfilewc} appmanifest_${appid}.acf files"
			sleep 1
			echo "	* Check user permissions"
			for appfile in ${appmanifestfile}; do
				echo "	${appfile}"
			done
			core_exit.sh
		else
			fn_print_ok "Removed x${appmanifestfilewc1} appmanifest_${appid}.acf files"
			fn_script_log_pass "Removed x${appmanifestfilewc1} appmanifest_${appid}.acf files"
			sleep 1
			fn_print_info_nl "Forcing update to correct issue"
			fn_script_log_info "Forcing update to correct issue"
			sleep 1
			fn_update_steamcmd_dl
			fn_update_request_log
		fi
	elif [ "${appmanifestfilewc}" -eq "0" ]; then
		fn_print_error "No appmanifest_${appid}.acf found"
		fn_script_log_error "No appmanifest_${appid}.acf found"
		sleep 1
		fn_print_info_nl "Forcing update to correct issue"
		fn_script_log_info "Forcing update to correct issue"
		sleep 1
		fn_update_steamcmd_dl
		fn_update_request_log
		fn_appmanifest_info
		if [ "${appmanifestfilewc}" -eq "0" ]; then
			fn_print_fatal "Still no appmanifest_${appid}.acf found"
			fn_script_log_fatal "Still no appmanifest_${appid}.acf found"
			core_exit.sh
		fi
	fi
}

fn_update_request_log(){
	# Checks for server update requests from server logs.
	fn_print_dots "Checking for update: Server logs"
	fn_script_log_info "Checking for update: Server logs"
	sleep 1
	requestrestart=$(grep -Ec "MasterRequestRestart" "${consolelog}")
	if [ "${requestrestart}" -ge "1" ]; then
		fn_print_ok_nl "Checking for update: Server logs: Update requested"
		fn_script_log_pass "Checking for update: Server logs: Update requested"
		sleep 1
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
		sleep 1
	fi
}

fn_update_steamcmd_check(){
	fn_appmanifest_check
	# Checks for server update from SteamCMD
	fn_print_dots "Checking for update: SteamCMD"
	fn_script_log_info "Checking for update: SteamCMD"
	sleep 1

	# Gets currentbuild
	currentbuild=$(grep buildid "${appmanifestfile}" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)

	# Removes appinfo.vdf as a fix for not always getting up to date version info from SteamCMD
	cd "${rootdir}/steamcmd"
	if [ -f "${HOME}/Steam/appcache/appinfo.vdf" ]; then
		rm -f "${HOME}/Steam/appcache/appinfo.vdf"
	fi

	# Set branch for updateinfo
	IFS=' ' read -a branchsplits <<< "${branch}"
	if [ "${#branchsplits[@]}" -gt 1 ]; then
		branchname="${branchsplits[1]}"
	else
		branchname="public"
	fi

	# Gets availablebuild info
	availablebuild=$(./steamcmd.sh +login "${steamuser}" "${steampass}" +app_info_update 1 +app_info_print "${appid}" +app_info_print "${appid}" +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"${branchname}\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)
	if [ -z "${availablebuild}" ]; then
		fn_print_fail "Checking for update: SteamCMD"
		sleep 1
		fn_print_fail_nl "Checking for update: SteamCMD: Not returning version info"
		fn_script_log_fatal "Checking for update: SteamCMD: Not returning version info"
		core_exit.sh
	else
		fn_print_ok "Checking for update: SteamCMD"
		fn_script_log_pass "Checking for update: SteamCMD"
		sleep 1
	fi

	if [ "${currentbuild}" != "${availablebuild}" ]; then
		fn_print_ok "Checking for update: SteamCMD: Update available"
		fn_script_log_pass "Checking for update: SteamCMD: Update available"
		echo -e "\n"
		echo -e "Update available:"
		sleep 1
		echo -e "	Current build: ${red}${currentbuild}${default}"
		echo -e "	Available build: ${green}${availablebuild}${default}"
		echo -e ""
		echo -e "	https://steamdb.info/app/${appid}/"
		sleep 1
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
	fn_update_steamcmd_check
fi