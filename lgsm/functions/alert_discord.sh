#!/bin/bash
# LinuxGSM alert_discord.sh function
# Author: Daniel Gibbs
# Contributor: faflfama
# Website: https://gameservermanagers.com
# Description: Sends Discord alert including the server status.

json=$(cat <<EOF
{
"username":"LinuxGSM",
"avatar_url":"https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/images/logo/lgsm-dark-square-512.png",
"file":"content",

"embeds": [{
	"color": "2067276",
	"author": {"name": "${alertemoji} ${alertsubject} ${alertemoji}", "icon_url": "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/images/logo/lgsm-dark-square-512.png"},
	"title": "",
	"description": "",
	"url": "",
	"type": "content",
	"thumbnail": {"url": "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/images/logo/lgsm-dark-square-512.png"},
	"footer": {"text": "LinuxGSM", "icon_url": "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/images/logo/lgsm-dark-square-512.png"},
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
				"value": "[${ip}:${port}](https://www.gametracker.com/server_info/${ip}:${port})"
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

#curl -X POST --data "Content-Type: application/json" -X POST -d """${json}""" "${discordwebhook}"


echo "$json" >f
curl -v -X POST --data @f ${discordwebhook}
