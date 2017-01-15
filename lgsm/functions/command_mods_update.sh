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
	installedmodscount="$(cat "${modslockfilefullpath}" | wc -l)"
	# If no mods to be updated
	if [ ! -f "${modslockfilefullpath}" ]||[ $installedmodscount -eq 0 ]; then
		fn_print_information_nl "No mods or addons to be updated"
		echo " * Did you install any mod using LGSM?"
		fn_scrip_log_info "No mods or addons to be updated"
		core_exit.sh
	else
		fn_print_information_nl "${installedmodscount} mods or addons will be updated:"
		fn_script_log_info "${installedmodscount} mods or addons will be updated"
		# Loop showing mods to update
		installedmodsline=1
		while [ $installedmodsline -le $installedmodscount ]; do
			echo -e " * \e[36m$(sed "${installedmodsline}q;d" "${modslockfilefullpath}")\e[0m"
			let installedmodsline=installedmodsline+1
		done
		sleep 2
	fi
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
				fn_print_warning_nl "${modprettyname} update has been disabled by LGSM."
				echo " * Usual reason is to prevent erasing custom files."
				echo " * If you still wish to update this mod:"
				echo " *  1) Backup your critical mod files"
				echo " *  2) Uninstall the mod with ./${selfname} mods-uninstall (optionnal)"
				echo " *  3) Re-install the mod with ./${selfname} mods-install"
				let installedmodsline=installedmodsline+1
			else
				fn_print_dots_nl "Updating ${modprettyname}"
				fn_script_log "Updating ${modprettyname}."
				# Check and create required directories
				fn_mods_dir
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
				fn_print_ok_nl "${modprettyname} installed."
				fn_script_log "${modprettyname} installed."
				let installedmodsline=installedmodsline+1
			fi
		else
			fn_print_fail "No mod was selected."
			fn_script_log_fail "No mod was selected."
			core_exit.sh
		fi
	done
}

fn_mods_update_init
fn_mods_update_loop
