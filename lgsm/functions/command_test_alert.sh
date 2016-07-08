#!/bin/bash
# LGSM command_test_alert.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends a test email alert.

local commandnane="ALERT"
local commandaction="Alert"
local selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_print_dots "${servername}"
check.sh
info_config.sh
alert="test"
alert.sh
core_exit.sh
