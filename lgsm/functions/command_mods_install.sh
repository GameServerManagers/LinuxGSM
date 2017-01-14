#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: List and installs available mods along with mods_list.sh.

local commandname="MODS"
local commandaction="Mod Installation"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_list.sh

fn_mods_install_init(){
	fn_script_log "Entering mods & addons installation"
	echo "================================="
	echo "${gamename} mods & addons installation"
	echo ""
	# Display available mods from mods_list.sh
	fn_mods_show_available
	echo ""
	# Keep prompting as long as the user input doesn't correspond to an available mod
	while [[ ! " ${availablemodscommands[@]} " =~ " ${usermodselect} " ]]; do
			echo -en "Enter a \e[36mmod\e[0m to install (or exit to abort): "
			read -r usermodselect
			# Exit if user says exit or abort
			if [ "${usermodselect}" == "exit" ]||[ "${usermodselect}" == "abort" ]; then
					fn_script_log "User aborted."
					echo "Aborted."
					core_exit.sh
			# Supplementary output upon invalid user input 
			elif [[ ! " ${availablemodscommands[@]} " =~ " ${usermodselect} " ]]; then
				fn_print_error2_nl "${usermodselect} is not a valid mod."
				echo " * Enter a valid mod or input exit to abort."
			fi
	done
	# Gives a pretty name to the user and get all mod info
	currentmod="${usermodselect}"
	fn_mod_get_info_from_command
	fn_print_dots "Installing ${modprettyname}"
	sleep 1
	fn_script_log "Installing ${modprettyname}."
}

fn_mods_requirements(){
	# If systemdir doesn't exist, then the game isn't installed
	if [ ! -d "${systemdir}" ]; then
		fn_print_fail "${gamename} needs to be installed first."
		core_exit.sh
	# If tompdir variable doesn't exist, LGSM is too old
	elif [ -z "${tmpdir}" ]||[ -z "${lgsmdir}" ]; then
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
		fn_print_ok_nl "Created mods directory"
	fi
}

# Clear mod download directory so that there is only one file in it since we don't the file name and extention
fn_clear_tmp_mods(){
	if [ -d "${modstmpdir}" ]; then
		rm -r "${modstmpdir}"
		fn_script_log "Clearing temp mod download directory: ${modstmpdir}"
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
	extractdir="${modstmpdir}/extracted"
	if [ ! -d "${extractdir}" ]; then
		mkdir -p "${extractdir}"
	fi
	fn_script_log "Extracting ${modprettyname} to ${extractdir}"
	fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
}

fn_mod_fileslist(){
	# ${modsdatadir}/${modcommand}-files.list
	true;
}

fn_mod_copy_destination(){
	# Destination directory: ${modinstalldir}
	fn_script_log "Copying ${modprettyname} to ${modinstalldir}"
	cp -Rf "${extractdir}/." "${modinstalldir}/"
}

# Check if the mod is already installed and warn the user
fn_mod_already_installed(){
	if [ -f "${modslockfilefullpath}" ]; then
		if [ -n "$(cat "${modslockfilefullpath}" | grep "${modcommand}")" ]; then
			echo ""
			fn_print_warning_nl "${modprettyname} has already been installed."
			echo " * Mod files will be overwritten."
			sleep 4
		fi
	fi
}

# Add the mod to the installed mods list
fn_mod_add_list(){
	# Create lgsm/data directory
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

# Run all required operation
fn_mod_installation(){
	# If a mod was selected
	if [ -n "${currentmod}" ]; then
		# Get mod info
		fn_mod_get_info_from_command
		# Check if mod is already installed
		fn_mod_already_installed
		# Check and create required directories
		fn_mods_dir
		# Clear lgsm/tmp/mods dir if exists then recreate it
		fn_clear_tmp_mods
		fn_mods_tmpdir
		# Download mod
		fn_mod_dl
		# Extract the mod
		fn_mod_extract
		# Build a file list
		fn_mod_fileslist
		# Copying to destination
		fn_mod_copy_destination
		# Ending with installation routines
		fn_mod_add_list
		fn_clear_tmp_mods
		fn_print_ok_nl "${modprettyname} installed."
		fn_script_log "${modprettyname} installed."
	else
		fn_print_fail "No mod was selected."
		core_exit.sh
	fi
}

fn_mods_requirements
fn_mods_install_init
fn_mod_installation
