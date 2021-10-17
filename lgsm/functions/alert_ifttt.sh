#!/bin/bash
# LinuxGSM alert_ifttt.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends IFTTT alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(cat <<EOF
{
	"value1": "${selfname}",
	"value2": "${alertemoji} ${alerttitle} ${alertemoji}",
	"value3": "<b>Server name</b><br>${servername}<br><br><b>Trigger Message</b><br>${alerttriggermessage}<br><br><b>Game</b><br>${gamename}<br><br><b>Map</b><br>${alertmap}<br><br><b>Current Players</b><br>${alertplayers}<br><br><b>Version</b><br>${alertversion}<br><br><b>Country</b><br>${country}<br><br><b>Server IP</b><br>${alertip}:${port}<br><br><b>Hostname</b><br>${HOSTNAME}<br><br><b>More Info</b><br>${alertmoreinfourl}"
}
EOF
)

fn_print_dots "Sending IFTTT alert"
iftttsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "https://maker.ifttt.com/trigger/${iftttevent}/with/key/${ifttttoken}" | grep "Bad Request")

if [ -n "${iftttsend}" ]; then
	fn_print_fail_nl "Sending IFTTT alert: ${pushbulletsend}"
	fn_script_log_fatal "Sending IFTTT alert: ${pushbulletsend}"
else
	fn_print_ok_nl "Sending IFTTT alert"
	fn_script_log_pass "Sent IFTTT alert"
fi
