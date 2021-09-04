#!/bin/bash
# LinuxGSM command_test_alert.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Sends a test alert.

commandname="TEST-ALERT"
commandaction="Sending Alert"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots "${servername}"
check.sh
info_config.sh
alert="test"
alert.sh

core_exit.sh
