#!/bin/bash
# LinuxGSM command_test_alert.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends a test alert.

commandname="TEST-ALERT"
commandaction="Sending Alert"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots "${servername}"
check.sh
info_game.sh
alert="test"
alert.sh

core_exit.sh
