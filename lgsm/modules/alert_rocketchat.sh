#!/bin/bash
# LinuxGSM alert_rocketchat.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Rocketchat alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

jsoninfo=$(
	cat << EOF
{
	"alias": "LinuxGSM",
	"text": "*${alerttitle}*\n${alertmessage}\nMore info: ${alerturl}",
	"attachments": [
		{
			"fields": [
				{
					"short": true,
					"title": "Game",
					"value": "${gamename}"
				},
				{
					"short": true,
					"title": "Server IP",
					"value": "${alertip}:${port}"
				},
				{
					"short": true,
					"title": "Hostname",
					"value": "${HOSTNAME}"
				}
			]
		}
	]
}
EOF
)

jsonnoinfo=$(
	cat << EOF
{
	"alias": "LinuxGSM",
	"text": "*${alerttitle}*\n${alertmessage}",
	"attachments": [
		{
			"fields": [
				{
					"short": true,
					"title": "Game",
					"value": "${gamename}"
				},
				{
					"short": true,
					"title": "Server IP",
					"value": "${alertip}:${port}"
				},
				{
					"short": true,
					"title": "Hostname",
					"value": "${HOSTNAME}"
				}
			]
		}
	]
}
EOF
)

if [ -z "${alerturl}" ]; then
	json="${jsonnoinfo}"
else
	json="${jsoninfo}"
fi

fn_print_dots "Sending Rocketchat alert"
rocketchatsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${rocketchatwebhook}")

if [ -n "${rocketchatsend}" ]; then
	fn_print_ok_nl "Sending Rocketchat alert"
	fn_script_log_pass "Sending Rocketchat alert"
else
	fn_print_fail_nl "Sending Rocketchat alert: ${rocketchatsend}"
	fn_script_log_fail "Sending Rocketchat alert: ${rocketchatsend}"
fi
