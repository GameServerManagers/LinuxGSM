#!/bin/bash
# LinuxGSM install_header.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Prints installation header.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

clear
fn_print_ascii_logo
fn_sleep_time
echo -e "================================="
echo -e "${lightyellow}Linux${default}GSM_"
echo -e "by Daniel Gibbs"
echo -e "${lightblue}Version:${default} ${version}"
echo -e "${lightblue}Game:${default} ${gamename}"
echo -e "${lightblue}Website:${default} https://linuxgsm.com"
echo -e "${lightblue}Contributors:${default} https://linuxgsm.com/contrib"
echo -e "${lightblue}Sponsor:${default} https://linuxgsm.com/sponsor"
echo -e "================================="
fn_sleep_time
