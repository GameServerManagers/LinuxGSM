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
	echo "${gamename} mods & addons update"
	echo ""
	# Installed mod dir is "${modslockfilefullpath}"
	# How many mods are installed
	installedmodscount="$(cat "${modslockfilefullpath}" | wc -l)"
	# If no mods to be updated
	if [ ! -f "${modslockfilefullpath}" ]||[ $installedmodscount -eq 0 ]; then
		fn_print_information_nl "No mods or addons to remove"
		echo " * Did you install any mod using LGSM?"
		fn_scrip_log_info "No mods or addons to remove."
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
	sleep 1
  
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
	fn_print_dots_nl "Removing ${modprettyname}"
	sleep 1
	fn_script_log "Removing ${modprettyname}."
}

fn_mods_remove_init
