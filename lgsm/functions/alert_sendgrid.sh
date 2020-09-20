#!/bin/bash
# LinuxGSM alert_sendgrid.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Sends SendGrid Email alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_print_dots "Sending Email alert: SendGrid: ${email}"

sendgridsend=$(curl --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header "Authorization: Bearer ${sendgridtoken}" \
  --header 'Content-Type: application/json' \
  --data '{"personalizations": [{"to": [{"email": ${sendgridemail}"}]}],"from": {"email": "${sendgridemailfrom}"},"subject": "${alertemoji} ${alertsubject} ${alertemoji}","content": [{"type": "text/plain", "value": "$(cat "${alertlog}")"}]}')

if [ -z "${mailgunsend}" ]; then
	fn_print_fail_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_fatal "Sending Email alert: Mailgun: ${email}"
else
	fn_print_ok_nl "Sending Email alert: Mailgun: ${email}"
	fn_script_log_pass "Sending Email alert: Mailgun: ${email}"
fi
