#!/bin/bash
# LGSM command_mods_uninstall.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Uninstall mods along with mods_list.sh.

local commandname="MODS"
local commandaction="Mod Remove"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_core.sh
mods_list.sh

fn_mods_remove_init(){
  fn_script_log "Entering mods & addons removal"
	echo "================================="
	echo "${gamename} mods & addons removal"
	echo ""
	# Installed mod dir is "${modslockfilefullpath}"
	# How many mods are installed
	installedmodscount="$(cat "${modslockfilefullpath}" | wc -l)"
	# If no mods to be updated
	if [ ! -f "${modslockfilefullpath}" ]||[ $installedmodscount -eq 0 ]; then
		fn_print_information_nl "No mods or addons to remove"
		echo " * Did you install any mod using LGSM?"
		fn_script_log_info "No mods or addons to remove."
		core_exit.sh
	fi
	# Build installed mods list and display to the user.
	installedmodsline=1
	availablemodsremove=()
	while [ $installedmodsline -le $installedmodscount ]; do
		availablemodsremove+=( "$(sed "${installedmodsline}q;d" "${modslockfilefullpath}" )" )
		echo -e " * \e[36m$(sed "${installedmodsline}q;d" "${modslockfilefullpath}")\e[0m"
		let installedmodsline=installedmodsline+1
	done
	echo ""
  	# Keep prompting as long as the user input doesn't correspond to an available mod
	while [[ ! " ${availablemodsremove[@]} " =~ " ${usermodselect} " ]]; do
		echo -en "Enter a \e[36mmod\e[0m to \e[31mremove\e[0m (or exit to abort): "
		read -r usermodselect
		# Exit if user says exit or abort
		if [ "${usermodselect}" == "exit" ]||[ "${usermodselect}" == "abort" ]; then
			fn_script_log "User aborted."
			echo "Aborted."
			core_exit.sh
			# Supplementary output upon invalid user input 
		elif [[ ! " ${availablemodsremove[@]} " =~ " ${usermodselect} " ]]; then
				fn_print_error2_nl "${usermodselect} is not a valid mod."
				echo " * Enter a valid mod or input exit to abort."
		fi
	done
	# Gives a pretty name to the user and get all mod info
	currentmod="${usermodselect}"
	fn_mod_get_info_from_command
	# Returns ${modsfilelistsize}
	fn_check_files_list
	fn_script_log "Removing ${modsfilelistsize} files from ${modprettyname}"
	fn_print_dots "Removing ${modsfilelistsize} files from ${modprettyname}"
	echo " * Any mod's custom file will be deleted."
	echo " * Press ctrl + c to abort."
	sleep 4
}

fn_mod_remove_process(){
	# Check file list in order to make sure we're able to remove the mod
	modfileline="1"
	while [ $modfileline -le $modsfilelistsize ]; do
		# Current line defines current mod command
		currentfileremove="$(sed "${modfileline}q;d" "${modsdatadir}/${modcommand}-files.list")"
		if [ -f "${modinstalldir}/${currentfileremove}" ]||[ -d "${modinstalldir}/${currentfileremove}" ]; then
			fn_script_log "Removing: ${modinstalldir}/${currentfileremove}"
			rm -rf "${modinstalldir}/${currentfileremove}"
		fi
		let modfileline=modfileline+1
	done
	# Remove file list
	fn_script_log "Removing: ${modsdatadir}/${modcommand}-files.list"
	rm -rf "${modsdatadir}/${modcommand}-files.list"
	# Remove from installed mods list
	fn_script_log "Removing: ${modcommand} from ${modslockfilefullpath}"
	sed -i "/^${modcommand}$/d" "${modslockfilefullpath}"
	fn_print_ok_nl "Removed ${modprettyname}"
	fn_script_log "Removed ${modprettyname}"
}

fn_mods_remove_init
fn_mod_remove_process
