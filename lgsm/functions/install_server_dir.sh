#!/bin/bash
# LGSM install_server_dir.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates the server directory.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

echo ""
echo "Server Directory"
echo "================================="
sleep 1
echo ""
pwd
echo ""
if [ -d "${filesdir}" ]; then
	fn_print_warning_nl "A server is already installed here."
fi
if [ -z "${autoinstall}" ]; then
	while true; do
		read -e -i "y" -p "Continue [Y/n]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer yes or no.";;
		esac
	done
fi
if [ ! -d "${filesdir}" ]; then
	mkdir -v "${filesdir}"
fi
sleep 1