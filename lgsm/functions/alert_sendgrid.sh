#!/bin/bash
# LinuxGSM alert_sendgrid.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends sendgrid Email alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

sendgridapiurl="https://api.sendgrid.com/v3/mail/send"

fn_print_dots "Sending Email alert: sendgrid: ${sendgridemail}"

sendgridsend=$(curl --request POST \
  --url ${sendgridapiurl} \
  --header "Authorization: Bearer ${sendgridapi}" \
  --header 'Content-Type: application/json' \
  --data '{"personalizations": [{"to": [{"email": "${sendgridemail}"}]}],"from": {"email": "${sendgridfrom}"},"subject": "${alertemoji} ${alertsubject} ${alertemoji}","content": [{"type": "text/plain", "value": "$(cat "${alertlog}")"}]}'
)

if [ -z "${sendgridsend}" ]; then
	fn_print_fail_nl "Sending Email alert: sendgrid: ${sendgridemail}"
	fn_script_log_fatal "Sending Email alert: sendgrid: ${sendgridemail}"
else
	fn_print_ok_nl "Sending Email alert: sendgrid: ${sendgridemail}"
	fn_script_log_pass "Sending Email alert: sendgrid: ${sendgridemail}"
fi
