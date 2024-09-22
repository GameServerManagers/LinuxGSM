#!/bin/bash
# LinuxGSM command_sponsor.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Shows ways to sponsor.

commandname="SPONSOR"
commandaction="Sponsor"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_ascii_logo
echo -e "${lightyellow}Support LinuxGSM${default}"
fn_messages_separator
echo -e ""
echo -e "Been using LinuxGSM?"
echo -e "Consider sponsoring to support development."
echo -e ""
echo -e "* ${lightblue}GitHub:${default} https://github.com/sponsors/dgibbs64"
echo -e "* ${lightblue}Patreon:${default} https://linuxgsm.com/patreon"
echo -e "* ${lightblue}PayPal:${default} https://linuxgsm.com/paypal"
echo -e ""
echo -e "LinuxGSM est. 2012"

core_exit.sh
