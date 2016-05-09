#!/bin/bash
# LGSM install_mod function
# Author: Jared Ballou
# Website: http://gameservermanagers.com

# TODO: Fix this to use the new hierarchial mod structure

# Description: Display menu of available mods, and add them to game settings

# Perform installation
fn_runfunction menu.sh

# Listing of available games
modlist="gamedata/__mod_list"

# Installation path
installpath=$(cd ~ && pwd)

# Get game list
fn_getgithubfile "${modlist}"

gamemods="$(grep "^${selfname}\/" "${lgsmdir}/${modlist}" | cut -d'/' -f2-)"
if [ "${gamemods}" == "" ]; then
	echo "Sorry, there are no mods available for your current game."
	exit
fi

# Display installer menu
fn_menu result "Linux Game Server Manager" "Select mod to install" "${gamemods}"
#echo $result
# If we have a selection, do the install
if [ -n "${result}" ]; then
	game_mod="${result}"
	fn_set_game_setting settings "game_mod" "${result}"
	fn_update_config "game_mod" "${result}" "${cfg_file_instance}"
#	modlink="${lgsmserverdir}/mod"
#	modtarget="${gamedatadir}/mods/${selfname}/${result}"
#	if [ "$(readlink -f "${modlink}")" != "${modtarget}" ]; then
#		ln -nsvf "${modtarget}" "${modlink}"
#	fi
fi
