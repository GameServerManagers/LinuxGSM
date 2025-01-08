#!/bin/bash
# LinuxGSM alert_discord.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Discord alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(
	cat << EOF
{
    "username": "LinuxGSM",
    "avatar_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
    "file": "content",
    "embeds": [
        {
            "author": {
                "name": "LinuxGSM Alert",
                "url": "",
                "icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
            },
            "title": "${alerttitle}",
            "url": "",
            "description": "",
            "color": "${alertcolourdec}",
            "type": "content",
            "thumbnail": {
                "url": "${alerticon}"
            },
            "fields": [
                {
                    "name": "Server Name",
                    "value": "${servername}"
                },
                {
                    "name": "Information",
                    "value": "${alertmessage}"
                },
                {
                    "name": "Game",
                    "value": "${gamename}",
                    "inline": true
                },
                {
                    "name": "Server Time",
                    "value": "$(date)",
                    "inline": true
                }
EOF
)

if [ -n "${querytype}" ]; then
	json+=$(
		cat << EOF
                ,
                {
                    "name": "Is my Game Server Online?",
                    "value": "https://ismygameserver.online/${imgsoquerytype}/${alertip}:${queryport}",
                    "inline": true
                }
EOF
	)
fi

json+=$(
	cat << EOF
            ],
            "footer": {
                "icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
                "text": "Sent by LinuxGSM ${version}"
            }
        }
    ]
}
EOF
)

fn_print_dots "Sending Discord alert"

discordsend=$(curl --connect-timeout 3 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${discordwebhook}")

if [ -n "${discordsend}" ]; then
	fn_print_fail_nl "Sending Discord alert: ${discordsend}"
	fn_script_log_fail "Sending Discord alert: ${discordsend}"
else
	fn_print_ok_nl "Sending Discord alert"
	fn_script_log_pass "Sending Discord alert"
fi
