#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Core functions for mods list/install/update/remove

local commandname="MODS"
local commandaction="Core functions for mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

## Useful variables
# Files and Directories
modstmpdir="${tmpdir}/mods"
extractdir="${modstmpdir}/extracted"
modsdatadir="${lgsmdir}/data/mods"
modslockfile="installed-mods-listing"
modslockfilefullpath="${modsdatadir}/${modslockfile}"
# Database initialization
mods_list.sh

# Sets some gsm requirements
fn_gsm_requirements(){
	# If tmpdir variable doesn't exist, LGSM is too old
	if [ -z "${tmpdir}" ]||[ -z "${lgsmdir}" ]; then
		fn_print_fail "Your LGSM version is too old."
		echo " * Please do a full update, including ${selfname} script."
		core_exit.sh
	fi
}

# Create mods files and directories if it doesn't exist
# Assuming the game is already installed as mods_list.sh checked for it.
fn_mods_files(){
	if [ ! -d "${modinstalldir}" ]; then
		fn_script_log_info "Creating mods directory: ${modinstalldir}"
		fn_print_dots "Creating mods directory"
		sleep 0.5
		mkdir -p "${modinstalldir}"
		fn_print_ok "Created mods directory"
		sleep 0.5
	fi
	# Create lgsm/data/mods directory
	if [ ! -d  "${modsdatadir}" ]; then
		mkdir -p "${modsdatadir}"
		fn_script_log "Created ${modsdatadir}"
	fi
	# Create lgsm/data/${modslockfile}
	if [ ! -f "${modslockfilefullpath}" ]; then
		touch "${modslockfilefullpath}"
		fn_script_log "Created ${modslockfilefullpath}"
	fi
}

# Clear mod download directory so that there is only one file in it since we don't the file name and extention
fn_clear_tmp_mods(){
	if [ -d "${modstmpdir}" ]; then
		rm -r "${modstmpdir}"
		fn_script_log "Clearing temp mod download directory: ${modstmpdir}"
	fi
	# Clear temp file list as well
	if [ -f "${modsdatadir}/.removedfiles.tmp" ]; then
		rm "${modsdatadir}/.removedfiles.tmp"
	fi
}

# Create tmp download mod directory
fn_mods_tmpdir(){
	if [ ! -d "${modstmpdir}" ]; then
		mkdir -p "${modstmpdir}"
		fn_script_log "Creating temp mod download directory: ${modstmpdir}"
	fi
}

# Fetches mod URL
fn_mod_dl(){
	# fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
	fileurl="${modurl}"
	filedir="${modstmpdir}"
	filename="${modfilename}" 
	fn_script_log "Downloading mods to ${modstmpdir}"
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}"
	# Check if variable is valid checking if file has been downloaded and exists
	if [ ! -f "${modstmpdir}/${modfilename}" ]; then
		fn_print_fail "An issue occurred upon downloading ${modprettyname}"
		core_exit.sh
	fi
}

# Extract the mod
fn_mod_extract(){
	# fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
	filename="${modfilename}"
	if [ ! -d "${extractdir}" ]; then
		mkdir -p "${extractdir}"
	fi
	fn_script_log "Extracting ${modprettyname} to ${extractdir}"
	fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
}

# Convert mod files to lowercase if needed
fn_mod_lowercase(){
	if [ "${modlowercase}" == "LowercaseOn" ]; then
		fn_print_dots "Converting ${modprettyname} files to lowercase"
		sleep 0.5
		fn_script_log "Converting ${modprettyname} files to lowercase"
		find "${extractdir}" -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
		fn_print_ok "Converting ${modprettyname} files to lowercase"
		sleep 0.5
	fi
}

# Don't overwrite specified files upon update (set by ${modkeepfiles})
# For that matter, remove cfg files after extraction before copying them to destination
fn_remove_cfg_files(){
	if [ "${modkeepfiles}" !=  "OVERWRITE" ]&&[ "${modkeepfiles}" != "NOUPDATE" ]; then
		fn_print_dots "Allow for not overwriting ${modprettyname} config files"
		fn_script_log "Allow for not overwriting ${modprettyname} config files"
		sleep 0.5
		# Let's count how many files there are to remove
		removefilesamount="$(echo "${modkeepfiles}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modkeepfiles" using the ";" separator
		for ((removefilesindex=1; removefilesindex < ${removefilesamount}; removefilesindex++)); do
			# Put current file we're looking for into a variable
			filetoremove="$( echo "${modkeepfiles}" | awk -F ';' -v x=${removefilesindex} '{ print $x }' )"
			# If it matches an existing file that have been extracted
			if [ -f "${extractdir}/${filetoremove}" ]||[ -d "${extractdir}/${filetoremove}" ]; then
				# Then delete the file!
				rm -r "${extractdir}/${filetoremove}"
				# Write this file path in a tmp file, to rebuild a full file list since it is rebuilt upon update
				if [ ! -f "${modsdatadir}/.removedfiles.tmp" ]; then
					touch "${modsdatadir}/.removedfiles.tmp"
				fi
					echo "${filetoremove}" >> "${modsdatadir}/.removedfiles.tmp"
			fi
		done
		fn_print_ok "Allow for preserving ${modprettyname} config files"
		sleep 0.5
	fi
}

# Create ${modcommand}-files.list containing the full extracted file/directory list
fn_mod_fileslist(){
	fn_print_dots "Building ${modcommand}-files.list"
	fn_script_log "Building ${modcommand}-files.list"
	sleep 0.5
	# ${modsdatadir}/${modcommand}-files.list
	find "${extractdir}" -mindepth 1 -printf '%P\n' > ${modsdatadir}/${modcommand}-files.list
	fn_script_log "Writing file list: ${modsdatadir}/${modcommand}-files.list}"
	# Adding removed files if needed
	if [ -f "${modsdatadir}/.removedfiles.tmp" ]; then
		cat "${modsdatadir}/.removedfiles.tmp" >> ${modsdatadir}/${modcommand}-files.list
	fi
	fn_print_ok "Building ${modcommand}-files.list"
	sleep 0.5
}

# Copy the mod to the destination ${modinstalldir}
fn_mod_copy_destination(){
	fn_print_dots "Copying ${modprettyname} to ${modinstalldir}"
	fn_script_log "Copying ${modprettyname} to ${modinstalldir}"
	sleep 0.5
	cp -Rf "${extractdir}/." "${modinstalldir}/"
	fn_print_ok "Copying ${modprettyname} to ${modinstalldir}"
	sleep 0.5
}

# Check if the mod is already installed and warn the user
fn_mod_already_installed(){
	if [ -f "${modslockfilefullpath}" ]; then
		if [ -n "$(sed -n "/^${modcommand}$/p" "${modslockfilefullpath}")" ]; then
			fn_print_warning_nl "${modprettyname} has already been installed"
			sleep 1
			echo " * Config files, if any, might be overwritten."
			while true; do
				read -e -i "y" -p "Continue? [Y/n]" yn
				case $yn in
				[Yy]* ) break;;
				[Nn]* ) echo Exiting; core_exit.sh;;
				* ) echo "Please answer yes or no.";;
				esac
				done
		fi
	fn_script_log "${modprettyname} is already installed, overwriting any file."
	fi
}

# Add the mod to the installed mods list
fn_mod_add_list(){
	# Append modname to lockfile if it's not already in it
	if [ ! -n "$(sed -n "/^${modcommand}$/p" "${modslockfilefullpath}")" ]; then
		echo "${modcommand}" >> "${modslockfilefullpath}"
		fn_script_log "${modcommand} added to ${modslockfile}"
	fi
}

fn_check_files_list(){
	# File list must exist and be valid before any operation on it
	if [ -f "${modsdatadir}/${modcommand}-files.list" ]; then
	# How many lines is the file list
		modsfilelistsize="$(cat "${modsdatadir}/${modcommand}-files.list" | wc -l)"
		# If file list is empty
		if [ $modsfilelistsize -eq 0 ]; then
			fn_print_error_nl "${modcommand}-files.list is empty"
			echo "Exiting."
			fn_scrip_log_fatal "${modcommand}-files.list is empty"
			exitcode="2"
			core_exit.sh
		fi
	else
			fn_print_error_nl "${modsdatadir}/${modcommand}-files.list don't exist"
			echo "Exiting."
			fn_scrip_log_fatal "${modsdatadir}/${modcommand}-files.list don't exist"
			exitcode="2"
			core_exit.sh
	fi
}

# Apply some post-install fixes to make sure everything will be fine
fn_postinstall_tasks(){
	# Prevent sensitive directories from being erased upon uninstall by removing them them from: ${modsdatadir}/${modcommand}-files.list
	# Check file validity
	fn_check_files_list
	# Output to the user
	fn_print_dots "Rearranging ${modcommand}-files.list"
	sleep 0.5
	fn_script_log_info "Rearranging ${modcommand}-files.list"
	# What lines/files to remove from file list (end var with a ";" separator)
	removefromlist="cfg;addons;"
	# Loop through files to remove from file list,
	# that way these files won't get removed upon uninstall
	# How many elements to remove from list
	removefromlistamount="$(echo "${removefromlist}" | awk -F ';' '{ print NF }')"
	# Test all subvalue of "removefromlist" using the ";" separator
	for ((filesindex=1; filesindex < ${removefromlistamount}; filesindex++)); do
		# Put current file into test variable
		removefilevar="$( echo "${removefromlist}" | awk -F ';' -v x=${filesindex} '{ print $x }' )"
		# Then delete matching line(s)!
		sed -i "/^${removefilevar}$/d" "${modsdatadir}/${modcommand}-files.list"
	done
	
	# Sourcemod fix
	# Remove metamod from sourcemod fileslist
	if [ "${modcommand}" == "sourcemod" ]; then
		# Remove addons/metamod & addons/metamod/sourcemod.vdf from ${modcommand}-files.list
		sed -i "/^addons\/metamod$/d" "${modsdatadir}/${modcommand}-files.list"
		sed -i "/^addons\/metamod\/sourcemod.vdf$/d" "${modsdatadir}/${modcommand}-files.list"
	fi
	fn_print_ok "Rearranging ${modcommand}-files.list"
	sleep 0.5
}

# Apply some post-uninstall fixes to make sure everything will be fine
fn_postuninstall_tasks(){
	# Oxide fix
	# Oxide replaces server files, so a validate is required after uninstall
	if [ "${engine}" == "unity3d" ]&&[[ "${modprettyname}" == *"Oxide"* ]]; then
		fn_print_information_nl "Validating to restore original ${gamename} files replaced by Oxide"
		fn_script_log "Validating to restore original ${gamename} files replaced by Oxide"
		exitbypass="1"
		command_validate.sh
		unset exitbypass
	fi
}

#########################
## mods_list.sh arrays ##
#########################

## Define info for a mod

# Define all variables from a mod at once when index is set to a separator
fn_mod_info(){
# If for some reason no index is set, none of this can work
if [ -z "$index" ]; then
	fn_print_error "index variable not set. Please report an issue to LGSM Team."
	echo "* https://github.com/GameServerManagers/LinuxGSM/issues"
	exitcode="1"
	core_exit.sh
fi
	modcommand="${mods_global_array[index+1]}"
	modprettyname="${mods_global_array[index+2]}"
	modurl="${mods_global_array[index+3]}"
	modfilename="${mods_global_array[index+4]}"
	modsubdirs="${mods_global_array[index+5]}"
	modlowercase="${mods_global_array[index+6]}"
	modinstalldir="${mods_global_array[index+7]}"
	modkeepfiles="${mods_global_array[index+8]}"
	modengines="${mods_global_array[index+9]}"
	modgames="${mods_global_array[index+10]}"
	modexcludegames="${mods_global_array[index+11]}"
	modsite="${mods_global_array[index+12]}"
	moddescription="${mods_global_array[index+13]}"
}

## Mod compatibility check

# Find out if a game is compatible with a mod from a modgames (list of games supported by a mod) variable
fn_compatible_mod_games(){
	# Reset test value
	modcompatiblegame="0"
	# If value is set to GAMES (ignore)
	if [ "${modgames}" != "GAMES" ]; then
		# How many games we need to test
		gamesamount="$(echo "${modgames}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modgames" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${gamesamount}; gamevarindex++)); do
			# Put current game name into modtest variable
			gamemodtest="$( echo "${modgames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If game name matches
			if [ "${gamemodtest}" == "${gamename}" ]; then
				# Mod is compatible !
				modcompatiblegame="1"
			fi
		done
	fi
}

# Find out if an engine is compatible with a mod from a modengines (list of engines supported by a mod) variable
fn_compatible_mod_engines(){
	# Reset test value
	modcompatibleengine="0"
	# If value is set to ENGINES (ignore)
	if [ "${modengines}" != "ENGINES" ]; then
		# How many engines we need to test
		enginesamount="$(echo "${modengines}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modengines" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${enginesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable
			enginemodtest="$( echo "${modengines}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches
			if [ "${enginemodtest}" == "${engine}" ]; then
				# Mod is compatible !
				modcompatibleengine="1"
			fi
		done
	fi
}

# Find out if a game is not compatible with a mod from a modnotgames (list of games not supported by a mod) variable
fn_not_compatible_mod_games(){
	# Reset test value
	modeincompatiblegame="0"
	# If value is set to NOTGAMES (ignore)
	if [ "${modexcludegames}" != "NOTGAMES" ]; then
		# How many engines we need to test
		excludegamesamount="$(echo "${modexcludegames}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modexcludegames" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${excludegamesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable
			excludegamemodtest="$( echo "${modexcludegames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches
			if [ "${excludegamemodtest}" == "${gamename}" ]; then
				# Mod is compatible !
				modeincompatiblegame="1"
			fi
		done
	fi
}

# Sums up if a mod is compatible or not with modcompatibility=0/1
fn_mod_compatible_test(){
	# Test game and engine compatibility
	fn_compatible_mod_games
	fn_compatible_mod_engines
	fn_not_compatible_mod_games
	if [ "${modeincompatiblegame}" == "1" ]; then
		modcompatibility="0"
	elif [ "${modcompatibleengine}" == "1" ]||[ "${modcompatiblegame}" == "1" ]; then
		modcompatibility="1"
	else
		modcompatibility="0"
	fi
}

# Checks if a mod is compatibile for installation
# Provides available mods for installation
# Provides commands for mods installation
fn_mods_available(){
	# First, reset variables
	compatiblemodslist=()
	availablemodscommands=()
	modprettynamemaxlength="0"
	modsitemaxlength="0"
	moddescriptionmaxlength="0"
	modcommandmaxlength="0"
	# Find compatible games
	# Find separators through the global array
	for ((index="0"; index <= ${#mods_global_array[@]}; index++)); do
		# If current value is a separator; then
		if [ "${mods_global_array[index]}" == "${modseparator}" ]; then
			# Set mod variables
			fn_mod_info
			# Test if game is compatible
			fn_mod_compatible_test
			# If game is compatible
			if [ "${modcompatibility}" == "1" ]; then
				# Put it into an array to prepare user output
				compatiblemodslist+=( "${modprettyname}" "${modcommand}" "${modsite}" "${moddescription}" )
				# Keep available commands in an array to make life easier
				availablemodscommands+=( "${modcommand}" )
			fi
		fi
	done
}

# Output available mods in a nice way to the user
fn_mods_show_available(){
	# Set and reset vars
	compatiblemodslistindex=0
	# As long as we're within index values
	while [ "${compatiblemodslistindex}" -lt "${#compatiblemodslist[@]}" ]; do
		# Set values for convenience
		displayedmodname="${compatiblemodslist[compatiblemodslistindex]}"
		displayedmodcommand="${compatiblemodslist[compatiblemodslistindex+1]}"
		displayedmodsite="${compatiblemodslist[compatiblemodslistindex+2]}"
		displayedmoddescription="${compatiblemodslist[compatiblemodslistindex+3]}"
		# Output mods to the user
		echo -e "\e[1m${displayedmodname}\e[0m - ${displayedmoddescription} - ${displayedmodsite}"
		echo -e " * \e[36m${displayedmodcommand}\e[0m"
		# Increment index from the amount of values we just displayed
		let "compatiblemodslistindex+=4"
	done
	# If no mods are found
	if [ -z "${compatiblemodslist}" ]; then
		fn_print_fail "No mods are currently available for ${gamename}."
		core_exit.sh
	fi
}

# Checks if mods have been installed
# Also returns ${installedmodscount} if mods were found
fn_check_installed_mods(){
	# Count installed mods
	if [ -f "${modslockfilefullpath}" ]; then
		installedmodscount="$(cat "${modslockfilefullpath}" | wc -l)"
	fi
}

# A simple function to exit if no mods were installed
# Also returns ${installedmodscount} if mods were found
fn_mods_exit_if_not_installed(){
	# Checks if mods have been installed
	# Also returns ${installedmodscount} if mods were found
	fn_check_installed_mods
	# If no mods lockfile is found or if it is empty
	if [ ! -f "${modslockfilefullpath}" ]||[ -z "${installedmodscount}" ]||[ $installedmodscount -le 0 ]; then
		fn_print_information_nl "No installed mods or addons were found"
		echo " * Install mods using LGSM first with: ./${selfname} mods-install"
		fn_script_log_info "No installed mods or addons were found."
		core_exit.sh
	fi
}

# Builds installed mods list and sets available commands according to installed mods
# (requires ${installedmodscount} from fn_check_installed_mods)
fn_mods_available_commands_from_installed(){
	# Set/reset variables
	installedmodsline="1"
	installedmodslist=()
	# Loop through every line of the installed mods list ${modslockfilefullpath}
	while [ $installedmodsline -le $installedmodscount ]; do
		currentmod="$(sed "${installedmodsline}q;d" "${modslockfilefullpath}")"
		# Get mod info to make sure mod exists
		fn_mod_get_info_from_command
		# Add the mod to available commands
		installedmodslist+=( "${modcommand}" )
		# Increment line check
		let installedmodsline=installedmodsline+1
	done
}

# Displays a detailed list of installed mods
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
fn_installed_mods_detailed_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	# Were now based on ${installedmodslist} array's values
	# We're gonna go through all available commands, get details and display them to the user
	for ((index=0; index <= ${#installedmodslist[@]}; index++)); do
		# Current mod is the "index" value of the array we're going through
		currentmod="${installedmodslist[index]}"
		# Get mod info
		fn_mod_get_info_from_command
		# Display mod info to the user
		echo -e "\e[1m${modprettyname}\e[0m - ${moddescription} - ${modsite}"
		echo -e " * \e[36m${modcommand}\e[0m"
	done
}

# Displays a detailed list of installed mods
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
fn_installed_mods_medium_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	# Were now based on ${installedmodslist} array's values
	# We're gonna go through all available commands, get details and display them to the user
	for ((index=0; index <= ${#installedmodslist[@]}; index++)); do
		# Current mod is the "index" value of the array we're going through
		currentmod="${installedmodslist[index]}"
		# Get mod info
		fn_mod_get_info_from_command
		# Display mod info to the user
		echo -e "\e[36m${modcommand}\e[0m - \e[1m${modprettyname}\e[0m - ${moddescription}"
	done
}

# Displays a simple list of installed mods
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
# This list is only displayed when some mods are installed 
fn_installed_mods_light_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	if [ $installedmodscount -gt 0 ]; then
		echo "================================="
		echo "Installed mods/addons"
		# Were now based on ${installedmodslist} array's values
		# We're gonna go through all available commands, get details and display them to the user
		for ((index=0; index <= ${#installedmodslist[@]}; index++)); do
			# Current mod is the "index" value of the array we're going through
			currentmod="${installedmodslist[index]}"
			# Get mod info
			fn_mod_get_info_from_command
			# Display simple mod info to the user
			echo -e " * \e[1m${modprettyname}\e[0m"
		done
	fi
}

# Displays a simple list of installed mods for mods-update command
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
fn_installed_mods_update_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	echo "================================="
	echo "Installed mods/addons"
	# Were now based on ${installedmodslist} array's values
	# We're gonna go through all available commands, get details and display them to the user
	for ((index=0; index <= ${#installedmodslist[@]}; index++)); do
		# Current mod is the "index" value of the array we're going through
		currentmod="${installedmodslist[index]}"
		# Get mod info
		fn_mod_get_info_from_command
		# Display simple mod info to the user according to the update policy
		# If modkeepfiles is not set for some reason, that's a problem
		if [ -z "${modkeepfiles}" ]; then
			fn_script_log_error "Couldn't find update policy for ${modprettyname}"
			fn_print_error_nl "Couldn't find update policy for ${modprettyname}"
			exitcode="1"
			core_exit.sh
		# If the mod won't get updated
		elif [ "${modkeepfiles}" == "NOUPDATE" ]; then
			echo -e " * \e[31m${modprettyname}\e[0m (won't be updated)"
		# If the mode is just overwritten
		elif [ "${modkeepfiles}" == "OVERWRITE" ]; then
			echo -e " * \e[1m${modprettyname}\e[0m (overwrite)"
		else			
			echo -e " * \e[33m${modprettyname}\e[0m (common custom files remain untouched)"
		fi
	done
}

# Get details of a mod any (relevant and unique, such as full mod name or install command) value
fn_mod_get_info_from_command(){
	# Variable to know when job is done
	modinfocommand="0"
	# Find entry in global array
	for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
		# When entry is found
		if [ "${mods_global_array[index]}" == "${currentmod}" ]; then
			# Go back to the previous "MOD" separator
			for ((index=index; index <= ${#mods_global_array[@]}; index--)); do
				# When "MOD" is found
				if [ "${mods_global_array[index]}" == "MOD" ]; then
					# Get info
					fn_mod_info
					modinfocommand="1"
					break
				fi
			done
		fi
		# Exit the loop if job is done
		if [ "${modinfocommand}" == "1" ]; then
			break
		fi
	done
	# What happens if mod is not found
	if [ "${modinfocommand}" == "0" ]; then
		fn_script_log_error "Couldn't find information for ${currentmod}"
		fn_print_error_nl "Couldn't find information for ${currentmod}"
		exitcode="1"
		core_exit.sh
	fi
}

fn_gsm_requirements
fn_mods_scrape_urls
fn_mods_info
fn_mods_available
