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
if [ "${emailalert}" = "on" ]||[ "${pushbulletalert}" = "on" ]; then
	alert="test"
	alert.sh
else
	fn_print_fail_nl "alerts not enabled"
	fn_scriptlog "alerts not enabled"
fi