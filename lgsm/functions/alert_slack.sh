#!/bin/bash
# LinuxGSM alert_slack.sh function
# Author: Kenneth Lindeof
# Website: https://linuxgsm.com
# Description: Sends Slack alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if ! command -v jq > /dev/null; then
	fn_print_fail_nl "Sending Slack alert: jq is missing."
	fn_script_log_fatal "Sending Slack alert: jq is missing."
fi

json=$(cat <<EOF
{
	"attachments": [
		{
			"color": "#36a64f",
			"blocks": [
				{
					"type": "section",
					"text": {
						"type": "mrkdwn",
						"text": "*${alertemoji} ${alertsubject} ${alertemoji}*"
					}
				},
				{
					"type": "section",
					"text": {
						"type": "mrkdwn",
						"text": "*${servername}*"
					}
				},
				{
					"type": "section",
					"text": {
						"type": "mrkdwn",
						"text": "${alertbody}"
					}
				},
				{
					"type": "divider"
				},
				{
					"type": "section",
					"fields": [
						{
							"type": "mrkdwn",
							"text": "*Game:* \n ${gamename}"
						},
						{
							"type": "mrkdwn",
							"text": "*Server IP:* \n ${alertip}:${port}"
						},
						{
							"type": "mrkdwn",
							"text": "*Hostname:* \n ${HOSTNAME}"
						}
					]
				},
				{
					"type": "divider"
				},
				{
					"type": "section",
					"text": {
						"type": "mrkdwn",
						"text": "Hostname: ${HOSTNAME} / More info: ${alerturl}"
					}
				}
			]
		}
	]
}
EOF
)

fn_print_dots "Sending Slack alert"

slacksend=$(curl -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "$json" | jq -c .)" "${slackwebhook}")

if [ "${slacksend}" == "ok" ]; then
	fn_print_ok_nl "Sending Slack alert"
	fn_script_log_pass "Sending Slack alert"
else
		fn_print_fail_nl "Sending Slack alert: ${slacksend}"
	fn_script_log_fatal "Sending Slack alert: ${slacksend}"
fi
