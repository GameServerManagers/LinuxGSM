#!/bin/bash
# LGSM command_mods_update.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Updates installed mods along with mods_list.sh.

local commandname="MODS"
local commandaction="Mods Update"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
mods_list.sh

fn_mods_update_init(){
	fn_script_log "Entering mods & addons update"
	echo "================================="
	echo "${gamename} mods & addons update"
	echo ""
	# Installed mod dir is "${modslockfilefullpath}"
	# How many mods will be updated
	installedmodscount="$(cat "${modslockfilefullpath}" | wc -l)"
	echo "${installedmodscount} addons will be updated:"
	# Loop showing mods to update
	installedmodsline=1
	while [ $installedmodsline -le $installedmodscount ]; do
		echo -e " * \e[36m$(sed "${installedmodsline}q;d" "${modslockfilefullpath}")\e[0m"
		let installedmodsline=installedmodsline+1
	done
	exit
	#currentmod="${usermodselect}"
	#fn_mod_get_info_from_command
	#fn_print_dots_nl "Updating ${modprettyname}"
	#sleep 1
	#fn_script_log "Updating ${modprettyname}."
}

fn_mods_update_init
