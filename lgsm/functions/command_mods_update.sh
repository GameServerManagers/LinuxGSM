#!/bin/bash
# LGSM command_mods_update.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Updates installed mods along with mods_list.sh and mods_core.sh.

local commandname="MODS"
local commandaction="Mods Update"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_core.sh
mods_list.sh

fn_mods_update_init(){
	fn_script_log "Entering mods & addons update"
	echo "================================="
	echo "${gamename} mods & addons update"
	echo ""
	# Installed mod dir is "${modslockfilefullpath}"
	# How many mods will be updated
	if [ -f "${modslockfilefullpath}" ]; then
		installedmodscount="$(cat "${modslockfilefullpath}" | wc -l)"
		if 
		echo "${installedmodscount} addons will be updated:"
		# Loop showing mods to update
		installedmodsline=1
		while [ $installedmodsline -le $installedmodscount ]; do
			echo -e " * \e[36m$(sed "${installedmodsline}q;d" "${modslockfilefullpath}")\e[0m"
			let installedmodsline=installedmodsline+1
		done
		sleep 2
	else
		fn_print_info_nl "No mods to be updated!"
		echo " * Did you install any mod using LGSM?"
		fn_print_log "No mods to be updated"
		core_exit.sh
	fi
}

fn_mods_update_loop(){
	installedmodline="1"
	while [ $installedmodsline -le $installedmodscount ]; do
		currentmod="$(sed "${installedmodsline}q;d" "${modslockfilefullpath}")"
		fn_mod_get_info_from_command
		if [ -n "${currentmod}" ]; then
			fn_print_dots_nl "Updating ${modprettyname}"
			sleep 0.5
			fn_script_log "Updating ${modprettyname}."
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
			let installedmodsline=installedmodsline+1
					
		else
			fn_print_fail "No mod was selected."
			core_exit.sh
		fi
	done
}

fn_mods_update_init
fn_mods_update_loop
