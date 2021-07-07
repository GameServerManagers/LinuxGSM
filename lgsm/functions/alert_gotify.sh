#!/bin/bash
# LinuxGSM alert_gotify.sh module
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Gotify alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if ! command -v jq > /dev/null; then
	fn_print_fail_nl "Sending Gotify alert: jq is missing."
	fn_script_log_fatal "Sending Gotify alert: jq is missing."
fi

json=$(cat <<EOF
{
	"alias": "LinuxGSM",
	"text": "*${alertemoji} ${alertsubject} ${alertemoji}* \n *${servername}* \n ${alertbody} \n More info: ${alerturl}",
	"attachments": [
		{
			"fields": [
				{
					"short": true,
					"title": "Game:",
					"value": "${gamename}"
				},
				{
					"short": true,
					"title": "Server IP:",
					"value": "${alertip}:${port}"
				},
				{
					"short": true,
					"title": "Hostname:",
					"value": "${HOSTNAME}"
				}
			]
		}
	]
}
EOF
)

fn_print_dots "Sending Gotify alert"

gotifysend=$(curl --connect-timeout 10 -sSL -H "{"X-Gotify-Key": "${gotifytoken}" -X POST -d "$(echo -n "$json" | jq -c .)" "${gotifywebhook}")

if [ -n "${gotifysend}" ]; then
	fn_print_ok_nl "Sending Gotify alert"
	fn_script_log_pass "Sending Gotify alert"
else
	fn_print_fail_nl "Sending Gotify alert: ${gotifysend}"
	fn_script_log_fatal "Sending Gotify alert: ${gotifysend}"
fi
