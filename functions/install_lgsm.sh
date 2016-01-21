#!/bin/bash
# LGSM install_lgsm function
# Author: Jared Ballou
# Website: http://gameservermanagers.com
lgsm_version="200116"

# Description: Display menu of available games and install the one selected

# Perform installation
fn_runfunction menu.sh
# Listing of available games
gamelist="gamedata/__game_list"
# Installation path
installpath=$(cd ~ && pwd)
# Get game list
fn_getgithubfile $gamelist
# Display installer menu
fn_menu result "Linux Game Server Manager" "Select game to install" "${lgsmdir}/${gamelist}"
# If we have a selection, do the install
if [ -n "${result}" ]; then
	# Confirm path for installation
	read -p "Select path to install ${result} [${installpath}]: " input
	installpath=${input:-$installpath}
	scriptpath="${installpath}/${result}"
	# If file exists, confirm overwrite
	if [ -e "${scriptpath}" ]; then
		read -p "WARNING! ${scriptpath} already exists! OVERWRITE!? [y/N]: " input
		if [ "${input}" != "y" ] && [ "${input}" != "Y" ]; then exit; fi
	fi
	# Install script
	echo -ne "Installing to ${scriptpath}... \c"
	# Create directory if missing. TODO: Gravefully handle errors like giving a file as the install dir
	if [ ! -e $(dirname "${scriptpath}") ]; then
		mkdir -p $(dirname "${scriptpath}")
	fi
	# Copy script and set executable
	cp "${0}" "${scriptpath}"
	chmod 0755 "${scriptpath}"
	if [ $? ]; then
		fn_colortext green "Done"
		echo "Script deployed to ${scriptpath}"
	else
		fn_colortext red "FAIL"
	fi
fi
