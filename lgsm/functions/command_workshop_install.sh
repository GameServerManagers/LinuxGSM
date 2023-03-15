#!/bin/bash
# LinuxGSM command_workshop_install.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: List and installs available mods along with mods_list.sh and mods_core.sh.

commandname="WORKSHOP-INSTALL"
commandaction="Installing Steam Workshop mods"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
workshop_core.sh

fn_print_header
fn_create_workshop_dir
fn_workshop_get_list

# Displays a list of installed mods.

echo -e ""
echo -e "Installed workshop addons/mods"
echo -e "================================="
fn_workshop_installed_list

for modid in "${workshoplist[@]}"; do
	# Check if the mod is already installed and warn the user.
	# if ! fn_workshop_check_mod_update $modid; then
	# 	fn_print_warning_nl "$(fn_workshop_get_mod_name ${modid}) is already installed"
	# 	fn_script_log_warn "$(fn_workshop_get_mod_name ${modid}) is already installed"
	# 	echo -e " * Any configs may be overwritten."
	# 	if ! fn_prompt_yn "Continue?" Y; then
	# 		core_exit.sh
	# 	fi
	# 	fn_script_log_info "User selected to continue"
	# fi
	echo -e ""
	echo -e "Installing $(fn_workshop_get_mod_name ${modid})."
	echo -e "================================="
	fn_workshop_download "${modid}"
	fn_workshop_copy_destination "${modid}"s
done

fn_workshop_lowercase
core_exit.sh
