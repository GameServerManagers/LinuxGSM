#!/bin/bash
# LinuxGSM workshop_core.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Core functions for mods list/install/update/remove

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Files and Directories.
steam="${steamcmd}/steam"
workhshopmodsdir="${serverfiles}/mods"
keysdir="${serverfiles}/keys"
workshopmodsdldir="${lgsmdir}/workshop"
workshopmodslist="workshop-mods.txt"
workshopmodslistfullpath="${configdir}/${workshopmodslist}"
workshopmoddownloaddir="${steam}/steamapps/workshop/content/${appid}"

## Installation.
core_steamcmd.sh
fn_check_steamcmd_exec

# # Download management.
# For Workshop Mod Downloads, we need to use game app id, not the server app id.
fn_workshop_download() {
	local modid=$1
	local workshopmodsrcdir="${workshopmoddownloaddir}/${modid}"

	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi

	# Unbuffer will allow the output of steamcmd not buffer allowing a smooth output.
	# unbuffer us part of the expect package.
	if [ "$(command -v unbuffer)" ]; then
		unbuffer="unbuffer"
	fi

	# To do error checking for SteamCMD the output of steamcmd will be saved to a log.
	steamcmdlog="${lgsmlogdir}/${selfname}-steamcmd.log"

	# clear previous steamcmd log
	if [ -f "${steamcmdlog}" ]; then
		rm -f "${steamcmdlog:?}"
	fi
	counter=0
	while [ "${counter}" == "0" ] || [ "${exitcode}" != "0" ]; do
		counter=$((counter + 1))
		# Select SteamCMD parameters
		${unbuffer} ${steamcmdcommand} +force_install_dir "${workshopmodsdldir}" +login "${steamuser}" "${steampass}" +workshop_download_item "${gameappid}" "${modid}" +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"

		# Error checking for SteamCMD. Some errors will loop to try again and some will just exit.
		# Check also if we have more errors than retries to be sure that we do not loop to many times and error out.
		exitcode=$?
		if [ -n "$(grep -i "Error!" "${steamcmdlog}" | tail -1)" ] && [ "$(grep -ic "Error!" "${steamcmdlog}")" -ge "${counter}" ]; then
			# Not enough space.
			if [ -n "$(grep "0x202" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download workshop mod"
				fn_script_log_fatal "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download workshop mod"
				core_exit.sh
				# Not enough space.
			elif [ -n "$(grep "0x212" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download workshop mod"
				fn_script_log_fatal "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download workshop mod"
				core_exit.sh
			# Need tp purchase game.
			elif [ -n "$(grep "No subscription" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Steam account does not have a license for the required game"
				fn_script_log_fatal "${commandaction} ${selfname}: ${remotelocation}: Steam account does not have a license for the required game"
				core_exit.sh
			# Two-factor authentication failure
			elif [ -n "$(grep "Two-factor code mismatch" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Two-factor authentication failure"
				fn_script_log_fatal "${commandaction} ${selfname}: ${remotelocation}: Two-factor authentication failure"
				core_exit.sh
			# Incorrect Branch password
			elif [ -n "$(grep "Password check for AppId" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: betapassword is incorrect"
				fn_script_log_fatal "${commandaction} ${selfname}: ${remotelocation}: betapassword is incorrect"
				core_exit.sh
			# Update did not finish.
			elif [ -n "$(grep "0x402" "${steamcmdlog}" | tail -1)" ] || [ -n "$(grep "0x602" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Update required but not completed - check network"
				fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Update required but not completed - check network"
			else
				fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Unknown error occured"
				echo -en "Please provide content log to LinuxGSM developers https://linuxgsm.com/steamcmd-error"
				fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Unknown error occured"
			fi
		elif [ "${exitcode}" != "0" ]; then
			fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Exit code: ${exitcode}"
			fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Exit code: ${exitcode}"
		else
			fn_print_complete_nl "${commandaction} ${selfname}: ${remotelocation}"
			fn_script_log_pass "${commandaction} ${selfname}: ${remotelocation}"
		fi

		if [ "${counter}" -gt "10" ]; then
			fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Did not complete the download, too many retrys"
			fn_script_log_fatal "${commandaction} ${selfname}: ${remotelocation}: Did not complete the download, too many retrys"
			core_exit.sh
		fi
	done

	# if [ -f "${workshopmodsrcdir}/meta.cpp" ]; then
    #             echo "Mod $modid downloaded"
    #             modsrcdirs[$modid]="$modsrcdir"
    #             return 0
	# else
	# 		echo "Mod $modid was not successfully downloaded"
	# 		return 1
	# fi
}

fn_workshop_get_list() {
	workshoplist=($(echo $workshopmods | tr ";" "\n"))
}

fn_workshop_get_latest_mod_version() {
	local modid="$1"
            local serverresp="$(curl -s -d "itemcount=1&publishedfileids[0]=${modid}" "http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1")"
            local remupd=
             if [[ "$serverresp" =~ \"hcontent_file\":[[:space:]]*([^,]*) ]]; then
           remupd="${BASH_REMATCH[1]}"
     fi
     echo "$remupd" | tr -d '"'
}

fn_workshop_check_mod_update() {
	local modid="$1"
	if [ ! -f "${workshopmodsdldir}/steamapps/workshop/appworkshop_${gameappid}.acf" ]; then return 0; fi
	local instmft="$(sed -n '/^\t"WorkshopItemsInstalled"$/,/^\t[}]$/{/^\t\t"'"${modid}"'"$/,/^\t\t[}]$/{s|^\t\t\t"manifest"\t\t"\(.*\)"$|\1|p}}' <"${workshopmodsdldir}/steamapps/workshop/appworkshop_${gameappid}.acf")"
	if [ -z "$instmft" ]; then return 0; fi
	local remmft="$(fn_workshop_get_latest_mod_version "$modid")"
	if [[ -n "${remmft}" && "${instmft}" != "${remmft}" ]]; then
		return 0 # true
	fi
	return 1 # false
}

fn_workshop_is_mod_copy_needed(){
	local modid="$1"
	local modsrc="${workshopmodsdldir}/steamapps/workshop/content/${gameappid}/${modid}"
	if [ ! -f "${workhshopmodsdir}/${modid}/meta.cpp" ]; then return 0; fi
	local instmft="$(grep "timestamp" ${workhshopmodsdir}/${modid}/meta.cpp)"
	if [ -z "$instmft" ]; then return 0; fi
	local remmft="$(grep "timestamp" $modsrc/meta.cpp)"
	if [[ -n "${remmft}" && "${instmft}" != "${remmft}" ]]; then
		return 0 # true
	fi
	return 1
}


fn_workshop_get_mod_name(){
	local modid="$1"
	#echo "$(grep -Po '(?<=name = ").+?(?=")' ${workshopmodsdir}/steamapps/workshop/content/${gameappid}/${modid}/mod.cpp)"
	echo "$(grep -Po '(?<=name = ").+?(?=")' ${workshopmodsdldir}/steamapps/workshop/content/${gameappid}/${modid}/mod.cpp)"
}

# Convert workshop mod files to lowercase if needed.
fn_workshop_lowercase() {
	local modid="$1"
	# Arma 3 requires lowercase
	if [ "${engine}" == "realvirtuality" ]; then
		echo -en "converting ${modprettyname} files to lowercase..."
		fn_sleep_time
		fn_script_log_info "Converting ${modprettyname} files to lowercase"
		# Total files and directories for the mod, to output to the user
		fileswc=$(find "${extractdir}" | wc -l)
		# Total uppercase files and directories for the mod, to output to the user
		filesupperwc=$(find "${extractdir}" -name '*[[:upper:]]*' | wc -l)
		fn_script_log_info "Found ${filesupperwc} uppercase files out of ${fileswc}, converting"
		echo -en "Found ${filesupperwc} uppercase files out of ${fileswc}, converting..."
		# Convert files and directories starting from the deepest to prevent issues (-depth argument)
		while read -r src; do
			# We have to convert only the last file from the path, otherwise we will fail to convert anything if a parent dir has any uppercase
			# therefore, we have to separate the end of the filename to only lowercase it rather than the whole line
			# Gather parent dir, filename lowercase filename, and set lowercase destination name
			latestparentdir=$(dirname "${src}")
			latestfilelc=$(basename "${src}" | tr '[:upper:]' '[:lower:]')
			dst="${latestparentdir}/${latestfilelc}"
			# Only convert if destination does not already exist for some reason
			if [ ! -e "${dst}" ]; then
				# Finally we can rename the file
				mv "${src}" "${dst}"
				# Exit if it fails for any reason
				local exitcode=$?
				if [ "${exitcode}" != 0 ]; then
					fn_print_fail_eol_nl
					core_exit.sh
				fi
			fi
		done < <(find "${extractdir}" -depth -name '*[[:upper:]]*')
		fn_print_ok_eol_nl
	fi
}

# # Copy the mod into serverfiles.
# fn_mod_copy_destination() {
# 	echo -en "copying ${modprettyname} to ${modinstalldir}..."
# 	fn_sleep_time
# 	cp -Rf "${extractdir}/." "${modinstalldir}/"
# 	local exitcode=$?
# 	if [ "${exitcode}" != 0 ]; then
# 		fn_print_fail_eol_nl
# 		fn_script_log_fatal "Copying ${modprettyname} to ${modinstalldir}"
# 	else
# 		fn_print_ok_eol_nl
# 		fn_script_log_pass "Copying ${modprettyname} to ${modinstalldir}"
# 	fi
# }

# ## Information Gathering.

# # Get details of a mod any (relevant and unique, such as full mod name or install command) value.
# fn_mod_get_info() {
# 	# Variable to know when job is done.
# 	modinfocommand="0"
# 	# Find entry in global array.
# 	for ((index = 0; index <= ${#mods_global_array[@]}; index++)); do
# 		# When entry is found.
# 		if [ "${mods_global_array[index]}" == "${currentmod}" ]; then
# 			# Go back to the previous "MOD" separator.
# 			for ((index = index; index <= ${#mods_global_array[@]}; index--)); do
# 				# When "MOD" is found.
# 				if [ "${mods_global_array[index]}" == "MOD" ]; then
# 					# Get info.
# 					fn_mods_define
# 					modinfocommand="1"
# 					break
# 				fi
# 			done
# 		fi
# 		# Exit the loop if job is done.
# 		if [ "${modinfocommand}" == "1" ]; then
# 			break
# 		fi
# 	done

# 	# What happens if mod is not found.
# 	if [ "${modinfocommand}" == "0" ]; then
# 		fn_script_log_error "Could not find information for ${currentmod}"
# 		fn_print_error_nl "Could not find information for ${currentmod}"
# 		core_exit.sh
# 	fi
# }

# # Builds list of installed mods.
# # using installed-mods.txt grabing mod info from mods_list.sh.
# fn_mods_installed_list() {
# 	fn_mods_count_installed
# 	# Set/reset variables.
# 	installedmodsline="1"
# 	installedmodslist=()
# 	modprettynamemaxlength="0"
# 	modsitemaxlength="0"
# 	moddescriptionmaxlength="0"
# 	modcommandmaxlength="0"
# 	# Loop through every line of the installed mods list ${modsinstalledlistfullpath}.
# 	while [ "${installedmodsline}" -le "${installedmodscount}" ]; do
# 		currentmod=$(sed "${installedmodsline}q;d" "${modsinstalledlistfullpath}")
# 		# Get mod info to make sure mod exists.
# 		fn_mod_get_info
# 		# Add the mod to available commands.
# 		installedmodslist+=("${modcommand}")
# 		# Increment line check.
# 		((installedmodsline++))
# 	done
# 	if [ "${installedmodscount}" ]; then
# 		fn_script_log_info "${installedmodscount} addons/mods are currently installed"
# 	fi
# }

# ## Directory management.

# Create mods files and directories if it doesn't exist.
fn_create_workshop_dir() {
	# Create lgsm data modsdir.
	if [ ! -d "${workshopmodsdldir}" ]; then
		echo -en "creating LinuxGSM Steam Workshop data directory ${workshopmodsdldir}..."
		mkdir -p "${workshopmodsdldir}"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod download dir ${workshopmodsdldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod download dir ${workshopmodsdldir}"
		fi
	fi
	# Create mod install directory.
	if [ ! -d "${workhshopmodsdir}" ]; then
		echo -en "creating Steam Workshop install directory ${workhshopmodsdir}..."
		mkdir -p "${workhshopmodsdir}"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod install directory ${workhshopmodsdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod install directory ${workhshopmodsdir}"
		fi
	fi
}

# # Create tmp download mod directory.
# fn_mods_create_tmp_dir() {
# 	if [ ! -d "${modstmpdir}" ]; then
# 		mkdir -p "${modstmpdir}"
# 		exitcode=$?
# 		echo -en "creating mod download directory ${modstmpdir}..."
# 		if [ "${exitcode}" != 0 ]; then
# 			fn_print_fail_eol_nl
# 			fn_script_log_fatal "Creating mod download directory ${modstmpdir}"
# 			core_exit.sh
# 		else
# 			fn_print_ok_eol_nl
# 			fn_script_log_pass "Creating mod download directory ${modstmpdir}"
# 		fi
# 	fi
# }

# # Remove the tmp mod download directory when finished.
# fn_mods_clear_tmp_dir() {
# 	if [ -d "${modstmpdir}" ]; then
# 		echo -en "clearing mod download directory ${modstmpdir}..."
# 		rm -fr "${modstmpdir:?}"
# 		exitcode=$?
# 		if [ "${exitcode}" != 0 ]; then
# 			fn_print_fail_eol_nl
# 			fn_script_log_fatal "Clearing mod download directory ${modstmpdir}"
# 			core_exit.sh
# 		else
# 			fn_print_ok_eol_nl
# 			fn_script_log_pass "Clearing mod download directory ${modstmpdir}"
# 		fi

# 	fi
# 	# Clear temp file list as well.
# 	if [ -f "${modsdir}/.removedfiles.tmp" ]; then
# 		rm -f "${modsdir:?}/.removedfiles.tmp"
# 	fi
# }

# Counts how many mods were installed.
fn_workshop_count_installed() {
	if [ -f "${workhshopmodsdir}" ]; then
		installedmodscount=$(ls -l "${workhshopmodsdir}" | grep -c ^d)
	else
		installedmodscount=0
	fi
}

# Exits if no mods were installed.
fn_workshop_check_installed() {
	# Count installed mods.
	fn_workshop_count_installed
	# If no mods are found.
	if [ ${installedmodscount} -eq 0 ]; then
		echo -e ""
		fn_print_failure_nl "No installed workshop mods or addons were found"
		echo -e " * Install mods using LinuxGSM first with: ./${selfname} workshop-install"
		fn_script_log_error "No installed workshop mods or addons were found."
		core_exit.sh
	fi
}

# fn_mod_exist() {
# 	modreq=$1
# 	# requires one parameter, the mod
# 	if [ -f "${modsdir}/${modreq}-files.txt" ]; then
# 		# how many lines is the file list
# 		modsfilelistsize=$(wc -l < "${modsdir}/${modreq}-files.txt")
# 		# if file list is empty
# 		if [ "${modsfilelistsize}" -eq 0 ]; then
# 			fn_mod_required_fail_exist "${modreq}"
# 		fi
# 	else
# 		fn_mod_required_fail_exist "${modreq}"
# 	fi
# }

# fn_mod_required_fail_exist() {
# 	modreq=$1
# 	# requires one parameter, the mod
# 	fn_script_log_fatal "${modreq}-files.txt is empty: unable to find ${modreq} installed"
# 	echo -en "* Unable to find '${modreq}' which is required prior to installing this mod..."
# 	fn_print_fail_eol_nl
# 	core_exit.sh
# }

# ## Database initialisation.

# mods_list.sh
# fn_mods_available
