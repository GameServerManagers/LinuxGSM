#!/bin/bash
# LinuxGSM alert_discord.sh function
# Author: Daniel Gibbs
# Contributor: faflfama
# Website: https://gameservermanagers.com
# Description: Sends Discord alert.

bot_name="${discord_bot_name:-LinuxGSM}"
avatar_url="${discord_avatar_url:-https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/images/logo/lgsm-dark-square-512.png}"
shown_ip_address="${discord_public_ip:-$ip}"
shown_port="${discord_public_port:-$port}"

json=$(cat <<EOF
{
"username":"${bot_name}",
"avatar_url":"${avatar_url}",
"file":"content",

"embeds": [{
	"color": "2067276",
	"author": {"name": "${alertemoji} ${alertsubject} ${alertemoji}", "icon_url": "${avatar_url}"},
	"title": "",
	"description": "",
	"url": "",
	"type": "content",
	"thumbnail": {"url": "${avatar_url}"},
	"footer": {"text": "${bot_name}", "icon_url": "${avatar_url}"},
	"fields": [
			{
				"name": "Alert Message",
				"value": "${alertbody}"
			},
			{
				"name": "Game",
				"value": "${gamename}"
			},
			{
				"name": "Server name",
				"value": "${servername}"
			},
			{
				"name": "Hostname",
				"value": "${HOSTNAME}"
			},
			{
				"name": "Server IP",
				"value": "[${shown_ip_address}:${shown_port}](https://www.gametracker.com/server_info/${shown_ip_address}:${shown_port})"
			},
			{
				"name": "More info",
				"value": "${alerturl}"
			}
		]
	}]
}
EOF
)

fn_print_dots "Sending Discord alert"
sleep 0.5
discordsend=$(${curlpath} -sSL -H "Content-Type: application/json" -X POST -d """${json}""" ${discordwebhook})

if [ -n "${discordsend}" ]; then
	fn_print_fail_nl "Sending Discord alert: ${discordsend}"
	fn_script_log_fatal "Sending Discord alert: ${discordsend}"
else
	fn_print_ok_nl "Sending Discord alert"
	fn_script_log_pass "Sending Discord alert"
fi
