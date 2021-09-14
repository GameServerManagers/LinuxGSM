#!/bin/bash
# LinuxGSM alert_gotify.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Gotify alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(cat <<EOF
{
	"title": "${alertemoji} ${alertsubject} ${alertemoji}",
	"message": "Server name\n${servername}\n\nMessage\n${alertbody}\n\nGame\n${gamename}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\nMore info\n${alerturl}",
	"priority": 5
}
EOF
)

fn_print_dots "Sending Gotify alert"

gotifysend=$(curl --connect-timeout 10 -sSL "${gotifywebhook}/message"?token="${gotifytoken}" -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)")

if [ -n "${gotifysend}" ]; then
	fn_print_ok_nl "Sending Gotify alert"
	fn_script_log_pass "Sending Gotify alert"
else
	fn_print_fail_nl "Sending Gotify alert: ${gotifysend}"
	fn_script_log_fatal "Sending Gotify alert: ${gotifysend}"
fi
