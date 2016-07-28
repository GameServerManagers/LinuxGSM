#!/bin/bash
# LGSM install_header.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Prints installation header.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

clear
echo "================================="
echo "${gamename}"
echo "Linux Game Server Manager"
echo "by Daniel Gibbs"
echo "Contributors: http://goo.gl/qLmitD"
echo "https://gameservermanagers.com"
echo "================================="
