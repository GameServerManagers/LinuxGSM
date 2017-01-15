176 lines (161 sloc)  5.27 KB
#!/bin/bash
# LGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: List and installs available mods along with mods_list.sh.

local commandname="MODS"
local commandaction="Core functions for mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

## Useful variables
# Files and Directories
modstmpdir="${tmpdir}/mods"
modsdatadir="${lgsmdir}/data/mods"
modslockfile="installed-mods-listing"
modslockfilefullpath="${modsdatadir}/${modslockfile}"

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
	find "${extractdir}" -mindepth 1 -printf '%P\n' >> ${modsdatadir}/${modcommand}-files.list
	fn_script_log "Writing file list: ${modsdatadir}/${modcommand}-files.list}"
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
