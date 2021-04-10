#!/bin/bash
# LinuxGSM alert_discord.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Discord alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if ! command -v jq > /dev/null; then
	fn_print_fail_nl "Sending Discord alert: jq is missing."
	fn_script_log_fatal "Sending Discord alert: jq is missing."
fi

json=$(cat <<EOF
{
	"username":"LinuxGSM",
	"avatar_url":"https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
	"file":"content",
	"embeds": [{
		"color": "2067276",
		"author": {
			"name": "${alertemoji} ${alertsubject} ${alertemoji}",
			"icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
		},
		"title": "${servername}",
		"description": "${alertbody} \n More info: ${alerturl}",
		"url": "",
		"type": "content",
		"thumbnail": {},
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
				"name": "Hostname",
				"value": "${HOSTNAME}",
				"inline": true
			}
		]
	}]
}
EOF
)

fn_print_dots "Sending Discord alert"

discordsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "$json" | jq -c .)" "${discordwebhook}")

if [ -n "${discordsend}" ]; then
	fn_print_fail_nl "Sending Discord alert: ${discordsend}"
	fn_script_log_fatal "Sending Discord alert: ${discordsend}"
else
	fn_print_ok_nl "Sending Discord alert"
	fn_script_log_pass "Sending Discord alert"
fi
