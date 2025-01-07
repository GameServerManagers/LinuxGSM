#!/bin/bash
# LinuxGSM alert_pushbullet.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Pushbullet Messenger alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(
	cat << EOF
{
	"channel_tag": "${channeltag}",
	"type": "note",
	"title": "${alerttitle}",
	"body": "Server Name\n${servername}\n\nInformation\n${alertmessage}\n\nGame\n${gamename}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\n
EOF
)

if [ -n "${querytype}" ]; then
	json+=$(
		cat << EOF
Is my Game Server Online?\nhttps://ismygameserver.online/${imgsoquerytype}/${alertip}:${queryport}\n\n
EOF
	)
fi

if [ -n "${alerturl}" ]; then
	json+=$(
		cat << EOF
More info\n${alerturl}\n\n
EOF
	)
fi

json+=$(
	cat << EOF
Server Time\n$(date)"
}
EOF
)

fn_print_dots "Sending Pushbullet alert"
pushbulletsend=$(curl --connect-timeout 3 -sSL -H "Access-Token: ${pushbullettoken}" -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "https://api.pushbullet.com/v2/pushes" | grep "error_code")

if [ -n "${pushbulletsend}" ]; then
	fn_print_fail_nl "Sending Pushbullet alert: ${pushbulletsend}"
	fn_script_log_fail "Sending Pushbullet alert: ${pushbulletsend}"
else
	fn_print_ok_nl "Sending Pushbullet alert"
	fn_script_log_pass "Sent Pushbullet alert"
fi
