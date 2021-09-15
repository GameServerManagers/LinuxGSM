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
	"value2": "${alertemoji} ${alertsubject} ${alertemoji}",
	"value3": "Server name\n${servername}\n\nInformation\n${alertdescription}\n\nGame\n${gamename}\n\n${alertplayerstitle}\n${alertplayers}\n\nMap\n${alertmap}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\nMore info\n${alerturl}"
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
