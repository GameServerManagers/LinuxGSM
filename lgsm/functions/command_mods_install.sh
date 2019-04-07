#!/bin/bash
# LinuxGSM command_mods_install.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: List and installs available mods along with mods_list.sh and mods_core.sh.

local commandname="MODS"
local commandaction="addons/mods"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh
mods_core.sh

fn_print_header

# Displays a list of installed mods
fn_mods_installed_list
if [ "${installedmodscount}" -gt "0" ]; then
	echo "Installed addons/mods"
	echo "================================="
	# Go through all available commands, get details and display them to the user
	for ((llindex=0; llindex < ${#installedmodslist[@]}; llindex++)); do
		# Current mod is the "llindex" value of the array we're going through
		currentmod="${installedmodslist[llindex]}"
		fn_mod_get_info
		# Display mod info to the user
		echo -e " * ${green}${modcommand}${default}${default}"
	done
	echo ""
fi

echo "Available addons/mods"
echo "================================="
# Display available mods from mods_list.sh
# Set and reset vars
compatiblemodslistindex=0
# As long as we're within index values
while [ "${compatiblemodslistindex}" -lt "${#compatiblemodslist[@]}" ]; do
	# Set values for convenience
	displayedmodname="${compatiblemodslist[compatiblemodslistindex]}"
	displayedmodcommand="${compatiblemodslist[compatiblemodslistindex+1]}"
	displayedmodsite="${compatiblemodslist[compatiblemodslistindex+2]}"
	displayedmoddescription="${compatiblemodslist[compatiblemodslistindex+3]}"
	# Output mods to the user
	echo -e "${displayedmodname} - ${displayedmoddescription} - ${displayedmodsite}"
	echo -e " * ${cyan}${displayedmodcommand}${default}"
	# Increment index from the amount of values we just displayed
	let "compatiblemodslistindex+=4"
	((totalmodsavailable++))
done

# If no mods are available for a specific game
if [ -z "${compatiblemodslist}" ]; then
	fn_print_fail_nl "No mods are currently available for ${gamename}."
	fn_script_log_info "No mods are currently available for ${gamename}."
	core_exit.sh
fi
fn_script_log_info "${totalmodsavailable} addons/mods are available for install"

## User selects a mod
echo ""
while [[ ! " ${availablemodscommands[@]} " =~ " ${usermodselect} " ]]; do
	echo -en "Enter an ${cyan}addon/mod${default} to ${green}install${default} (or exit to abort): "
	read -r usermodselect
	# Exit if user says exit or abort
	if [ "${usermodselect}" == "exit" ]||[ "${usermodselect}" == "abort" ]; then
			core_exit.sh
	# Supplementary output upon invalid user input
	elif [[ ! " ${availablemodscommands[@]} " =~ " ${usermodselect} " ]]; then
		fn_print_error2_nl "${usermodselect} is not a valid addon/mod."
	fi
done
# Get mod info
currentmod="${usermodselect}"
fn_mod_get_info

echo ""
echo "Installing ${modprettyname}"
echo "================================="
fn_script_log_info "${modprettyname} selected for install"

# Check if the mod is already installed and warn the user
if [ -f "${modsinstalledlistfullpath}" ]; then
	if [ -n "$(sed -n "/^${modcommand}$/p" "${modsinstalledlistfullpath}")" ]; then
		fn_print_warning_nl "${modprettyname} is already installed"
		fn_script_log_warn "${modprettyname} is already installed"
		sleep 0.5
		echo " * Any configs may be overwritten."
		if ! fn_prompt_yn "Continue?" Y; then
			echo Exiting; core_exit.sh
		fi
		fn_script_log_info "User selected to continue"
	fi
fi

## Installation

fn_create_mods_dir
fn_mods_clear_tmp_dir
fn_mods_create_tmp_dir
fn_mod_install_files
fn_mod_lowercase
fn_mod_create_filelist
fn_mod_copy_destination
fn_mod_add_list
fn_mod_tidy_files_list
fn_mods_clear_tmp_dir
echo "${modprettyname} installed"
fn_script_log_pass "${modprettyname} installed."

core_exit.sh
