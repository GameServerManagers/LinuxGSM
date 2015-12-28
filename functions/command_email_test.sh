#!/bin/bash
# LGSM command_email_test.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Sends a test email notification.

local modulename="Email"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
check.sh
info_config.sh
if [ "${emailnotification}" = "on" ]; then
	fn_scriptlog "Sending test notification"
	subject="${servicename} Email Test Notification - Testing ${servername}"
	failurereason="Testing ${servicename} email notification"
	actiontaken="Sent test email...hello is this thing on?"
	email.sh
else
	fn_printfailnl "Notifications not enabled"
	fn_scriptlog "Notifications not enabled"
fi