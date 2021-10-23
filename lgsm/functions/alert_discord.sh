#!/bin/bash
# LinuxGSM alert_discord.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Discord alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

jsonshort=$(cat <<EOF
{
	"username": "LinuxGSM Alert",
	"avatar_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
	"content": "",
	"embeds": [
		{
			"author": {
				"name": "${servername}",
				"url": "",
				"icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
			},
			"title": "${alertemoji} ${alerttriggermessage}",
			"url": "",
			"description": "",
			"color": "${alertcolourdec}",
			"thumbnail": {
				"url": "${alerticon}"
			}
		}
	]
}
EOF
)

json=$(cat <<EOF
{
	"username": "LinuxGSM Alert",
	"avatar_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
	"content": "",
	"embeds": [
		{
			"author": {
				"name": "LinuxGSM Alert",
				"url": "",
				"icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
			},
			"title": "${servername}",
			"url": "",
			"description": "${alertemoji} ${alerttitle}",
			"color": "${alertcolourdec}",
			"fields": [
				{
				"name": "Game",
				"value": "${gamename}"
				},
				{
				"name": "${alertplayerstitle}",
				"value": "${alertplayers}",
				"inline": true
				},
				{
				"name": "Map",
				"value": "${alertmap}",
				"inline": true
				},
				{
				"name": "Version",
				"value": "${alertversion}",
				"inline": true
				},
				{
				"name": "Country",
				"value": "${countryflag} ${country}",
				"inline": true
				},
				{
				"name": "Server IP",
				"value": "${alertip}:${port}",
				"inline": true
				},
				{
				"name": "Hostname",
				"value": "${HOSTNAME}",
				"inline": true
				},
				{
					"name": "Trigger Message",
					"value": "${alerttriggermessage}"
				},
				{
					"name": "More Info",
					"value": "${alertmoreinfourl}"
				}
			],
			"thumbnail": {
				"url": "${alerticon}"
			},
			"image": {
				"url": "${alertimage}"
			},
			"footer": {
				"text": "Powered by LinuxGSM ${version}",
				"icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
			}
		}
	]
}
EOF
)

if [ "${alerttype}" == "short" ]; then
	json="${jsonshort}"
fi

fn_print_dots "Sending Discord alert"

discordsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${discordwebhook}")

if [ -n "${discordsend}" ]; then
	fn_print_fail_nl "Sending Discord alert: ${discordsend}"
	fn_script_log_fatal "Sending Discord alert: ${discordsend}"
else
	fn_print_ok_nl "Sending Discord alert"
	fn_script_log_pass "Sending Discord alert"
fi
