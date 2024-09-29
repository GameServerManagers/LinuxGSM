#!/bin/bash
# LinuxGSM alert_gotify.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Gotify alert.

module_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

jsoninfo=$(
	cat << EOF
{
	"title": "${alerttitle}",
	"message": "Server Name\n${servername}\n\nInformation\n${alertmessage}\n\nGame\n${gamename}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\nMore info\n${alerturl}\n\nServer Time\n$(date)",
	"priority": 5
}
EOF
)

jsonnoinfo=$(
	cat << EOF
{
	"title": "${alerttitle}",
	"message": "Server Name\n${servername}\n\nInformation\n${alertmessage}\n\nGame\n${gamename}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\nServer Time\n$(date)",
	"priority": 5
}
EOF
)

if [ -z "${alerturl}" ]; then
	json="${jsonnoinfo}"
else
	json="${jsoninfo}"
fi

fn_print_dots "Sending Gotify alert"
gotifysend=$(curl --connect-timeout 3 -sSL "${gotifywebhook}/message"?token="${gotifytoken}" -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)")

if [ -n "${gotifysend}" ]; then
	fn_print_ok_nl "Sending Gotify alert"
	fn_script_log_pass "Sending Gotify alert"
else
	fn_print_fail_nl "Sending Gotify alert: ${gotifysend}"
	fn_script_log_fail "Sending Gotify alert: ${gotifysend}"
fi
