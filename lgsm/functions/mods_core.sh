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

# Create mods directory if it doesn't exist
# Assuming the game is already installed as mods_list.sh checked for it.
fn_mods_dir(){
	if [ ! -d "${modinstalldir}" ]; then
		fn_script_log_info "Creating mods directory: ${modinstalldir}"
		fn_print_dots "Creating mods directory"
		sleep 1
		mkdir -p "${modinstalldir}"
		fn_print_ok "Created mods directory"
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

fn_mod_extract(){
	# fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
	filename="${modfilename}"
	if [ ! -d "${extractdir}" ]; then
		mkdir -p "${extractdir}"
	fi
	fn_script_log "Extracting ${modprettyname} to ${extractdir}"
	fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
}

fn_mod_lowercase(){
	# Converting files to lowercase
	if [ "${modlowercase}" == "LowercaseOn" ]; then
		fn_print_dots "Converting ${modprettyname} files to lowercase"
		fn_script_log "Converting ${modprettyname} files to lowercase"
		find "${extractdir}" -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
		fn_print_ok "Converting ${modprettyname} files to lowercase"
		sleep 1
	fi
}

fn_remove_cfg_files(){
	# Remove config file after extraction for updates set by ${modkeepfiles}
	if [ "${modkeepfiles}" !=  "OVERWRITE" ]&&[ "${modkeepfiles}" != "NOUPDATE" ]; then
		# Upon mods updates, config files should not be overwritten
		# We will just remove these files before copying the mod to the destination
		# Let's count how many files there are to remove
		fn_print_dots "Allow for preserving ${modprettyname} config files"
		sleep 0.5
		removefilesamount="$(echo "${modkeepfiles}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modgames" using the ";" separator
		for ((removefilesindex=1; removefilesindex < ${removefilesamount}; removefilesindex++)); do
			# Put current file we're looking for into a variable
			filetoremove="$( echo "${modkeepfiles}" | awk -F ';' -v x=${removefilesindex} '{ print $x }' )"
			# If it matches an existing file that have been extracted
			if [ -f "${extractdir}/${filetoremove}" ]||[ -d "${extractdir}/${filetoremove}" ]; then
				# Then delete the file!
				rm -R "${extractdir}/${filetoremove}"
				# Write this file path in a tmp file, to rebuild a full file list
				if [ ! -f "${modsdatadir}/.removedfiles.tmp" ]; then
					touch "${modsdatadir}/.removedfiles.tmp"
				fi
					echo "${filetoremove}" >> "${modsdatadir}/.removedfiles.tmp"
			fi
		done
		fn_print_ok "Allow for preserving ${modprettyname} config files"
	fi
}

fn_mod_fileslist(){
	# Create lgsm/data/mods directory
	if [ ! -d "${modsdatadir}" ]; then
		mkdir -p "${modsdatadir}"
		fn_script_log "Created ${modsdatadir}"
	fi
	fn_print_dots "Building ${modcommand}-files.list"
	fn_script_log "Building ${modcommand}-files.list"
	# ${modsdatadir}/${modcommand}-files.list
	find "${extractdir}" -mindepth 1 -printf '%P\n' > ${modsdatadir}/${modcommand}-files.list
	fn_script_log "Writing file list: ${modsdatadir}/${modcommand}-files.list}"
	# Adding removed files if needed
	if [ -f "${modsdatadir}/.removedfiles.tmp" ]; then
		cat "${modsdatadir}/.removedfiles.tmp" >> ${modsdatadir}/${modcommand}-files.list
	fi
	fn_print_ok "Building ${modcommand}-files.list"
}

fn_mod_copy_destination(){
	# Destination directory: ${modinstalldir}
	fn_print_dots "Copying ${modprettyname} to ${modinstalldir}"
	fn_script_log "Copying ${modprettyname} to ${modinstalldir}"
	cp -Rf "${extractdir}/." "${modinstalldir}/"
	sleep 0.5
	fn_print_ok "Copying ${modprettyname} to ${modinstalldir}"
}

# Check if the mod is already installed and warn the user
fn_mod_already_installed(){
	if [ -f "${modslockfilefullpath}" ]; then
		if [ -n "$(cat "${modslockfilefullpath}" | grep "${modcommand}")" ]; then
			fn_print_warning_nl "${modprettyname} has already been installed."
			echo " * Config files, if any, might be overwritten."
			echo " * Press ctrl + c to abort."
			sleep 4
		fi
	fn_script_log "${modprettyname} is already installed, overwriting any file."
	fi
}

# Add the mod to the installed mods list
fn_mod_add_list(){
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
	# Input mod name to lockfile
	if [ ! -n "$(cat "${modslockfilefullpath}" | grep "${modcommand}")" ]; then
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

fn_postinstall_tasks(){
	# Prevent addons folder from being removed by clearing them in: ${modsdatadir}/${modcommand}-files.list
	# Check file validity
	fn_check_files_list
	# Output to the user
	fn_print_dots "Rearranging ${modcommand}-files.list"
	sleep 1
	fn_script_log_info "Rearranging ${modcommand}-files.list"
	# What lines/files to remove from file list
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
		sed -i "/^addons/metamod$/d" "${modsdatadir}/${modcommand}-files.list"
		sed -i "/^addons/metamod/sourcemod.vdf$/d" "${modsdatadir}/${modcommand}-files.list"
	fi
	fn_print_ok "Rearranging ${modcommand}-files.list"
}

## mods_list.sh arrays

# Define all variables from a mod at once when index is set to a separator
fn_mod_info(){
# If for some reason no index is set, none of this can work
if [ -z "$index" ]; then
	fn_print_error "index variable not set. Please report an issue to LGSM Team."
	echo "* https://github.com/GameServerManagers/LinuxGSM/issues"
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
	spaces=" "
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
}

fn_gsm_requirements
fn_mods_scrape_urls
fn_mods_info
fn_mods_available
