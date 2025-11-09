#!/bin/bash
# LinuxGSM alert_rocketchat.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Rocketchat alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(
	cat << EOF
{
	"alias": "LinuxGSM",
	"text": "*${alerttitle}*",
	"attachments": [
		{
			"title": "",
			"color": "${alertcolourhex}",
			"author_name": "LinuxGSM Alert",
			"author_link": "https://linuxgsm.com",
			"author_icon": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
			"thumb_url": "${alerticon}",
			"text": "",
			"fields": [
				{
					"short": false,
					"title": "Server Name",
					"value": "${servername}"
				},
				{
					"short": false,
					"title": "Information",
					"value": "${alertmessage}"
				},
				{
					"short": false,
					"title": "Game",
					"value": "${gamename}"
				},
				{
					"short": false,
					"title": "Server IP",
					"value": "${alertip}:${port}"
				},
				{
					"short": false,
					"title": "Hostname",
					"value": "${HOSTNAME}"
				},
				{
					"short": false,
					"title": "More info",
					"value": "${alerturl}"
				},
				{
					"short": false,
					"title": "Server Time",
					"value": "$(date)"
				}
			]
		}
	]
}
EOF
)

if [ -n "${querytype}" ]; then
	json+=$(
		cat << EOF
				{
					"short": false,
					"title": "Is my Game Server Online?",
					"value": "<https://ismygameserver.online/${imgsoquerytype}/${alertip}:${queryport}|Check here>"
				},
EOF
	)
fi

if [ -n "${alerturl}" ]; then
	json+=$(
		cat << EOF
				{
					"short": false,
					"title": "More info",
					"value": "${alerturl}"
				},
EOF
	)
fi

json+=$(
	cat << EOF
{
	"alias": "LinuxGSM",
	"text": "*${alerttitle}*",
	"attachments": [
		{
			"title": "",
			"color": "${alertcolourhex}",
			"author_name": "LinuxGSM Alert",
			"author_link": "https://linuxgsm.com",
			"author_icon": "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/alert_discord_logo.jpg",
			"thumb_url": "${alerticon}",
			"text": "",
			"fields": [
				{
					"short": false,
					"title": "Server Name",
					"value": "${servername}"
				},
				{
					"short": false,
					"title": "Information",
					"value": "${alertmessage}"
				},
				{
					"short": false,
					"title": "Game",
					"value": "${gamename}"
				},
				{
					"short": false,
					"title": "Server IP",
					"value": "${alertip}:${port}"
				},
				{
					"short": false,
					"title": "Hostname",
					"value": "${HOSTNAME}"
				},
				{
					"short": false,
					"title": "Server Time",
					"value": "$(date)"
				}
			]
		}
	]
}
EOF
)

fn_print_dots "Sending Rocketchat alert"
rocketchatsend=$(curl --connect-timeout 3 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${rocketchatwebhook}")

if [ -n "${rocketchatsend}" ]; then
	fn_print_ok_nl "Sending Rocketchat alert"
	fn_script_log_pass "Sending Rocketchat alert"
else
	fn_print_fail_nl "Sending Rocketchat alert: ${rocketchatsend}"
	fn_script_log_fail "Sending Rocketchat alert: ${rocketchatsend}"
fi
