#!/usr/bin/env bash
# LinuxGSM install_server_dir.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates the server directory.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo ""
echo "Server Directory"
echo "================================="
sleep 1
if [ -d "${serverfiles}" ]; then
	fn_print_warning_nl "A server is already installed here."
fi
pwd
echo ""
if [ -z "${autoinstall}" ]; then
	if ! fn_prompt_yn "Continue?" Y; then
		exit
	fi
fi
if [ ! -d "${serverfiles}" ]; then
	mkdir -v "${serverfiles}"
fi
sleep 1
