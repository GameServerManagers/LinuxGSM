#!/bin/bash
# LinuxGSM alert_rocketchat.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Rocketchat alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

jsoninfo=$(
	cat << EOF
{
	"alias": "LinuxGSM",
	"text": "*${alerttitle}*\nInformation\n${alertmessage}\nMore info: ${alerturl}",
	"attachments": [
		{
			"fields": [
				{
					"short": true,
					"title": "Game",
					"value": "${gamename}"
				},
				{
					"short": true,
					"title": "Server IP",
					"value": "${alertip}:${port}"
				},
				{
					"short": true,
					"title": "Hostname",
					"value": "${HOSTNAME}"
				}
			]
		}
	]
}
EOF
)

jsonnoinfo=$(
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
				}
			]
		}
	]
}
EOF
)

if [ -z "${alerturl}" ]; then
	json="${jsonnoinfo}"
else
	json="${jsoninfo}"
fi

fn_print_dots "Sending Rocketchat alert"
rocketchatsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${rocketchatwebhook}")

if [ -n "${rocketchatsend}" ]; then
	fn_print_ok_nl "Sending Rocketchat alert"
	fn_script_log_pass "Sending Rocketchat alert"
else
	fn_print_fail_nl "Sending Rocketchat alert: ${rocketchatsend}"
	fn_script_log_fail "Sending Rocketchat alert: ${rocketchatsend}"
fi
