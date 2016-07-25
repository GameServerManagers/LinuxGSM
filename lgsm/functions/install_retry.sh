#!/bin/bash
# LGSM install_retry.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Asks for installation retry after failure.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

while true; do
	read -e -i "y" -p "Retry install? [Y/n]" yn
	case $yn in
	[Yy]* ) command_install.sh; exit;;
	[Nn]* ) echo Exiting; exit;;
	* ) echo "Please answer yes or no.";;
	esac
done