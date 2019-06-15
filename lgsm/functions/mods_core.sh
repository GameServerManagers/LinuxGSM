#!/bin/bash
# LinuxGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Core functions for mods list/install/update/remove

local commandname="MODS"
local commandaction="Mods"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Files and Directories.
modsdir="${lgsmdir}/mods"
modstmpdir="${modsdir}/tmp"
extractdir="${modstmpdir}/extract"
modsinstalledlist="installed-mods.txt"
modsinstalledlistfullpath="${modsdir}/${modsinstalledlist}"

## Installation.

# Download management.
fn_mod_install_files(){
	fn_fetch_file "${modurl}" "${modstmpdir}" "${modfilename}"
	# Check if variable is valid checking if file has been downloaded and exists.
	if [ ! -f "${modstmpdir}/${modfilename}" ]; then
		fn_print_failure "An issue occurred downloading ${modprettyname}"
		fn_script_log_fatal "An issue occurred downloading ${modprettyname}"
		core_exit.sh
	fi
	if [ ! -d "${extractdir}" ]; then
		mkdir -p "${extractdir}"
	fi
	fn_dl_extract "${modstmpdir}" "${modfilename}" "${extractdir}"
}

# Convert mod files to lowercase if needed.
fn_mod_lowercase(){
	if [ "${modlowercase}" == "LowercaseOn" ]; then

		echo -en "converting ${modprettyname} files to lowercase..."
		fn_sleep_time
		fn_script_log_info "Converting ${modprettyname} files to lowercase"
		fileswc=$(find "${extractdir}" -depth | wc -l)
		echo -en "\r"
		while read -r src; do
			dst=$(dirname "${src}"$(/)basename "${src}" | tr 'A-Z' 'a-z')
			if [ "${src}" != "${dst}" ]
			then
				[ ! -e "${dst}" ] && mv -T "${src}" "${dst}" || echo "${src} was not renamed"
				local exitcode=$?
				((renamedwc++))
			fi
			echo -en "${renamedwc} / ${totalfileswc} / ${fileswc} converting ${modprettyname} files to lowercase..." $'\r'
			((totalfileswc++))
		done < <(find "${extractdir}" -depth)
		echo -en "${renamedwc} / ${totalfileswc} / ${fileswc} converting ${modprettyname} files to lowercase..."

		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi
		fn_sleep_time
	fi
}

# Create ${modcommand}-files.txt containing the full extracted file/directory list.
fn_mod_create_filelist(){
	echo -en "building ${modcommand}-files.txt..."
	fn_sleep_time
	# ${modsdir}/${modcommand}-files.txt.
	find "${extractdir}" -mindepth 1 -printf '%P\n' > "${modsdir}/${modcommand}-files.txt"
	local exitcode=$?
	if [ ${exitcode} -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "Building ${modsdir}/${modcommand}-files.txt"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Building ${modsdir}/${modcommand}-files.txt"
	fi
	# Adding removed files if needed.
	if [ -f "${modsdir}/.removedfiles.tmp" ]; then
		cat "${modsdir}/.removedfiles.tmp" >> "${modsdir}/${modcommand}-files.txt"
	fi
	fn_sleep_time
}

# Copy the mod into serverfiles.
fn_mod_copy_destination(){
	echo -en "copying ${modprettyname} to ${modinstalldir}..."
	fn_sleep_time
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

# Add the mod to the installed-mods.txt.
fn_mod_add_list(){
	if [ ! -n "$(sed -n "/^${modcommand}$/p" "${modsinstalledlistfullpath}")" ]; then
		echo "${modcommand}" >> "${modsinstalledlistfullpath}"
		fn_script_log_info "${modcommand} added to ${modsinstalledlist}"
	fi
}

# Prevent sensitive directories from being erased upon uninstall by removing them from: ${modcommand}-files.txt.
fn_mod_tidy_files_list(){
	# Check file list validity.
	fn_check_mod_files_list
	# Output to the user
	echo -en "tidy up ${modcommand}-files.txt..."
	fn_sleep_time
	fn_script_log_info "Tidy up ${modcommand}-files.txt"
	# Lines/files to remove from file list (end with ";" separator).
	removefromlist="cfg;addons;RustDedicated_Data;RustDedicated_Data\/Managed;RustDedicated_Data\/Managed\/x86;RustDedicated_Data\/Managed\/x64;"
	# Loop through files to remove from file list,
	# generate elements to remove from list.
	removefromlistamount="$(echo "${removefromlist}" | awk -F ';' '{ print NF }')"
	# Test all subvalue of "removefromlist" using the ";" separator.
	for ((filesindex=1; filesindex < removefromlistamount; filesindex++)); do
		# Put current file into test variable.
		removefilevar="$(echo "${removefromlist}" | awk -F ';' -v x=${filesindex} '{ print $x }')"
		# Delete line(s) matching exactly.
		sed -i "/^${removefilevar}$/d" "${modsdir}/${modcommand}-files.txt"
		# Exit on error.
		local exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Error while tidying line: ${removefilevar} from: ${modsdir}/${modcommand}-files.txt"
			core_exit.sh
			break
		fi
	done
	fn_print_ok_eol_nl
	# Sourcemod fix
	# Remove metamod from sourcemod fileslist.
	if [ "${modcommand}" == "sourcemod" ]; then
		# Remove addons/metamod & addons/metamod/sourcemod.vdf from ${modcommand}-files.txt.
		sed -i "/^addons\/metamod$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/metamod\/sourcemod.vdf$/d" "${modsdir}/${modcommand}-files.txt"
	fi
}

## Information Gathering.

# Get details of a mod any (relevant and unique, such as full mod name or install command) value.
fn_mod_get_info(){
	# Variable to know when job is done.
	modinfocommand="0"
	# Find entry in global array.
	for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
		# When entry is found.
		if [ "${mods_global_array[index]}" == "${currentmod}" ]; then
			# Go back to the previous "MOD" separator.
			for ((index=index; index <= ${#mods_global_array[@]}; index--)); do
				# When "MOD" is found.
				if [ "${mods_global_array[index]}" == "MOD" ]; then
					# Get info.
					fn_mods_define
					modinfocommand="1"
					break
				fi
			done
		fi
		# Exit the loop if job is done.
		if [ "${modinfocommand}" == "1" ]; then
			break
		fi
	done

	# What happens if mod is not found.
	if [ "${modinfocommand}" == "0" ]; then
		fn_script_log_error "Could not find information for ${currentmod}"
		fn_print_error_nl "Could not find information for ${currentmod}"
		core_exit.sh
	fi
}

# Define all variables for a mod at once when index is set to a separator.
fn_mods_define(){
if [ -z "$index" ]; then
	fn_script_log_fatal "index variable not set. Please report an issue."
	fn_print_error "index variable not set. Please report an issue."
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

# Builds list of installed mods.
# using installed-mods.txt grabing mod info from mods_list.sh.
fn_mods_installed_list(){
	fn_mods_count_installed
	# Set/reset variables.
	installedmodsline="1"
	installedmodslist=()
	modprettynamemaxlength="0"
	modsitemaxlength="0"
	moddescriptionmaxlength="0"
	modcommandmaxlength="0"
	# Loop through every line of the installed mods list ${modsinstalledlistfullpath}.
	while [ "${installedmodsline}" -le "${installedmodscount}" ]; do
		currentmod="$(sed "${installedmodsline}q;d" "${modsinstalledlistfullpath}")"
		# Get mod info to make sure mod exists.
		fn_mod_get_info
		# Add the mod to available commands.
		installedmodslist+=( "${modcommand}" )
		# Increment line check.
		((installedmodsline++))
	done
	if [ -n "${installedmodscount}" ]; then
		fn_script_log_info "${installedmodscount} addons/mods are currently installed"
	fi
}

# Loops through mods_global_array to define available mods & provide available commands for mods installation.
fn_mods_available(){
	# First, reset variables.
	compatiblemodslist=()
	availablemodscommands=()
	# Find compatible games.
	# Find separators through the global array.
	for ((index="0"; index <= ${#mods_global_array[@]}; index++)); do
		# If current value is a separator; then.
		if [ "${mods_global_array[index]}" == "${modseparator}" ]; then
			# Set mod variables.
			fn_mods_define
			# Test if game is compatible.
			fn_mod_compatible_test
			# If game is compatible.
			if [ "${modcompatibility}" == "1" ]; then
				# Put it into an array to prepare user output.
				compatiblemodslist+=( "${modprettyname}" "${modcommand}" "${modsite}" "${moddescription}" )
				# Keep available commands in an array to make life easier.
				availablemodscommands+=( "${modcommand}" )
			fi
		fi
	done
}

## Mod compatibility check.

# Find out if a game is compatible with a mod from a modgames (list of games supported by a mod) variable.
fn_compatible_mod_games(){
	# Reset test value.
	modcompatiblegame="0"
	# If value is set to GAMES (ignore).
	if [ "${modgames}" != "GAMES" ]; then
		# How many games we need to test.
		gamesamount="$(echo "${modgames}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modgames" using the ";" separator.
		for ((gamevarindex=1; gamevarindex < gamesamount; gamevarindex++)); do
			# Put current game name into modtest variable.
			gamemodtest="$( echo "${modgames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If game name matches.
			if [ "${gamemodtest}" == "${gamename}" ]; then
				# Mod is compatible.
				modcompatiblegame="1"
			fi
		done
	fi
}

# Find out if an engine is compatible with a mod from a modengines (list of engines supported by a mod) variable.
fn_compatible_mod_engines(){
	# Reset test value.
	modcompatibleengine="0"
	# If value is set to ENGINES (ignore).
	if [ "${modengines}" != "ENGINES" ]; then
		# How many engines we need to test.
		enginesamount="$(echo "${modengines}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modengines" using the ";" separator.
		for ((gamevarindex=1; gamevarindex < ${enginesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable.
			enginemodtest="$( echo "${modengines}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches.
			if [ "${enginemodtest}" == "${engine}" ]; then
				# Mod is compatible.
				modcompatibleengine="1"
			fi
		done
	fi
}

# Find out if a game is not compatible with a mod from a modnotgames (list of games not supported by a mod) variable.
fn_not_compatible_mod_games(){
	# Reset test value.
	modeincompatiblegame="0"
	# If value is set to NOTGAMES (ignore).
	if [ "${modexcludegames}" != "NOTGAMES" ]; then
		# How many engines we need to test.
		excludegamesamount="$(echo "${modexcludegames}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modexcludegames" using the ";" separator.
		for ((gamevarindex=1; gamevarindex < excludegamesamount; gamevarindex++)); do
			# Put current engine name into modtest variable.
			excludegamemodtest="$( echo "${modexcludegames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches.
			if [ "${excludegamemodtest}" == "${gamename}" ]; then
				# Mod is compatible.
				modeincompatiblegame="1"
			fi
		done
	fi
}

# Sums up if a mod is compatible or not with modcompatibility=0/1.
fn_mod_compatible_test(){
	# Test game and engine compatibility.
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

## Directory management.

# Create mods files and directories if it doesn't exist.
fn_create_mods_dir(){
	# Create lgsm data modsdir.
	if [ ! -d "${modsdir}" ]; then
		echo -en "creating LinuxGSM mods data directory ${modsdir}..."
		mkdir -p "${modsdir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod download dir ${modsdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod download dir ${modsdir}"
		fi
		fn_sleep_time
	fi
	# Create mod install directory.
	if [ ! -d "${modinstalldir}" ]; then
		echo -en "creating mods install directory ${modinstalldir}..."
		mkdir -p "${modinstalldir}"
		exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod install directory ${modinstalldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod install directory ${modinstalldir}"
		fi
		fn_sleep_time
	fi

	# Create lgsm/data/${modsinstalledlist}.
	if [ ! -f "${modsinstalledlistfullpath}" ]; then
		touch "${modsinstalledlistfullpath}"
		fn_script_log_info "Created ${modsinstalledlistfullpath}"
	fi
}

# Create tmp download mod directory.
fn_mods_create_tmp_dir(){
	if [ ! -d "${modstmpdir}" ]; then
		mkdir -p "${modstmpdir}"
		exitcode=$?
		echo -en "creating mod download directory ${modstmpdir}..."
		if [ ${exitcode} -ne 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fatal "Creating mod download directory ${modstmpdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod download directory ${modstmpdir}"
		fi
	fi
}

# Remove the tmp mod download directory when finished.
fn_mods_clear_tmp_dir(){
	if [ -d "${modstmpdir}" ]; then
		echo -en "clearing mod download directory ${modstmpdir}..."
		rm -r "${modstmpdir}"
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
	# Clear temp file list as well.
	if [ -f "${modsdir}/.removedfiles.tmp" ]; then
		rm "${modsdir}/.removedfiles.tmp"
	fi
}

# Counts how many mods were installed.
fn_mods_count_installed(){
	if [ -f "${modsinstalledlistfullpath}" ]; then
		installedmodscount="$(wc -l < "${modsinstalledlistfullpath}")"
	else
		installedmodscount=0
	fi
}

# Exits if no mods were installed.
fn_mods_check_installed(){
	# Count installed mods.
	fn_mods_count_installed
	# If no mods are found.
	if [ ${installedmodscount} -eq 0 ]; then
		echo ""
		fn_print_failure_nl "No installed mods or addons were found"
		echo " * Install mods using LinuxGSM first with: ./${selfname} mods-install"
		fn_script_log_error "No installed mods or addons were found."
		core_exit.sh
	fi
}

# Checks that mod files list exists and isn't empty.
fn_check_mod_files_list(){
	# File list must exist and be valid before any operation on it.
	if [ -f "${modsdir}/${modcommand}-files.txt" ]; then
	# How many lines is the file list.
		modsfilelistsize="$(wc -l < "${modsdir}/${modcommand}-files.txt")"
		# If file list is empty.
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

## Database initialisation.

mods_list.sh
fn_mods_available
