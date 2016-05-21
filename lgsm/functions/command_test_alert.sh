#!/bin/bash
# LGSM command_email_test.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Sends a test email alert.

local modulename="Alert"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
info_config.sh
alert="test"
alert.sh
