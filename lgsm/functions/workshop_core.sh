#!/bin/bash
# LinuxGSM workshop_core.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Core functions for mods list/install/update/remove

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Files and Directories.
steam="${steamcmd}/steam"
workshopmodsdir="${serverfiles}/mods"
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
}

fn_workshop_get_list() {
	workshoplist=($(echo "${workshopmods}" | tr ";" "\n"))
}

fn_workshop_get_latest_mod_version() {
	local modid="$1"
	local serverresp="$(curl -s -d "itemcount=1&publishedfileids[0]=${modid}" "http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1")"
	local remupd=
	if [[ "${serverresp}" =~ \"hcontent_file\":[[:space:]]*([^,]*) ]]; then
       remupd="${BASH_REMATCH[1]}"
    fi
    echo "${remupd}" | tr -d '"'
}

fn_workshop_get_name_from_steam() {
	local modid="$1"
	local serverresp="$(curl -s -d "itemcount=1&publishedfileids[0]=${modid}" "http://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1")"
	local title=
	if [[ "${serverresp}" =~ \"title\":[[:space:]]*([^,]*) ]]; then
       title="${BASH_REMATCH[1]}"
    fi
    echo "${title}" | tr -d '"'
}

fn_workshop_check_mod_update() {
	local modid="$1"
	if [ ! -f "${workshopmodsdldir}/steamapps/workshop/appworkshop_${gameappid}.acf" ]; then return 0; fi
	local instmft="$(sed -n '/^\t"WorkshopItemsInstalled"$/,/^\t[}]$/{/^\t\t"'"${modid}"'"$/,/^\t\t[}]$/{s|^\t\t\t"manifest"\t\t"\(.*\)"$|\1|p}}' <"${workshopmodsdldir}/steamapps/workshop/appworkshop_${gameappid}.acf")"
	if [ -z "${instmft}" ]; then return 0; fi
	local remmft="$(fn_workshop_get_latest_mod_version "${modid}")"
	if [[ -n "${remmft}" && "${instmft}" != "${remmft}" ]]; then
		return 0 # true
	fi
	return 1 # false
}

fn_workshop_is_mod_copy_needed(){
	local modid="$1"
	local modsrc="${workshopmodsdldir}/steamapps/workshop/content/${gameappid}/${modid}"
	if [ ! -f "${workshopmodsdir}/${modid}/meta.cpp" ]; then return 0; fi
	local instmft="$(grep "timestamp" ${workshopmodsdir}/${modid}/meta.cpp)"
	if [ -z "${instmft}" ]; then return 0; fi
	local remmft="$(grep "timestamp" ${modsrc}/meta.cpp)"
	if [[ -n "${remmft}" && "${instmft}" != "${remmft}" ]]; then
		return 0 # true
	fi
	return 1
}


fn_workshop_get_mod_name(){
	local modid="$1"
	if ! [ -d "${workshopmodsdir}/${modid}" ]; then
		echo "$(grep -Po '(?<=name = ").+?(?=")' ${workshopmodsdir}/${modid}/mod.cpp)"
	elif ! [ -d "${workshopmodsdldir}/steamapps/workshop/content/${gameappid}/${modid}" ]; then
		echo "$(grep -Po '(?<=name = ").+?(?=")' ${workshopmodsdldir}/steamapps/workshop/content/${gameappid}/${modid}/mod.cpp)"
	else
		echo "$(fn_workshop_get_name_from_steam ${modid})"
	fi
}

# Convert workshop mod files to lowercase if needed.
fn_workshop_lowercase() {
	# local modid="$1"
	# local modname="$(fn_workshop_get_mod_name $modid)"
	# Arma 3 requires lowercase
	if [ "${engine}" == "realvirtuality" ]; then
		echo -en "Converting ${modname} files to lowercase..."
		fn_sleep_time
		fn_script_log_info "Converting ${modname} files to lowercase"
		# Total files and directories for the mod, to output to the user
		fileswc=$(find "${workshopmodsdir}" | wc -l)
		# Total uppercase files and directories for the mod, to output to the user
		filesupperwc=$(find "${workshopmodsdir}/" -name '*[[:upper:]]*' | wc -l)
		fn_script_log_info "Found ${filesupperwc} uppercase files out of ${fileswc}, converting"
		echo -en "Found ${filesupperwc} uppercase files out of ${fileswc}, converting..."
		# Works but not on folders
		# while IFS= read -r -d '' file; do
        # 	mv -b -- "$file" "${file,,}" 2>/dev/null
		# done < <(find ${workshopmodsdir} -depth -name '*[A-Z]*' -print0)
		# while IFS= read -r -d '' file; do
        # 	mv -b -- "$file" "${file,,}" 2>/dev/null
		# done < <(find ${workshopmodsdir}/ -depth -name '*[A-Z]*' -print0)

		# Works bu not on WSL?
		# https://unix.stackexchange.com/questions/20222/change-entire-directory-tree-to-lower-case-names/20232#20232
		#
		find ${workshopmodsdir} -depth -exec sh -c '
			t=${0%/*}/$(printf %s "${0##*/}" | tr "[:upper:]" "[:lower:]");
			[ "$t" = "$0" ] || mv -i "$0" "$t"
		' {} \;

		#
		# Coudln't get this to work.
		#
		# Convert files and directories starting from the deepest to prevent issues (-depth argument)
		# while IFS= read -r -d '' src; do
		# 	# We have to convert only the last file from the path, otherwise we will fail to convert anything if a parent dir has any uppercase
		# 	# therefore, we have to separate the end of the filename to only lowercase it rather than the whole line
		# 	# Gather parent dir, filename lowercase filename, and set lowercase destination name
		# 	latestparentdir=$(dirname "${src}")
		# 	latestfilelc=$(basename "${src}" | tr '[:upper:]' '[:lower:]')
		# 	dst="${latestparentdir}/${latestfilelc}"
		# 	# Only convert if destination does not already exist for some reason
		# 	if [ ! -e "${dst}" ]; then
		# 		# Finally we can rename the file
		# 		mv "${src}" "${dst}"
		# 		# Exit if it fails for any reason
		# 		local exitcode=$?
		# 		if [ "${exitcode}" != 0 ]; then
		# 			fn_print_fail_eol_nl
		# 			core_exit.sh
		# 		fi
		# 	fi
		# done < <(find "${workshopmodsdir}" -depth -name '*[[:upper:]]*' -print0)
		fn_print_ok_eol_nl
	fi
}

# # Copy the mod into serverfiles.
fn_workshop_copy_destination() {
	local modid="$1"
	local modname="$(fn_workshop_get_mod_name ${modid})"
	if fn_workshop_is_mod_copy_needed ${modid}; then
		echo "Copying mod ${modname} (${modid})"
		# If workshop mod exists in installation folder, delete it for clean install
		if [ -d "${workshopmodsdir}/${modid}" ]; then
			rm -rf "${workshopmodsdir}/${modid}"
		fi
		modsrc="${workshopmodsdldir}/steamapps/workshop/content/${gameappid}/${modid}"
		cp -fa ${modsrc} ${workshopmodsdir}
		if [ "${engine}" == "realvirtuality" ]; then
			modkey="${workshopmodsdldir}/steamapps/workshop/content/${gameappid}/${modid}/keys"
			if ! [ -d "${modkey}" ]; then
				modkey="$steamcmd/steamapps/workshop/content/${gameappid}/${modid}/Keys"
			fi
			if ! [ -d "${modkey}" ]; then
				modkey="$steamcmd/steamapps/workshop/content/${gameappid}/${modid}/key"
			fi
			if ! [ -d "${modkey}" ]; then
				modkey="$steamcmd/steamapps/workshop/content/${gameappid}/${modid}/Key"
			fi
			if ! [ -d "${modkey}" ]; then
				echo "Mod ${modname} seems to be missing key folder. Tring to copy key from the main folder."
				cp -fa "${workshopmodsdir}/${modid}/*.bikey" ${keysdir}
			else
				cp -fa ${modkey}/*.bikey ${keysdir}
			fi
		fi
	else
		echo "Mod ${modname}  is already in mods folder."
	fi
	# echo -en "copying ${modprettyname} to ${modinstalldir}..."
	# fn_sleep_time
	# cp -Rf "${extractdir}/." "${modinstalldir}/"
	# local exitcode=$?
	# if [ "${exitcode}" != 0 ]; then
	# 	fn_print_fail_eol_nl
	# 	fn_script_log_fatal "Copying ${modprettyname} to ${modinstalldir}"
	# else
	# 	fn_print_ok_eol_nl
	# 	fn_script_log_pass "Copying ${modprettyname} to ${modinstalldir}"
	# fi
}

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
	if [ ! -d "${workshopmodsdir}" ]; then
		echo -en "creating Steam Workshop install directory ${workshopmodsdir}..."
		mkdir -p "${workshopmodsdir}"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod install directory ${workshopmodsdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod install directory ${workshopmodsdir}"
		fi
	fi
}

# Counts how many mods were installed.
fn_workshop_count_installed() {
	if [ -f "${workshopmodsdir}" ]; then
		installedworkshopmodscount=$(ls -l "${workshopmodsdir}" | grep -c ^d)
	else
		installedworkshopmodscount=0
	fi
}

# Exits if no mods were installed.
fn_workshop_check_installed() {
	# Count installed mods.
	fn_workshop_count_installed
	# If no mods are found.
	if [ ${installedworkshopmodscount}/* -eq 0 ]; then
		echo -e ""
		fn_print_failure_nl "No installed workshop mods or addons were found"
		echo -e " * Install mods using LinuxGSM first with: ./${selfname} workshop-install"
		fn_script_log_error "No installed workshop mods or addons were found."
		core_exit.sh
	fi
}

# Builds list of installed Steam Workshop mods.
fn_workshop_installed_list() {
	fn_workshop_count_installed
	for folder in ${workshopmodsdir}/*; do
		# If it is a folder, then use it's name as Steam Workshop Mod Id
		if [ -d "${folder}" ]; then
			echo -e "$(fn_workshop_get_mod_name $(basename ${f})) ($(basename ${f}))"
		fi
	done
	if [ "${installedworkshopmodscount}" ]; then
		fn_script_log_info "${installedworkshopmodscount} addons/mods are currently installed"
	fi
}
