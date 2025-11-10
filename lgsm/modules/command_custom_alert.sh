#!/bin/bash
# LinuxGSM command_custom_alert.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends a custom alert.

commandname="CUSTOM-ALERT"
commandaction="Custom Alert"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh

if [ -n "${userinput2}" ]; then
	customalertmessage="${userinput2}"
else
	fn_print_header
	fn_print_information_nl "Send a custom alert."
	echo ""
	customalertmessage=$(fn_prompt_message "alert message: ")
fi

# optional: custom alert title
if [ -n "${userinput3}" ]; then
	customalerttitle="${userinput3}"
else
	customalerttitle="Custom Alert"
fi

info_game.sh
alert="custom"
alert.sh

core_exit.sh
