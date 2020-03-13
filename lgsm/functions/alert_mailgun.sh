#!/bin/bash
# LinuxGSM alert_mailgun.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Sends Mailgun Email alert.

local modulename="ALERT"
local commandaction="Alert"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_print_dots "Sending Email alert: Mailgun: ${email}"

mailgunsend=$(curl -s --user "api:${mailguntoken}" \
-F from="LinuxGSM <${mailgunemailfrom}>" \
-F to="LinuxGSM Admin <${mailgunemail}>" \
-F subject="${alertemoji} ${alertsubject} ${alertemoji}" \
-F o:tag='alert' \
-F o:tag='LinuxGSM' \
-F text="$(cat "${alertlog}")" "https://api.mailgun.net/v3/${mailgundomain}/messages")

if [ -z "${mailgunsend}" ]; then
	fn_print_fail_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_fatal "Sending Email alert: Mailgun: ${email}"
else
	fn_print_ok_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_pass "Sending Email alert: Mailgun: ${email}"
fi
