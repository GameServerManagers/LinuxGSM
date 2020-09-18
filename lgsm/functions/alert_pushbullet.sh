#!/bin/bash
# LinuxGSM alert_pushbullet.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Sends Pushbullet Messenger alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(cat <<EOF
{
	"channel_tag": "${channeltag}",
	"type": "note",
	"title": "${alertemoji} ${alertsubject} ${alertemoji}",
	"body": "Server name\n${servername}\n\nMessage\n${alertbody}\n\nGame\n${gamename}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\nMore info\n${alerturl}"
}
EOF
)

fn_print_dots "Sending Pushbullet alert"
pushbulletsend=$(curl -sSL -u """${pushbullettoken}"":" -H "Content-Type: application/json" -X POST -d """${json}""" "https://api.pushbullet.com/v2/pushes" | grep "error_code")

if [ "${pushbulletsend}" ]; then
	fn_print_fail_nl "Sending Pushbullet alert: ${pushbulletsend}"
	fn_script_log_fatal "Sending Pushbullet alert: ${pushbulletsend}"
else
	fn_print_ok_nl "Sending Pushbullet alert"
	fn_script_log_pass "Sent Pushbullet alert"
fi
