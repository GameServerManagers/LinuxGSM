#!/bin/bash
# LinuxGSM install_header.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Prints installation header.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

clear
fn_print_ascii_logo
fn_messages_separator
echo -e "${bold}${lightyellow}Linux${default}${bold}GSM_${default}"
echo -e "${italic}by Daniel Gibbs${default}"
echo -e "${lightblue}Version:${default} ${version}"
echo -e "${lightblue}Game:${default} ${gamename}"
echo -e "${lightblue}Website:${default} https://linuxgsm.com"
echo -e "${lightblue}Contributors:${default} https://linuxgsm.com/contrib"
echo -e "${lightblue}Sponsor:${default} https://linuxgsm.com/sponsor"
fn_messages_separator
