#!/bin/bash
# LinuxGSM alert_mailgun.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Mailgun Email alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${mailgunapiregion}" == "eu" ]; then
	mailgunapiurl="https://api.eu.mailgun.net"
else
	mailgunapiurl="https://api.mailgun.net"
fi

fn_print_dots "Sending Email alert: Mailgun: ${email}"

mailgunsend=$(curl --connect-timeout 10 -s --user "api:${mailguntoken}" \
-F from="LinuxGSM <${mailgunemailfrom}>" \
-F to="LinuxGSM Admin <${mailgunemail}>" \
-F subject="${alertemoji} ${alertsubject} ${alertemoji}" \
-F o:tag='alert' \
-F o:tag='LinuxGSM' \
-F text="$(cat "${alertlog}")" "${mailgunapiurl}/v3/${mailgundomain}/messages")

if [ -z "${mailgunsend}" ]; then
	fn_print_fail_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_fatal "Sending Email alert: Mailgun: ${email}"
else
	fn_print_ok_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_pass "Sending Email alert: Mailgun: ${email}"
fi
