#!/bin/bash
# LinuxGSM install_header.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Prints installation header.

local modulename="INSTALL"
local commandaction="Install"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

clear
fn_print_ascii_logo
fn_sleep_time
echo -e "================================="
echo -e "${lightyellow}Linux${default}GSM_"
echo -e "by Daniel Gibbs"
echo -e "${lightblue}Game:${default} ${gamename}"
echo -e "${lightblue}Website:${default} https://linuxgsm.com"
echo -e "${lightblue}Contributors:${default} https://linuxgsm.com/contrib"
echo -e "${lightblue}Donate:${default} https://linuxgsm.com/donate"
echo -e "================================="
fn_sleep_time
