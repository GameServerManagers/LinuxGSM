#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Core functions for mods list/install/update/remove

local commandname="MODS"
local commandaction="addons/mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Files and Directories
modsdir="${lgsmdir}/mods"
modstmpdir="${modsdir}/tmp"
extractdir="${modstmpdir}/extract"
modsinstalledlist="installed-mods.txt"
modsinstalledlistfullpath="${modsdir}/${modsinstalledlist}"

# Database initialisation
mods_list.sh

## Directory management

# Create mods files and directories if it doesn't exist
# Assuming the game is already installed as mods_list.sh checked for it.
fn_mods_files(){
	# Create mod install directory
	if [ ! -d "${modinstalldir}" ]; then
		echo "creating mods install directory ${modinstalldir}..."
		mkdir -p "${modinstalldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod download dir ${modstmpdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod download dir ${modstmpdir}"
		fi
		sleep 0.5
	fi

	# Create lgsm/data/${modsinstalledlist}
	if [ ! -f "${modsinstalledlistfullpath}" ]; then
		touch "${modsinstalledlistfullpath}"
		fn_script_log "Created ${modsinstalledlistfullpath}"
	fi
}

# Create tmp download mod directory
fn_mods_tmpdir(){
	if [ ! -d "${modstmpdir}" ]; then
		mkdir -p "${modstmpdir}"
		exitcode=$?
		echo -ne "creating mod download dir ${modstmpdir}..."
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod download dir ${modstmpdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod download dir ${modstmpdir}"
		fi
	fi
}

# Clear contents of mod download directory when finished
fn_clear_tmp_mods(){
	if [ -d "${modstmpdir}" ]; then
		rm -r "${modstmpdir}"/*
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Clearing mod download directory ${modstmpdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Clearing mod download directory ${modstmpdir}"
		fi

	fi
	# Clear temp file list as well
	if [ -f "${modsdir}/.removedfiles.tmp" ]; then
		rm "${modsdir}/.removedfiles.tmp"
	fi
}


## Download management
fn_install_mod_dl_extract(){
	fn_fetch_file "${modurl}" "${modstmpdir}" "${modfilename}"
	# Check if variable is valid checking if file has been downloaded and exists
	if [ ! -f "${modstmpdir}/${modfilename}" ]; then
		fn_print_failure "An issue occurred upon downloading ${modprettyname}"
		core_exit.sh
	fi
	if [ ! -d "${extractdir}" ]; then
		mkdir -p "${extractdir}"
	fi
	fn_dl_extract "${modstmpdir}" "${filename}" "${extractdir}"
}

# Convert mod files to lowercase if needed
fn_mod_lowercase(){
	if [ "${modlowercase}" == "LowercaseOn" ]; then

		echo -ne "converting ${modprettyname} files to lowercase..."
		sleep 0.5
		fn_script_log "Converting ${modprettyname} files to lowercase"
		files=$(find "${extractdir}" -depth | wc -l)
		echo -en "\r"
		while read src; do
			dst=`dirname "${src}"`/`basename "${src}" | tr '[A-Z]' '[a-z]'`
			if [ "${src}" != "${dst}" ]
			then
				[ ! -e "${dst}" ] && mv -T "${src}" "${dst}" || echo "${src} was not renamed"
				local exitcode=$?
				((renamedwc++))
			fi
			echo -ne "${renamedwc} / ${totalfileswc} / $files converting ${modprettyname} files to lowercase..." $'\r'
			((totalfileswc++))
		done < <(find "${extractdir}" -depth)
		echo -ne "${renamedwc} / ${totalfileswc} / $files converting ${modprettyname} files to lowercase..."

		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
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
				if [ ! -f "${modsdir}/.removedfiles.tmp" ]; then
					touch "${modsdir}/.removedfiles.tmp"
				fi
					echo "${filetoremove}" >> "${modsdir}/.removedfiles.tmp"
			fi
		done
		fn_print_ok "Allow for preserving ${modprettyname} config files"
		sleep 0.5
	fi
}

# Create ${modcommand}-files.txt containing the full extracted file/directory list
fn_mod_fileslist(){
	echo -ne "building ${modcommand}-files.txt..."

	sleep 0.5
	# ${modsdir}/${modcommand}-files.txt
	find "${extractdir}" -mindepth 1 -printf '%P\n' > "${modsdir}"/${modcommand}-files.txt
	local exitcode=$?
	if [ ${exitcode} -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "Building ${modcommand}-files.txt"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Building ${modcommand}-files.txt"
	fi
	fn_script_log "Writing file list ${modsdir}/${modcommand}-files.txt"
	# Adding removed files if needed
	if [ -f "${modsdir}/.removedfiles.tmp" ]; then
		cat "${modsdir}/.removedfiles.tmp" >> "${modsdir}"/${modcommand}-files.txt
	fi
	sleep 0.5
}

# Copy the mod to the destination ${modinstalldir}
fn_mod_copy_destination(){
	echo -ne "copying ${modprettyname} to ${modinstalldir}..."
	sleep 0.5
	cp -Rf "${extractdir}/." "${modinstalldir}/"
	local exitcode=$?
	if [ ${exitcode} -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "Copying ${modprettyname} to ${modinstalldir}"
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying ${modprettyname} to ${modinstalldir}"
	fi
}

# Check if the mod is already installed and warn the user
fn_mod_already_installed(){
	if [ -f "${modsinstalledlistfullpath}" ]; then
		if [ -n "$(sed -n "/^${modcommand}$/p" "${modsinstalledlistfullpath}")" ]; then
			fn_print_warning_nl "${modprettyname} is already installed"
			fn_script_log_warn "${modprettyname} is already installed"
			sleep 1
			echo " * Any configs may be overwritten."
			while true; do
				read -e -i "y" -p "Continue? [Y/n]" yn
				case $yn in
				[Yy]* ) break;;
				[Nn]* ) echo Exiting; core_exit.sh;;
				* ) echo "Please answer yes or no.";;
				esac
				done
		fi
	fn_script_log_info "User selected to continue"
	fi
}

# Add the mod to the installed mods list
fn_mod_add_list(){
	# Append modname to lockfile if it's not already in it
	if [ ! -n "$(sed -n "/^${modcommand}$/p" "${modsinstalledlistfullpath}")" ]; then
		echo "${modcommand}" >> "${modsinstalledlistfullpath}"
		fn_script_log_info "${modcommand} added to ${modsinstalledlist}"
	fi
}

fn_check_files_list(){
	# File list must exist and be valid before any operation on it
	if [ -f "${modsdir}/${modcommand}-files.txt" ]; then
	# How many lines is the file list
		modsfilelistsize="$(cat "${modsdir}/${modcommand}-files.txt" | wc -l)"
		# If file list is empty
		if [ "${modsfilelistsize}" -eq 0 ]; then
			fn_print_failure "${modcommand}-files.txt is empty"
			echo "* Unable to remove ${modprettyname}"
			fn_script_log_fatal "${modcommand}-files.txt is empty: Unable to remove ${modprettyname}."
			core_exit.sh
		fi
	else
		fn_print_failure "${modsdir}/${modcommand}-files.txt does not exist"
		fn_script_log_fatal "${modsdir}/${modcommand}-files.txt does not exist: Unable to remove ${modprettyname}."
		core_exit.sh
	fi
}

# Apply some post-install fixes to make sure everything will be fine
fn_postinstall_tasks(){
	# Prevent sensitive directories from being erased upon uninstall by removing them from: ${modsdir}/${modcommand}-files.txt
	# Check file validity
	fn_check_files_list
	# Output to the user
	echo -ne "tidy up ${modcommand}-files.txt..."
	sleep 0.5
	fn_script_log_info "Rearranging ${modcommand}-files.txt"
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
		sed -i "/^${removefilevar}$/d" "${modsdir}/${modcommand}-files.txt"
		local exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			break
		fi
	done
	if [ ${exitcode} -ne 0 ]; then
		fn_print_fail_eol_nl
	else
		fn_print_ok_eol_nl
	fi

	# Sourcemod fix
	# Remove metamod from sourcemod fileslist
	if [ "${modcommand}" == "sourcemod" ]; then
		# Remove addons/metamod & addons/metamod/sourcemod.vdf from ${modcommand}-files.txt
		sed -i "/^addons\/metamod$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/metamod\/sourcemod.vdf$/d" "${modsdir}/${modcommand}-files.txt"
	fi
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

# Checks if a mod is compatible for installation
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
		echo -e "\e[1m${displayedmodname}${default} - ${displayedmoddescription} - ${displayedmodsite}"
		echo -e " * ${cyan}${displayedmodcommand}${default}"
		# Increment index from the amount of values we just displayed
		let "compatiblemodslistindex+=4"
		((totalmods++))
	done
	# If no mods are found
	if [ -z "${compatiblemodslist}" ]; then
		fn_print_fail "No mods are currently available for ${gamename}."
		core_exit.sh
	fi
	fn_script_log_info "${totalmods} addons/mods are available for install"
}

# Checks if mods have been installed
# Also returns ${installedmodscount} if mods were found
fn_check_installed_mods(){
	# Count installed mods
	if [ -f "${modsinstalledlistfullpath}" ]; then
		installedmodscount="$(cat "${modsinstalledlistfullpath}" | wc -l)"
	fi
}

# A simple function to exit if no mods were installed
# Also returns ${installedmodscount} if mods were found
fn_mods_exit_if_not_installed(){
	# Checks if mods have been installed
	# Also returns ${installedmodscount} if mods were found
	fn_check_installed_mods
	# If no mods lockfile is found or if it is empty
	if [ ! -f "${modsinstalledlistfullpath}" ]||[ -z "${installedmodscount}" ]||[ ${installedmodscount} -le 0 ]; then
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
	# Loop through every line of the installed mods list ${modsinstalledlistfullpath}
	while [ ${installedmodsline} -le ${installedmodscount} ]; do
		currentmod="$(sed "${installedmodsline}q;d" "${modsinstalledlistfullpath}")"
		# Get mod info to make sure mod exists
		fn_mod_get_info_from_command
		# Add the mod to available commands
		installedmodslist+=( "${modcommand}" )
		# Increment line check
		let installedmodsline=installedmodsline+1
	done
	if [ -n "${totalmods}" ] ;then
		fn_script_log_info "${totalmods} addons/mods are already installed"
	fi
}

# Displays a detailed list of installed mods
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
fn_installed_mods_detailed_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	# Were now based on ${installedmodslist} array's values
	# We're gonna go through all available commands, get details and display them to the user
	for ((dlindex=0; dlindex < ${#installedmodslist[@]}; dlindex++)); do
		# Current mod is the "dlindex" value of the array we're going through
		currentmod="${installedmodslist[dlindex]}"
		# Get mod info
		fn_mod_get_info_from_command
		# Display mod info to the user
		echo -e "\e[1m${modprettyname}${default} - ${moddescription} - ${modsite}"
		echo -e " * ${cyan}${modcommand}${default}"
	done
}

# Displays a detailed list of installed mods
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
fn_installed_mods_medium_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	# Were now based on ${installedmodslist} array's values
	# We're gonna go through all available commands, get details and display them to the user
	for ((mlindex=0; mlindex < ${#installedmodslist[@]}; mlindex++)); do
		# Current mod is the "mlindex" value of the array we're going through
		currentmod="${installedmodslist[mlindex]}"
		# Get mod info
		fn_mod_get_info_from_command
		# Display mod info to the user
		echo -e "${cyan}${modcommand}${default} - \e[1m${modprettyname}${default} - ${moddescription}"
	done
}

# Displays a simple list of installed mods
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
# This list is only displayed when some mods are installed
fn_installed_mods_light_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	if [ "${installedmodscount}" -gt 0 ]; then
		echo "Installed addons/mods"
		echo "================================="
		# Were now based on ${installedmodslist} array's values
		# We're gonna go through all available commands, get details and display them to the user
		for ((llindex=0; llindex < ${#installedmodslist[@]}; llindex++)); do
			# Current mod is the "llindex" value of the array we're going through
			currentmod="${installedmodslist[llindex]}"
			# Get mod info
			fn_mod_get_info_from_command
			# Display simple mod info to the user
			echo -e " * \e[1m${green}${modcommand}${default}${default}"
		((totalmodsinstalled++))
		done
		echo ""
	fi
}

# Displays a simple list of installed mods for mods-update command
# Requires fn_check_installed_mods and fn_mods_available_commands_from_installed to run
fn_installed_mods_update_list(){
	fn_check_installed_mods
	fn_mods_available_commands_from_installed
	echo "================================="
	echo "Installed addons/mods"
	# Were now based on ${installedmodslist} array's values
	# We're gonna go through all available commands, get details and display them to the user
	for ((ulindex=0; ulindex < ${#installedmodslist[@]}; ulindex++)); do
		# Current mod is the "ulindex" value of the array we're going through
		currentmod="${installedmodslist[ulindex]}"
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
			echo -e " * \e[31m${modprettyname}${default} (won't be updated)"
		# If the mode is just overwritten
		elif [ "${modkeepfiles}" == "OVERWRITE" ]; then
			echo -e " * \e[1m${modprettyname}${default} (overwrite)"
		else
			echo -e " * ${yellow}${modprettyname}${default} (common custom files remain untouched)"
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
				((totalmods++))
			done

		fi
		# Exit the loop if job is done
		if [ "${modinfocommand}" == "1" ]; then
			break
		fi
	done

	# What happens if mod is not found
	if [ "${modinfocommand}" == "0" ]; then
		fn_script_log_error "Could not find information for ${currentmod}"
		fn_print_error_nl "Could not find information for ${currentmod}"
		exitcode="1"
		core_exit.sh
	fi
}

fn_mods_scrape_urls
fn_mods_info
fn_mods_available
