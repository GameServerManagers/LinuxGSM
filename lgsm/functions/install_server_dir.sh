#!/bin/bash
# LinuxGSM install_server_dir.sh function
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
if [ -d "${filesdir}" ]; then
	fn_print_warning_nl "A server is already installed here."
fi
pwd
echo ""
if [ -z "${autoinstall}" ]; then
	if ! fn_prompt_yn "Continue?" Y; then
		exit
	fi
fi
if [ ! -d "${filesdir}" ]; then
	mkdir -v "${filesdir}"
fi
sleep 1
