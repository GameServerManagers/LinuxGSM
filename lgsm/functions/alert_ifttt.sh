#!/bin/bash
# LinuxGSM alert_ifttt.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Sends IFTTT alert.

local modulename="ALERT"
local commandaction="Alert"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

json=$(cat <<EOF
{
	"value1": "${selfname}",
	"value2": "${alertsubject}",
	"value3": "Message\n${alertbody}\n\nGame\n${gamename}\n\nServer name\n${servername}\n\nHostname\n${HOSTNAME}\n\nServer IP\n${alertip}:${port}\n\nMore info\n${alerturl}"
}
EOF
)

fn_print_dots "Sending IFTTT alert"
iftttsend=$(curl -sSL -H "Content-Type: application/json" -X POST -d """${json}""" "https://maker.ifttt.com/trigger/${iftttevent}/with/key/${ifttttoken}" | grep "Bad Request")

if [ "${iftttsend}" ]; then
	fn_print_fail_nl "Sending IFTTT alert: ${pushbulletsend}"
	fn_script_log_fatal "Sending IFTTT alert: ${pushbulletsend}"
else
	fn_print_ok_nl "Sending IFTTT alert"
	fn_script_log_pass "Sent IFTTT alert"
fi
