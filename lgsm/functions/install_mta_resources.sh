#!/bin/bash
# LinuxGSM install_mta_resources.sh function
# Author: Daniel Gibbs
# Contributor: ChaosMTA
# Website: https://linuxgsm.com
# Description: Installs the libmysqlclient for database functions on the server and optionally installs default resources required to run the server

local commandname="INSTALL"
local commandaction="Install"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_print_information_nl "${gamename} will not function without resources!"
echo -e "	* install default resources using ./${selfname} install-default-resources"
echo -e "	* download resources from https://community.multitheftauto.com"
