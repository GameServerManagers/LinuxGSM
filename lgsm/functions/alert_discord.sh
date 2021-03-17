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
  "username": "LinuxGSM Alert",
  "avatar_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
  "content": "",
  "embeds": [
    {
      "author": {
        "name": "LinuxGSM",
        "url": "",
        "icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
      },
      "title": "${servername}",
      "url": "",
      "description": "${alertemoji} ${alertsubject}",
      "color": 15258703,
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
        },
        {
          "name": "Information",
          "value": "${alertbody} \n More info: ${alerturl}"
        }
      ],
      "thumbnail": {
        "url": "https://linuxgsm.com/wp-content/uploads/2020/07/minecraft-bedrock-icon.jpg"
      },
      "image": {
        "url": "https://linuxgsm.com/wp-content/uploads/2021/02/mcbe-header.jpg"
      },
      "footer": {
        "text": "Powered by LinuxGSM",
        "icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
      }
    }
  ]
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
