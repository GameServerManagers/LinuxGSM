#!/bin/bash
# LinuxGSM update_steamcmd.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles updating using SteamCMD.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_steamcmd_dl(){
	fn_print_start_nl "${remotelocation}"
	fn_script_log_info "Updating server: ${remotelocation}"

	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi

	# Unbuffer will allow the output of steamcmd not buffer allowing a smooth output.
	# unbuffer us part of the expect package.
	if [ "$(command -v unbuffer)" ]; then
		unbuffer="unbuffer"
	fi

	# Validate will be added as a parameter if required.
	if [ "${commandname}" == "VALIDATE" ]||[ "${commandname}" == "INSTALL" ]; then
		validate="validate"
	fi

	# To do error checking for SteamCMD the output of steamcmd will be saved to a log.
	steamcmdlog="${lgsmlogdir}/${selfname}-steamcmd.log"

	counter=0
	while [ "${counter}" == "0" ]||[ "${exitcode}" != "0" ]; do
		counter=$((counter+1))
		# Select SteamCMD parameters
		# If GoldSrc (appid 90) servers. GoldSrc (appid 90) require extra commands.
		if [ "${appid}" == "90" ]; then
			# If using a specific branch.
			if [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" "${branch}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" "${branch}" +app_update "${appid}" ${validate} +quit | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		# Force Windows Platform type.
		elif [ "${shortname}" == "ac" ]; then
			if [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" ${validate} +quit | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		# All other servers.
		else
			if [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" ${validate} +quit | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		fi

		# Error checking for SteamCMD. Some errors will loop to try again and some will just exit.
		exitcode=$?
		if [ -n "$(grep "Error!" "${steamcmdlog}" | tail -1)" ]||[ -n "$(grep "ERROR!" "${steamcmdlog}" | tail -1)" ]; then
			# Not enough space.
			if [ -n "$(grep "0x202" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "Updating server: ${remotelocation}: Not enough space to download server files"
				fn_script_log_fatal "Updating server: ${remotelocation}: Not enough space to download server files"
				core_exit.sh
			# Need tp purchase game.
			elif [ -n "$(grep "No subscription" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "Updating server: ${remotelocation}: Game not owned by any authorised accounts"
				fn_script_log_fatal "Updating server: ${remotelocation}: Game not owned by any authorised accounts"
				core_exit.sh
			# Two-factor authentication failure
			elif [ -n "$(grep "Two-factor code mismatch" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "Updating server: ${remotelocation}: Two-factor authentication failure"
				fn_script_log_fatal "Updating server: ${remotelocation}: Two-factor authentication failure"
				core_exit.sh
			# Update did not finish.
			elif [ -n "$(grep "0x402" "${steamcmdlog}" | tail -1)" ]||[ -n "$(grep "0x602" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "Updating server: ${remotelocation}: Update required but not completed - check network"
				fn_script_log_error "Updating server: ${remotelocation}: Update required but not completed - check network"
			else
				fn_print_error2_nl "Updating server: ${remotelocation}: Unknown error occured"
				fn_script_log_error "Updating server: ${remotelocation}: Unknown error occured"
			fi
		elif [ "${exitcode}" != "0" ]; then
			fn_print_error2_nl "Updating server: ${remotelocation}: Exit code: ${exitcode}"
			fn_script_log_error "Updating server: ${remotelocation}: Exit code: ${exitcode}"
		else
			fn_print_complete_nl "Updating server: ${remotelocation}"
			fn_script_log_pass "Updating server: ${remotelocation}"
		fi

		if [ "${counter}" -gt "10" ]; then
			fn_print_failure_nl "Updating server: ${remotelocation}: Did not complete the download, too many retrys"
			fn_script_log_fatal "Updating server: ${remotelocation}: Did not complete the download, too many retrys"
			core_exit.sh
		fi
	done
}

fn_update_steamcmd_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	fn_appmanifest_check
	# Uses appmanifest to find local build.
	localbuild=$(grep buildid "${appmanifestfile}" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)

	# Set branch for updateinfo.
	IFS=' ' read -ra branchsplits <<< "${branch}"
	if [ "${#branchsplits[@]}" -gt 1 ]; then
		branchname="${branchsplits[1]}"
	else
		branchname="public"
	fi

	# Checks if localbuild variable has been set.
	if [ -z "${localbuild}" ]||[ "${localbuild}" == "null" ]; then
		fn_print_fail "Checking local build: ${remotelocation}"
		fn_script_log_fatal "Checking local build"
		core_exit.sh
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_steamcmd_remotebuild(){
	# Gets remote build info.
	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi

	# Removes appinfo.vdf as a fix for not always getting up to date version info from SteamCMD.
	if [ "$(find "${HOME}" -type f -name "appinfo.vdf" | wc -l)" -ne "0" ]; then
		find "${HOME}" -type f -name "appinfo.vdf" -exec rm -f {} \;
	fi

	remotebuild=$(${steamcmdcommand} +login "${steamuser}" "${steampass}" +app_info_update 1 +app_info_print "${appid}" +quit | sed '1,/branches/d' | sed "1,/${branchname}/d" | grep -m 1 buildid | tr -cd '[:digit:]')
	if [ "${installer}" != "1" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fatal "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ]||[ "${remotebuild}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fatal "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_steamcmd_compare(){
	fn_print_dots "Checking for update: ${remotelocation}"
	if [ "${localbuild}" != "${remotebuild}" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		if [ -v "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		echo -e "https://steamdb.info/app/${appid}/"
		echo -en "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -v "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuild}"

		unset updateonstart
		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			fn_update_steamcmd_dl
		# If server started.
		else
			fn_print_stop_warning_update
			exitbypass=1
			command_stop.sh
			exitbypass=1
			fn_update_steamcmd_dl
			exitbypass=1
			command_start.sh
		fi
		date +%s > "${lockdir}/lastupdate.lock"
		alert="update"
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${remotebuild}${default}"
		if [ -v "${branch}" ]; then
			echo -e "* Branch: ${branch}"
		fi
		echo -e "https://steamdb.info/app/${appid}/"
		echo -en "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		if [ -v "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
	fi
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
			fn_script_log_fatal "Unable to remove x${appmanifestfilewc} appmanifest_${appid}.acf files"
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
			fn_update_steamcmd_dl
		fi
	elif [ "${appmanifestfilewc}" -eq "0" ]; then
		fn_print_error_nl "No appmanifest_${appid}.acf found"
		fn_script_log_error "No appmanifest_${appid}.acf found"
		fn_print_info_nl "Forcing update to correct issue"
		fn_script_log_info "Forcing update to correct issue"
		fn_update_steamcmd_dl
		fn_appmanifest_info
		if [ "${appmanifestfilewc}" -eq "0" ]; then
			fn_print_fail_nl "Still no appmanifest_${appid}.acf found"
			fn_script_log_fatal "Still no appmanifest_${appid}.acf found"
			core_exit.sh
		fi
	fi
}

# The location where the builds are checked and downloaded.
remotelocation="SteamCMD"
check.sh

fn_print_dots "${remotelocation}"

if [ "${forceupdate}" == "1" ]; then
	# forceupdate bypasses update checks.
	if [ "${status}" != "0" ]; then
		fn_print_stop_warning_update
		exitbypass=1
		command_stop.sh
		fn_commandname
		fn_update_steamcmd_dl
		date +%s > "${lockdir}/lastupdate.lock"
		exitbypass=1
		command_start.sh
	else
		fn_update_steamcmd_dl
		date +%s > "${lockdir}/lastupdate.lock"
	fi
else
	fn_update_steamcmd_localbuild
	fn_update_steamcmd_remotebuild
	fn_update_steamcmd_compare
fi
