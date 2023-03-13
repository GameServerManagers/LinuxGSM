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
echo -e "Installed workshop addons/mods"
echo -e "================================="
fn_workshop_installed_list

for modid in "${workshoplist[@]}"; do
    modname="$(fn_workshop_get_mod_name $modid)"
    if fn_workshop_check_mod_update $modid; then
        echo "Mod ${modname} (${modid}) is not up to date."
        fn_workshop_download $modid
        fn_workshop_copy_destination $modid
    else
        echo "Mod $modname is up to date."
    fi
done

fn_workshop_lowercase
core_exit.sh
