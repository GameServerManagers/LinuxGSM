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

fn_mods_update_init(){
	fn_script_log "Entering mods & addons update"
	echo "================================="
	echo "${gamename} mods & addons update"
	# A simple function to exit if no mods were installed
	# Also returns ${installedmodscount} if mods were found
	fn_mods_exit_if_not_installed
	echo ""
	fn_print_information_nl "${installedmodscount} mods or addons will be updated:"
	fn_script_log_info "${installedmodscount} mods or addons will be updated"
	# Display a list of installed addons
	fn_installed_mods_update_list
}

# Recursively list all installed mods and apply update
fn_mods_update_loop(){
	# Reset line value
	installedmodsline="1"
	while [ $installedmodsline -le $installedmodscount ]; do
		# Current line defines current mod command
		currentmod="$(sed "${installedmodsline}q;d" "${modslockfilefullpath}")"
		if [ -n "${currentmod}" ]; then
			# Get mod info
			fn_mod_get_info_from_command
			# Don't update the mod if it's policy is to "NOUPDATE"
			if [ "${modkeepfiles}" == "NOUPDATE" ]; then
				fn_print_info "${modprettyname} won't be updated to preserve custom files"
				fn_script_log "${modprettyname} won't be updated to preserve custom files."
				let installedmodsline=installedmodsline+1
			else
				echo ""
				fn_print_dots_nl "Updating ${modprettyname}"
				fn_script_log "Updating ${modprettyname}."
				# Check and create required files
				fn_mods_files
				# Clear lgsm/tmp/mods dir if exists then recreate it
				fn_clear_tmp_mods
				fn_mods_tmpdir
				# Download mod
				fn_mod_dl
				# Extract the mod
				fn_mod_extract
				# Convert to lowercase if needed
				fn_mod_lowercase
				# Remove files that should not be erased
				fn_remove_cfg_files
				# Build a file list
				fn_mod_fileslist
				# Copying to destination
				fn_mod_copy_destination
				# Ending with installation routines
				fn_mod_add_list
				# Post install fixes
				fn_postinstall_tasks
				# Cleaning
				fn_clear_tmp_mods
				fn_print_ok "${modprettyname} updated"
				fn_script_log "${modprettyname} updated."
				let installedmodsline=installedmodsline+1
			fi
		else
			fn_print_fail "No mod was selected"
			fn_script_log_fail "No mod was selected."
			exitcode="1"
			core_exit.sh
		fi
	done
	echo ""
	fn_print_ok_nl "Mods update complete"
	fn_script_log "Mods update complete."
}

fn_mods_update_init
fn_mods_update_loop
core_exit.sh
