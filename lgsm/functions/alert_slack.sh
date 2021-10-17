#!/bin/bash
# LinuxGSM alert_slack.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Slack alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(cat <<EOF
{
	"blocks": [
		{
			"type": "context",
			"elements": [
				{
					"type": "image",
					"image_url": "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/alert_discord_logo.jpg",
					"alt_text": "LinuxGSM"
				},
				{
					"type": "mrkdwn",
					"text": "*LinuxGSM Alert*"
				}
			]
		},
		{
			"type": "context",
			"elements": [
				{
					"type": "image",
					"image_url": "${alerticon}",
					"alt_text": "${alerticonalt}"
				},
				{
					"type": "mrkdwn",
					"text": "${gamename}"
				}
			]
		},
		{
			"type": "header",
			"text": {
				"type": "plain_text",
				"text": "${servername}",
				"emoji": true
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "*${alertemoji} ${alerttitle} ${alertemoji}*"
			},
			"accessory": {
				"type": "image",
				"image_url": "${alertimage}",
				"alt_text": "${alertimagealt}"
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "*Game*\n${gamename}"
			}
		},
		{
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": "*Map*"
				},
				{
					"type": "mrkdwn",
					"text": "*${alertplayerstitle}*"
				},
				{
					"type": "mrkdwn",
					"text": "${alertmap}"
				},
				{
					"type": "mrkdwn",
					"text": "${alertplayers}"
				}
			]
		},
		{
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": "*Version*"
				},
				{
					"type": "mrkdwn",
					"text": "*Country*"
				},
				{
					"type": "mrkdwn",
					"text": "${alertversion}"
				},
				{
					"type": "mrkdwn",
					"text": "${country}"
				}
			]
		},
		{
			"type": "section",
			"fields": [
				{
					"type": "mrkdwn",
					"text": "*Server IP*"
				},
				{
					"type": "mrkdwn",
					"text": "*Hostname*"
				},
				{
					"type": "mrkdwn",
					"text": "${alertip}:${port}"
				},
				{
					"type": "mrkdwn",
					"text": "${HOSTNAME}"
				}

			]
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "*Trigger Message*\n${alerttriggermessage}"
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "*More info*\n${alertmoreinfourl}"
			}
		},
		{
			"type": "divider"
		},
		{
			"type": "context",
			"elements": [
				{
					"type": "image",
					"image_url": "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/alert_discord_logo.jpg",
					"alt_text": "LinuxGSM Logo"
				},
				{
					"type": "plain_text",
					"text": "Powered by LinuxGSM ${version}",
					"emoji": true
				}
			]
		},
		{
			"type": "divider"
		}
	]
}
EOF
)

fn_print_dots "Sending Slack alert"
slacksend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${slackwebhook}")

if [ "${slacksend}" == "ok" ]; then
	fn_print_ok_nl "Sending Slack alert"
	fn_script_log_pass "Sending Slack alert"
else
	fn_print_fail_nl "Sending Slack alert: ${slacksend}"
	fn_script_log_fatal "Sending Slack alert: ${slacksend}"
fi
