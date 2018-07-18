#!/bin/bash
# LinuxGSM install_header.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Prints installation header.

commandname="INSTALL"
commandaction="Install"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

clear
echo "================================="
echo "${gamename}"
echo "Linux Game Server Manager"
echo "by Daniel Gibbs"
echo "Contributors: http://goo.gl/qLmitD"
echo "https://linuxgsm.com"
echo "================================="
