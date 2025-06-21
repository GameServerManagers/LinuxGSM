#!/bin/bash
# LinuxGSM alert_gotify.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Gotify alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(
	cat << EOF
{
	"title": "${alerttitle}",
	"message": "Server Name\n${servername}\n\nInformation\n${alertmessage}\n\nGame\n${gamename}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\n
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
Server Time\n$(date)",
	"priority": 5
}
EOF
)

fn_print_dots "Sending Gotify alert"
gotifysend=$(curl --connect-timeout 3 -sSL "${gotifywebhook}/message"?token="${gotifytoken}" -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)")

if [ -n "${gotifysend}" ]; then
	fn_print_ok_nl "Sending Gotify alert"
	fn_script_log_pass "Sending Gotify alert"
else
	fn_print_fail_nl "Sending Gotify alert: ${gotifysend}"
	fn_script_log_fail "Sending Gotify alert: ${gotifysend}"
fi
