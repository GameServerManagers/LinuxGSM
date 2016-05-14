#!/bin/bash
# LGSM command_email_test.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Sends a test email notification.

local modulename="Comms"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
info_config.sh
if [ "${emailnotification}" = "on" ]||[ "${pushbulletnotification}" = "on" ]; then
	fn_scriptlog "Sending Comms Check"
	commssubject="LGSM - Comms Check - ${servername}"
	commsbody="LGSM testing comms, how you read?"
	comms.sh
else
	fn_print_fail_nl "Notifications not enabled"
	fn_scriptlog "Notifications not enabled"
fi