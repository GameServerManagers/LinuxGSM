#!/bin/bash
# LinuxGSM command_dev_ui.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Dev only: Assist with UI development.

commandname="DEV-DEBUG"
commandaction="Developer ui"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_header

# Load ANSI colors
fn_ansi_loader

echo -e ""
echo -e "${lightgreen}Colours${default}"
fn_messages_separator
# Print supported colors
echo -e "${default}default"
echo -e "${black}black${default}"
echo -e "${red}red${default}"
echo -e "${lightred}lightred${default}"
echo -e "${green}green${default}"
echo -e "${lightgreen}lightgreen${default}"
echo -e "${yellow}yellow${default}"
echo -e "${lightyellow}lightyellow${default}"
echo -e "${blue}blue${default}"
echo -e "${lightblue}lightblue${default}"
echo -e "${magenta}magenta${default}"
echo -e "${lightmagenta}lightmagenta${default}"
echo -e "${cyan}cyan${default}"
echo -e "${lightcyan}lightcyan${default}"
echo -e "${darkgrey}darkgrey${default}"
echo -e "${lightgrey}lightgrey${default}"
echo -e "${white}white${default}"
echo -e "${bold}bold${default}"
echo -e "${dim}dim${default}"
echo -e "${italic}italic${default}"
echo -e "${underline}underline${default}"
echo -e "${reverse}reverse${default}"

core_exit.sh
