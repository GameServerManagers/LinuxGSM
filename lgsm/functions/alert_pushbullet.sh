#!/bin/bash
# LinuxGSM alert_pushbullet.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Pushbullet Messenger alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(cat <<EOF
{
	"channel_tag": "${channeltag}",
	"type": "note",
	"title": "${alertemoji} ${alerttitle} ${alertemoji}",
	"body": "Server name\n${servername}\n\nTrigger Message\n${alerttriggermessage}\n\nGame\n${gamename}\n\nCurrent Players\n${alertplayers}\n\nMap\n${alertmap}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\nVersion\n${alertversion}\n\nMore Info\n${alertmoreinfourl}"
}
EOF
)

fn_print_dots "Sending Pushbullet alert"
pushbulletsend=$(curl --connect-timeout 10 -sSL -H "Access-Token: ${pushbullettoken}" -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "https://api.pushbullet.com/v2/pushes" | grep "error_code")

if [ -n "${pushbulletsend}" ]; then
	fn_print_fail_nl "Sending Pushbullet alert: ${pushbulletsend}"
	fn_script_log_fatal "Sending Pushbullet alert: ${pushbulletsend}"
else
	fn_print_ok_nl "Sending Pushbullet alert"
	fn_script_log_pass "Sent Pushbullet alert"
fi
