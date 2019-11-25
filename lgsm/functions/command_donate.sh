#!/bin/bash
# LinuxGSM command_donate.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Shows ways to donate.

local commandname="CONSOLE"
local commandaction="Console"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_print_ascii_logo
echo -e "${lightyellow}Support LinuxGSM${default}"
echo -e "================================="
echo -e ""
echo -e "Been using LinuxGSM?"
echo -e "Consider donating to support development."
echo -e ""
echo -e "* ${lightblue}Patreon:${default} https://linuxgsm.com/patreon"
echo -e "* ${lightblue}PayPal:${default} https://linuxgsm.com/paypal"
echo -e "* ${lightblue}Ko-Fi:${default} https://linuxgsm.com/ko-fi"
echo -e ""
echo -e "LinuxGSM est. 2012"

core_exit.sh
