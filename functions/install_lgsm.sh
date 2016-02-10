#!/bin/bash
# LGSM install_lgsm function
# Author: Jared Ballou
# Website: http://gameservermanagers.com

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
#echo $result
# If we have a selection, do the install
if [ -n "${result}" ]; then
	if [ "${BASH_SOURCE[0]}" == "" ]; then
		scriptpath="${installpath}/${result}"
	else
		# Confirm path for installation
		read -p "Select path to install ${result} [${installpath}]: " input
		installpath=${input:-$installpath}
		scriptpath="${installpath}/${result}"
		# If file exists, confirm overwrite
		if [ -e "${scriptpath}" ]; then
			read -p "WARNING! ${scriptpath} already exists! OVERWRITE!? [y/N]: " input
			if [ "${input}" != "y" ] && [ "${input}" != "Y" ]; then exit; fi
		fi
	fi
	# Install script
	echo -ne "Installing to ${scriptpath}... \c"
	# Create directory if missing. TODO: Gravefully handle errors like giving a file as the install dir
	if [ ! -e $(dirname "${scriptpath}") ]; then
		mkdir -p $(dirname "${scriptpath}")
	fi
	# Copy script and set executable
	fn_getgithubfile "${scriptpath}" noexec "${core_script}"
	chmod 0755 "${scriptpath}"
	if [ $? ]; then
		fn_colortext green "Done"
		echo "Script deployed! To install game, run:"
		echo "${scriptpath} install"
	else
		fn_colortext red "FAIL"
	fi
fi
