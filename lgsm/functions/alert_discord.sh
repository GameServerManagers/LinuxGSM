#!/bin/bash
# LinuxGSM alert_discord.sh function
# Author: Daniel Gibbs
# Contributor: faflfama, diamondburned
# Website: https://linuxgsm.com
# Description: Sends Discord alert.

if ! command -v jq > /dev/null; then
	fn_print_fail_nl "Sending Discord alert: jq is missing."
	fn_script_log_fatal "Sending Discord alert: jq is missing."
fi

escaped_servername=$(echo -n "${servername}" | jq -sRr "@json")
escaped_alertbody=$(echo -n "${alertbody}" | jq -sRr "@json")

json=$(cat <<EOF
{
	"username":"LinuxGSM",
	"avatar_url":"https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.png",
	"file":"content",
	"embeds": [{
		"color": "2067276",
		"author": {"name": "${alertemoji} ${alertsubject}", "icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.png"},
		"title": "",
		"description": ${escaped_alertbody},
		"url": "",
		"type": "content",
		"thumbnail": {},
		"footer": {"text": "Hostname: ${HOSTNAME} / More info: ${alerturl}", "icon_url": ""},
		"fields": [
			{
				"name": "Game",
				"value": "${gamename}",
				"inline": true
			},
			{
				"name": "Server IP",
				"value": "[${alertip}:${port}](https://www.gametracker.com/server_info/${alertip}:${port})",
				"inline": true
			},
			{
				"name": "Server Name",
				"value": ${escaped_servername},
				"inline": true
			}
		]
	}]
}
EOF
)

fn_print_dots "Sending Discord alert"

discordsend=$(curl -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "$json" | jq -c .)" "${discordwebhook}")

if [ -n "${discordsend}" ]; then
	fn_print_fail_nl "Sending Discord alert: ${discordsend}"
	fn_script_log_fatal "Sending Discord alert: ${discordsend}"
else
	fn_print_ok_nl "Sending Discord alert"
	fn_script_log_pass "Sending Discord alert"
fi
