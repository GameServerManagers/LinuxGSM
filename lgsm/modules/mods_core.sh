#!/bin/bash
# LinuxGSM command_mods_install.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Core modules for mods list/install/update/remove

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Files and Directories.
modsdir="${lgsmdir}/mods"
modstmpdir="${modsdir}/tmp"
extractdest="${modstmpdir}/extract"
modsinstalledlist="installed-mods.txt"
modsinstalledlistfullpath="${modsdir}/${modsinstalledlist}"

## Installation.

# Download management.
fn_mod_install_files() {
	fn_fetch_file "${modurl}" "" "" "" "${modstmpdir}" "${modfilename}"
	# Check if variable is valid checking if file has been downloaded and exists.
	if [ ! -f "${modstmpdir}/${modfilename}" ]; then
		fn_print_failure "An issue occurred downloading ${modprettyname}"
		fn_script_log_fail "An issue occurred downloading ${modprettyname}"
		core_exit.sh
	fi
	if [ ! -d "${extractdest}" ]; then
		mkdir -p "${extractdest}"
	fi
	fn_dl_extract "${modstmpdir}" "${modfilename}" "${extractdest}"
}

# Convert mod files to lowercase if needed.
fn_mod_lowercase() {
	# Checking lowercase settings from mods array definition
	if [ "${modlowercase}" == "LowercaseOn" ]; then
		echo -en "converting ${modprettyname} files to lowercase..."
		fn_sleep_time
		fn_script_log_info "Converting ${modprettyname} files to lowercase"
		# Total files and directories for the mod, to output to the user
		fileswc=$(find "${extractdest}" | wc -l)
		# Total uppercase files and directories for the mod, to output to the user
		filesupperwc=$(find "${extractdest}" -name '*[[:upper:]]*' | wc -l)
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
		done < <(find "${extractdest}" -depth -name '*[[:upper:]]*')
		fn_print_ok_eol_nl
	fi
}

# Create ${modcommand}-files.txt containing the full extracted file/directory list.
fn_mod_create_filelist() {
	echo -en "building ${modcommand}-files.txt..."
	fn_sleep_time
	# ${modsdir}/${modcommand}-files.txt.
	find "${extractdest}" -mindepth 1 -printf '%P\n' > "${modsdir}/${modcommand}-files.txt"
	local exitcode=$?
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Building ${modsdir}/${modcommand}-files.txt"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Building ${modsdir}/${modcommand}-files.txt"
	fi
	# Adding removed files if needed.
	if [ -f "${modsdir}/.removedfiles.tmp" ]; then
		cat "${modsdir}/.removedfiles.tmp" >> "${modsdir}/${modcommand}-files.txt"
	fi
}

# Copy the mod into serverfiles.
fn_mod_copy_destination() {
	echo -en "copying ${modprettyname} to ${modinstalldir}..."
	fn_sleep_time
	cp -Rf "${extractdest}/." "${modinstalldir}/"
	local exitcode=$?
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Copying ${modprettyname} to ${modinstalldir}"
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Copying ${modprettyname} to ${modinstalldir}"
	fi
}

# Add the mod to the installed-mods.txt.
fn_mod_add_list() {
	if [ -z "$(sed -n "/^${modcommand}$/p" "${modsinstalledlistfullpath}")" ]; then
		echo -e "${modcommand}" >> "${modsinstalledlistfullpath}"
		fn_script_log_info "${modcommand} added to ${modsinstalledlist}"
	fi
}

# Prevent sensitive directories from being erased upon uninstall by removing them from: ${modcommand}-files.txt.
fn_mod_tidy_files_list() {
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
	removefromlistamount=$(echo -e "${removefromlist}" | awk -F ';' '{ print NF }')
	# Test all subvalue of "removefromlist" using the ";" separator.
	for ((filesindex = 1; filesindex < removefromlistamount; filesindex++)); do
		# Put current file into test variable.
		removefilevar=$(echo -e "${removefromlist}" | awk -F ';' -v x=${filesindex} '{ print $x }')
		# Delete line(s) matching exactly.
		sed -i "/^${removefilevar}$/d" "${modsdir}/${modcommand}-files.txt"
		# Exit on error.
		local exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Error while tidying line: ${removefilevar} from: ${modsdir}/${modcommand}-files.txt"
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

	# Remove common paths from deletion list (Add your sourcemod mod here)
	if [ "${modcommand}" == "gokz" ] || [ "${modcommand}" == "ttt" ] || [ "${modcommand}" == "steamworks" ] || [ "${modcommand}" == "get5" ]; then
		sed -i "/^addons\/sourcemod$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/configs$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/extensions$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/logs$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/plugins$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/plugins\/disabled$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/translations$/d" "${modsdir}/${modcommand}-files.txt"
		# Don't delete directories of translations like 'fr', 'sv', 'de', etc
		sed -i "/^addons\/sourcemod\/translations\/[A-Za-z0-9_]*$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^cfg\/sourcemod$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^maps$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^materialss$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^materials\/models$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^materials\/models\/weapons$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^materials\/darkness$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^materials\/decals$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^materials\/overlays$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^models$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^models\/weapons$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^sound$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^sound\/weapons$/d" "${modsdir}/${modcommand}-files.txt"
	fi

	# Remove paths of specific mods from deletion list
	if [ "${modcommand}" == "gokz" ]; then
		sed -i "/^addons\/sourcemod\/scripting\/include\/smjansson.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/GlobalAPI-Core.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/sourcebanspp.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/autoexecconfig.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/colorvariables.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/movementapi.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/movement.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/dhooks.inc$/d" "${modsdir}/${modcommand}-files.txt"
		sed -i "/^addons\/sourcemod\/scripting\/include\/updater.inc$/d" "${modsdir}/${modcommand}-files.txt"
	fi
}

## Information Gathering.

# Get details of a mod any (relevant and unique, such as full mod name or install command) value.
fn_mod_get_info() {
	# Variable to know when job is done.
	modinfocommand="0"
	# Find entry in global array.
	for ((index = 0; index <= ${#mods_global_array[@]}; index++)); do
		# When entry is found.
		if [ "${mods_global_array[index]}" == "${currentmod}" ]; then
			# Go back to the previous "MOD" separator.
			for ((index = index; index <= ${#mods_global_array[@]}; index--)); do
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
fn_mods_define() {
	if [ -z "$index" ]; then
		fn_script_log_fail "index variable not set. Please report an issue."
		fn_print_error "index variable not set. Please report an issue."
		echo -e "* https://github.com/GameServerManagers/LinuxGSM/issues"
		core_exit.sh
	fi
	modcommand="${mods_global_array[index + 1]}"
	modprettyname="${mods_global_array[index + 2]}"
	modurl="${mods_global_array[index + 3]}"
	modfilename="${mods_global_array[index + 4]}"
	modsubdirs="${mods_global_array[index + 5]}"
	modlowercase="${mods_global_array[index + 6]}"
	modinstalldir="${mods_global_array[index + 7]}"
	modkeepfiles="${mods_global_array[index + 8]}"
	modengines="${mods_global_array[index + 9]}"
	modgames="${mods_global_array[index + 10]}"
	modexcludegames="${mods_global_array[index + 11]}"
	modsite="${mods_global_array[index + 12]}"
	moddescription="${mods_global_array[index + 13]}"
}

# Builds list of installed mods.
# using installed-mods.txt grabing mod info from mods_list.sh.
fn_mods_installed_list() {
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
		currentmod=$(sed "${installedmodsline}q;d" "${modsinstalledlistfullpath}")
		# Get mod info to make sure mod exists.
		fn_mod_get_info
		# Add the mod to available commands.
		installedmodslist+=("${modcommand}")
		# Increment line check.
		((installedmodsline++))
	done
	if [ "${installedmodscount}" ]; then
		fn_script_log_info "${installedmodscount} addons/mods are currently installed"
	fi
}

# Loops through mods_global_array to define available mods & provide available commands for mods installation.
fn_mods_available() {
	# First, reset variables.
	compatiblemodslist=()
	availablemodscommands=()
	# Find compatible games.
	# Find separators through the global array.
	for ((index = "0"; index <= ${#mods_global_array[@]}; index++)); do
		# If current value is a separator; then.
		if [ "${mods_global_array[index]}" == "${modseparator}" ]; then
			# Set mod variables.
			fn_mods_define
			# Test if game is compatible.
			fn_mod_compatible_test
			# If game is compatible.
			if [ "${modcompatibility}" == "1" ]; then
				# Put it into an array to prepare user output.
				compatiblemodslist+=("${modprettyname}" "${modcommand}" "${modsite}" "${moddescription}")
				# Keep available commands in an array to make life easier.
				availablemodscommands+=("${modcommand}")
			fi
		fi
	done
}

## Mod compatibility check.

# Find out if a game is compatible with a mod from a modgames (list of games supported by a mod) variable.
fn_compatible_mod_games() {
	# Reset test value.
	modcompatiblegame="0"
	# If value is set to GAMES (ignore).
	if [ "${modgames}" != "GAMES" ]; then
		# How many games we need to test.
		gamesamount=$(echo -e "${modgames}" | awk -F ';' '{ print NF }')
		# Test all subvalue of "modgames" using the ";" separator.
		for ((gamevarindex = 1; gamevarindex < gamesamount; gamevarindex++)); do
			# Put current game name into modtest variable.
			gamemodtest=$(echo -e "${modgames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }')
			# If game name matches.
			if [ "${gamemodtest}" == "${gamename}" ]; then
				# Mod is compatible.
				modcompatiblegame="1"
			fi
		done
	fi
}

# Find out if an engine is compatible with a mod from a modengines (list of engines supported by a mod) variable.
fn_compatible_mod_engines() {
	# Reset test value.
	modcompatibleengine="0"
	# If value is set to ENGINES (ignore).
	if [ "${modengines}" != "ENGINES" ]; then
		# How many engines we need to test.
		enginesamount=$(echo -e "${modengines}" | awk -F ';' '{ print NF }')
		# Test all subvalue of "modengines" using the ";" separator.
		for ((gamevarindex = 1; gamevarindex < ${enginesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable.
			enginemodtest=$(echo -e "${modengines}" | awk -F ';' -v x=${gamevarindex} '{ print $x }')
			# If engine name matches.
			if [ "${enginemodtest}" == "${engine}" ]; then
				# Mod is compatible.
				modcompatibleengine="1"
			fi
		done
	fi
}

# Find out if a game is not compatible with a mod from a modnotgames (list of games not supported by a mod) variable.
fn_not_compatible_mod_games() {
	# Reset test value.
	modeincompatiblegame="0"
	# If value is set to NOTGAMES (ignore).
	if [ "${modexcludegames}" != "NOTGAMES" ]; then
		# How many engines we need to test.
		excludegamesamount=$(echo -e "${modexcludegames}" | awk -F ';' '{ print NF }')
		# Test all subvalue of "modexcludegames" using the ";" separator.
		for ((gamevarindex = 1; gamevarindex < excludegamesamount; gamevarindex++)); do
			# Put current engine name into modtest variable.
			excludegamemodtest=$(echo -e "${modexcludegames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }')
			# If engine name matches.
			if [ "${excludegamemodtest}" == "${gamename}" ]; then
				# Mod is compatible.
				modeincompatiblegame="1"
			fi
		done
	fi
}

# Sums up if a mod is compatible or not with modcompatibility=0/1.
fn_mod_compatible_test() {
	# Test game and engine compatibility.
	fn_compatible_mod_games
	fn_compatible_mod_engines
	fn_not_compatible_mod_games
	if [ "${modeincompatiblegame}" == "1" ]; then
		modcompatibility="0"
	elif [ "${modcompatibleengine}" == "1" ] || [ "${modcompatiblegame}" == "1" ]; then
		modcompatibility="1"
	else
		modcompatibility="0"
	fi
}

## Directory management.

# Create mods files and directories if it doesn't exist.
fn_create_mods_dir() {
	# Create lgsm data modsdir.
	if [ ! -d "${modsdir}" ]; then
		echo -en "creating LinuxGSM mods data directory ${modsdir}..."
		mkdir -p "${modsdir}"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Creating mod download dir ${modsdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod download dir ${modsdir}"
		fi
	fi
	# Create mod install directory.
	if [ ! -d "${modinstalldir}" ]; then
		echo -en "creating mods install directory ${modinstalldir}..."
		mkdir -p "${modinstalldir}"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Creating mod install directory ${modinstalldir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod install directory ${modinstalldir}"
		fi
	fi

	# Create lgsm/data/${modsinstalledlist}.
	if [ ! -f "${modsinstalledlistfullpath}" ]; then
		touch "${modsinstalledlistfullpath}"
		fn_script_log_info "Created ${modsinstalledlistfullpath}"
	fi
}

# Create tmp download mod directory.
fn_mods_create_tmp_dir() {
	if [ ! -d "${modstmpdir}" ]; then
		mkdir -p "${modstmpdir}"
		exitcode=$?
		echo -en "creating mod download directory ${modstmpdir}..."
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Creating mod download directory ${modstmpdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Creating mod download directory ${modstmpdir}"
		fi
	fi
}

# Remove the tmp mod download directory when finished.
fn_mods_clear_tmp_dir() {
	if [ -d "${modstmpdir}" ]; then
		echo -en "clearing mod download directory ${modstmpdir}..."
		rm -rf "${modstmpdir:?}"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_fail_eol_nl
			fn_script_log_fail "Clearing mod download directory ${modstmpdir}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Clearing mod download directory ${modstmpdir}"
		fi

	fi
	# Clear temp file list as well.
	if [ -f "${modsdir}/.removedfiles.tmp" ]; then
		rm -f "${modsdir:?}/.removedfiles.tmp"
	fi
}

# Counts how many mods were installed.
fn_mods_count_installed() {
	if [ -f "${modsinstalledlistfullpath}" ]; then
		installedmodscount=$(wc -l < "${modsinstalledlistfullpath}")
	else
		installedmodscount=0
	fi
}

# Exits if no mods were installed.
fn_mods_check_installed() {
	# Count installed mods.
	fn_mods_count_installed
	# If no mods are found.
	if [ ${installedmodscount} -eq 0 ]; then
		echo -e ""
		fn_print_failure_nl "No installed mods or addons were found"
		echo -e " * Install mods using LinuxGSM first with: ./${selfname} mods-install"
		fn_script_log_error "No installed mods or addons were found."
		core_exit.sh
	fi
}

# Checks that mod files list exists and isn't empty.
fn_check_mod_files_list() {
	# File list must exist and be valid before any operation on it.
	if [ -f "${modsdir}/${modcommand}-files.txt" ]; then
		# How many lines is the file list.
		modsfilelistsize=$(wc -l < "${modsdir}/${modcommand}-files.txt")
		# If file list is empty.
		if [ "${modsfilelistsize}" -eq 0 ]; then
			fn_print_failure "${modcommand}-files.txt is empty"
			echo -e "* Unable to remove ${modprettyname}"
			fn_script_log_fail "${modcommand}-files.txt is empty: Unable to remove ${modprettyname}."
			core_exit.sh
		fi
	else
		fn_print_failure "${modsdir}/${modcommand}-files.txt does not exist"
		fn_script_log_fail "${modsdir}/${modcommand}-files.txt does not exist: Unable to remove ${modprettyname}."
		core_exit.sh
	fi
}

fn_mod_exist() {
	modreq=$1
	# requires one parameter, the mod
	if [ -f "${modsdir}/${modreq}-files.txt" ]; then
		# how many lines is the file list
		modsfilelistsize=$(wc -l < "${modsdir}/${modreq}-files.txt")
		# if file list is empty
		if [ "${modsfilelistsize}" -eq 0 ]; then
			fn_mod_required_fail_exist "${modreq}"
		fi
	else
		fn_mod_required_fail_exist "${modreq}"
	fi
}

fn_mod_required_fail_exist() {
	modreq=$1
	# requires one parameter, the mod
	fn_script_log_fail "${modreq}-files.txt is empty: unable to find ${modreq} installed"
	echo -en "* Unable to find '${modreq}' which is required prior to installing this mod..."
	fn_print_fail_eol_nl
	core_exit.sh
}

fn_mod_liblist_gam_filenames() {
	# clear variables just in case
	moddll=""
	modso=""
	moddylib=""

	# default libraries
	case ${gamename} in
		"Counter-Strike 1.6")
			moddll="mp.dll"
			modso="cs.so"
			moddylib="cs.dylib"
			;;
		"Day of Defeat")
			moddll="dod.dll"
			modso="dod.so"
			moddylib="dod.dylib"
			;;
		"Team Fortress Classic")
			moddll="tfc.dll"
			modso="tfc.so"
			moddylib="tfc.dylib"
			;;
		"Natural Selection")
			moddll="ns.dll"
			modso="ns_i386.so"
			moddylib=""
			;;
		"The Specialists")
			moddll="mp.dll"
			modso="ts_i386.so"
			moddylib=""
			;;
		"Half-Life: Deathmatch")
			moddll="hl.dll"
			modso="hl.so"
			moddylib="hl.dylib"
			;;
	esac
}

# modifers for liblist.gam to add/remote metamod binaries
fn_mod_install_liblist_gam_file() {

	fn_mod_liblist_gam_filenames

	if [ -f "${modinstalldir}/liblist.gam" ]; then
		# modify the liblist.gam file to initialize Metamod
		logentry="sed replace (dlls\\${moddll}) ${modinstalldir}/liblist.gam"
		echo -en "modifying gamedll in liblist.gam..."
		rpldll="s/dlls\\\\${moddll}/addons\/metamod\/dlls\/metamod.dll/g"
		sed -i $rpldll "${modinstalldir}/liblist.gam"
		grep -q "addons/metamod/dlls/metamod.dll" "${modinstalldir}/liblist.gam"
		exitcode=$?
		# if replacement back didn't happen, error out.
		if [ "${exitcode}" != 0 ]; then
			fn_script_log_fail "${logentry}"
			fn_print_fail_eol_nl
		else
			fn_script_log_pass "${logentry}"
			fn_print_ok_eol_nl
		fi

		# modify the liblist.gam file to initialize metamod
		logentry="sed replace (dlls\\${modso}) ${modinstalldir}/liblist.gam"
		echo -en "modifying gamedll_linux in liblist.gam..."
		rplso="s/dlls\/${modso}/addons\/metamod\/dlls\/metamod.so/g"
		sed -i $rplso "${modinstalldir}/liblist.gam"
		grep -q "addons/metamod/dlls/metamod.so" "${modinstalldir}/liblist.gam"
		exitcode=$?
		# if replacement back didn't happen, error out
		if [ "${exitcode}" != 0 ]; then
			fn_script_log_fail "${logentry}"
			fn_print_fail_eol_nl
		else
			fn_script_log_pass "${logentry}"
			fn_print_ok_eol_nl
		fi

		# mac os needs to be checked not all mods support mac os
		if [ -n "${moddylib}" ]; then
			# modify the liblist.gam file to initialize metamod
			logentry="sed replace (dlls\\${moddylib}) ${modinstalldir}/liblist.gam"
			echo -en "modifying gamedll_osx in liblist.gam..."
			rpldylib="s/dlls\/${moddylib}/addons\/metamod\/dlls\/metamod.dylib/g"
			sed -i $rpldylib "${modinstalldir}/liblist.gam"
			grep -q "addons/metamod/dlls/metamod.dylib" "${modinstalldir}/liblist.gam"
			exitcode=$?
			# if replacement back didn't happen, error out.
			if [ "${exitcode}" != 0 ]; then
				fn_script_log_fail "${logentry}"
				fn_print_fail_eol_nl
			else
				fn_script_log_pass ${logentry}
				fn_print_ok_eol_nl
			fi
		fi
	fi
}

fn_mod_remove_liblist_gam_file() {

	fn_mod_liblist_gam_filenames

	if [ -f "${modinstalldir}/liblist.gam" ]; then
		# modify the liblist.gam file back to defaults
		logentry="sed replace (addons/metamod/dlls/metamod.dll) ${modinstalldir}/liblist.gam"
		echo -en "modifying gamedll in liblist.gam..."
		rpldll="s/addons\/metamod\/dlls\/metamod.dll/dlls\\\\${moddll}/g"
		sed -i $rpldll "${modinstalldir}/liblist.gam"
		grep -q "${moddll}" "${modinstalldir}/liblist.gam"
		exitcode=$?
		# if replacement back didn't happen, error out.
		if [ "${exitcode}" != 0 ]; then
			fn_script_log_fail "${logentry}"
			fn_print_fail_eol_nl
		else
			fn_script_log_pass ${logentry}
			fn_print_ok_eol_nl
		fi

		# modify the liblist.gam file back to defaults
		logentry="sed replace (addons/metamod/dlls/metamod.so) ${modinstalldir}/liblist.gam"
		echo -en "modifying gamedll_linux in liblist.gam..."
		rplso="s/addons\/metamod\/dlls\/metamod.so/dlls\/${modso}/g"
		sed -i $rplso "${modinstalldir}/liblist.gam"
		grep -q "${modso}" "${modinstalldir}/liblist.gam"
		exitcode=$?
		# if replacement back didn't happen, error out
		if [ "${exitcode}" != 0 ]; then
			fn_script_log_fail "${logentry}"
			fn_print_fail_eol_nl
		else
			fn_script_log_pass ${logentry}
			fn_print_ok_eol_nl
		fi

		# mac os needs to be checked not all mods support mac os
		if [ -n "${moddylib}" ]; then
			# modify the liblist.gam file back to defaults
			logentry="sed replace (addons/metamod/dlls/metamod.dylib) ${modinstalldir}/liblist.gam"
			echo -en "modifying gamedll_osx in liblist.gam..."
			rpldylib="s/addons\/metamod\/dlls\/metamod.dylib/dlls\/${moddylib}/g"
			sed -i $rpldylib "${modinstalldir}/liblist.gam"
			grep -q "${moddylib}" "${modinstalldir}/liblist.gam"
			# if replacement back didn't happen, error out.
			exitcode=$?
			if [ "${exitcode}" != 0 ]; then
				fn_script_log_fail "${logentry}"
				fn_print_fail_eol_nl
			else
				fn_script_log_pass ${logentry}
				fn_print_ok_eol_nl
			fi
		fi
	fi
}

fn_mod_install_amxmodx_file() {
	# does plugins.ini exist?
	if [ -f "${modinstalldir}/addons/metamod/plugins.ini" ]; then
		# since it does exist, is the entry already in plugins.ini
		logentry="line (linux addons/amxmodx/dlls/amxmodx_mm_i386.so) inserted into ${modinstalldir}/addons/metamod/plugins.ini"
		echo -en "adding amxmodx_mm_i386.so in plugins.ini..."
		grep -q "amxmodx_mm_i386.so" "${modinstalldir}/addons/metamod/plugins.ini"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			# file exists but the entry does not, let's add it
			echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> "${modinstalldir}/addons/metamod/plugins.ini"
			exitcode=$?
			if [ "${exitcode}" != 0 ]; then
				fn_script_log_fail "${logentry}"
				fn_print_fail_eol_nl
			else
				fn_script_log_pass ${logentry}
				fn_print_ok_eol_nl
			fi
		fi
	else
		# create new file and add the mod to it
		echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" > "${modinstalldir}/addons/metamod/plugins.ini"
		exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_script_log_fail "${logentry}"
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_script_log_pass ${logentry}
			fn_print_ok_eol_nl
		fi
	fi
}

fn_mod_remove_amxmodx_file() {
	if [ -f "${modinstalldir}/addons/metamod/plugins.ini" ]; then
		# since it does exist, is the entry already in plugins.ini
		logentry="line (linux addons/amxmodx/dlls/amxmodx_mm_i386.so) removed from ${modinstalldir}/addons/metamod/plugins.ini"
		echo -en "removing amxmodx_mm_i386.so in plugins.ini..."
		grep -q "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" "${modinstalldir}/addons/metamod/plugins.ini"
		# iIs it found? If so remove it and clean up
		exitcode=$?
		if [ "${exitcode}" == 0 ]; then
			# delete the line we inserted
			sed -i '/linux addons\/amxmodx\/dlls\/amxmodx_mm_i386.so/d' "${modinstalldir}/addons/metamod/plugins.ini"
			# remove empty lines
			sed -i '/^$/d' "${modinstalldir}/addons/metamod/plugins.ini"
			exitcode=$?
			if [ "${exitcode}" != 0 ]; then
				fn_script_log_fail "${logentry}"
				fn_print_fail_eol_nl
			else
				fn_script_log_pass ${logentry}
				fn_print_ok_eol_nl
			fi

			# if file is empty, remove it.
			if [ -f "${modinstalldir}/addons/metamod/plugins.ini" ]; then
				rm -f "${modinstalldir}/addons/metamod/plugins.ini"
				fn_script_log_pass "file removed ${modinstalldir}/addons/metamod/plugins.ini because it was empty"
			fi
		fi
	fi
}

## Database initialisation.

mods_list.sh
fn_mods_available
