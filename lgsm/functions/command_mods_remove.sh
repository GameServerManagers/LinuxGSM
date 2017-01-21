#!/bin/bash
# LGSM command_mods_uninstall.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Uninstall mods along with mods_list.sh and mods_core.sh.

local commandname="MODS"
local commandaction="addons/mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_core.sh

fn_mods_remove_init(){
	fn_print_header
	echo "Remove addons/mods"
	echo "================================="
	# A simple function to exit if no mods were installed
	# Also returns ${installedmodscount} if mods were found
	fn_mods_exit_if_not_installed
	echo ""
	# Displays installed addons to the user
	fn_installed_mods_medium_list
	echo ""
  	# Keep prompting as long as the user input doesn't correspond to an available mod
	while [[ ! " ${installedmodslist[@]} " =~ " ${usermodselect} " ]]; do
		echo -en "Enter a ${cyan}mod${default} to ${red}remove${default} (or exit to abort): "
		read -r usermodselect
		# Exit if user says exit or abort
		if [ "${usermodselect}" == "exit" ]||[ "${usermodselect}" == "abort" ]; then
				core_exit.sh
		# Supplementary output upon invalid user input 
		elif [[ ! " ${availablemodscommands[@]} " =~ " ${usermodselect} " ]]; then
			fn_print_error2_nl "${usermodselect} is not a valid addon/mod."
		fi
	done
	fn_print_warning_nl "You are about to remove ${usermodselect}."
	echo " * Any custom files/configuration will be removed."
	while true; do
		read -e -i "y" -p "Continue? [Y/n]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) echo Exiting; exit;;
		* ) echo "Please answer yes or no.";;
	esac
	done	
	# Gives a pretty name to the user and get all mod info
	currentmod="${usermodselect}"
	fn_mod_get_info_from_command
	# Check file list in order to make sure we're able to remove the mod (returns ${modsfilelistsize})
	fn_check_files_list
	fn_script_log "Removing ${modsfilelistsize} files from ${modprettyname}"
	fn_print_dots "Removing ${modsfilelistsize} files from ${modprettyname}"
}

# Uninstall the mod
fn_mod_remove_process(){
	# Go through every file and remove it
	modfileline="1"
	while [ "${modfileline}" -le "${modsfilelistsize}" ]; do
		# Current line defines current file to remove
		currentfileremove="$(sed "${modfileline}q;d" "${modsdatadir}/${modcommand}-files.txt")"
		# If file or directory exists, then remove it
		if [ -f "${modinstalldir}/${currentfileremove}" ]||[ -d "${modinstalldir}/${currentfileremove}" ]; then
			fn_script_log "Removing: ${modinstalldir}/${currentfileremove}"
			rm -rf "${modinstalldir}/${currentfileremove}"
		fi
		let modfileline=modfileline+1
	done
	# Remove file list
	fn_script_log "Removing: ${modsdatadir}/${modcommand}-files.txt"
	rm -rf "${modsdatadir}/${modcommand}-files.txt"
	# Remove from installed mods list
	fn_script_log "Removing: ${modcommand} from ${modslockfilefullpath}"
	sed -i "/^${modcommand}$/d" "${modslockfilefullpath}"
	# Post install tasks to solve potential issues
	fn_postuninstall_tasks
	fn_print_ok_nl "Removed ${modprettyname}"
	fn_script_log "Removed ${modprettyname}"
}

fn_mods_remove_init
fn_mod_remove_process
core_exit.sh
