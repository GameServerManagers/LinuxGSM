#!/bin/bash
# LinuxGSM alert_mailgun.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends Mailgun Email alert.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_print_dots "Sending Email alert: Mailgun: ${email}"
sleep 0.5
info_distro.sh
info_config.sh
info_glibc.sh
info_messages.sh
if [ -f "${emaillog}" ]; then
	rm "${emaillog}"
fi

{
	fn_info_message_head
	fn_info_message_distro
	fn_info_message_performance
	fn_info_message_disk
	fn_info_message_gameserver
	fn_info_logs
} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1

mailgunsend=$(curl -s --user "api:${mailguntoken}" \
-F from="LinuxGSM <${mailgunemailfrom}>" \
-F to="LinuxGSM Admin <${mailgunemail}>" \
-F subject="${alertemoji} ${alertsubject} ${alertemoji}" \
-F o:tag='alert' \
-F o:tag='LinuxGSM' \
-F text="$(cat ${emaillog})" https://api.mailgun.net/v3/${mailgundomain}/messages)

if [ -z "${mailgunsend}" ]; then
	fn_print_fail_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_fatal "Sending Email alert: Mailgun: ${email}"
else
	fn_print_ok_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_pass "Sending Email alert: Mailgun: ${email}"
fi