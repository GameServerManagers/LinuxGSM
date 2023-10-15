#!/bin/bash
# LinuxGSM alert_discord.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Discord alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

jsonshortinfo=$(
	cat << EOF
{
    "username": "LinuxGSM",
    "avatar_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
    "file": "content",
    "embeds": [
        {
            "author": {
                "name": "${alertemoji} ${alertsubject} ${alertemoji}",
                "url": "",
                "icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
            },
            "title": "${servername}",
            "url": "",
            "description": "${alertbody} \n More info: ${alerturl}",
            "color": "${alertcolourdec}",
            "type": "content",
            "thumbnail": {
                "url": "${alerticon}"
            },
            "fields": [
                {
                    "name": "Game",
                    "value": "${gamename}",
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
                }
            ],
            "footer": {
                "text": "Sent by LinuxGSM ${version}"
            }
        }
    ]
}
EOF
)

jsonshortnoinfo=$(
	cat << EOF
{
    "username": "LinuxGSM",
    "avatar_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
    "file": "content",
    "embeds": [
        {
            "author": {
                "name": "${alertemoji} ${alertsubject} ${alertemoji}",
                "url": "",
                "icon_url": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg"
            },
            "title": "${servername}",
            "url": "",
            "description": "${alertbody}",
            "color": "${alertcolourdec}",
            "type": "content",
            "thumbnail": {
                "url": "${alerticon}"
            },
            "fields": [
                {
                    "name": "Game",
                    "value": "${gamename}",
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
                }
            ],
            "footer": {
                "text": "Sent by LinuxGSM ${version}"
            }
        }
    ]
}
EOF
)

fn_print_dots "Sending Discord alert"

if [ "${alerturl}" == "not enabled" ]; then
	json="${jsonshortnoinfo}"
else
	json="${jsonshortinfo}"
fi

discordsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${discordwebhook}")

if [ -n "${discordsend}" ]; then
	fn_print_fail_nl "Sending Discord alert: ${discordsend}"
	fn_script_log_fail "Sending Discord alert: ${discordsend}"
else
	fn_print_ok_nl "Sending Discord alert"
	fn_script_log_pass "Sending Discord alert"
fi
