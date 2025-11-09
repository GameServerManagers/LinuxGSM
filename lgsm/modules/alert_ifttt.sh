#!/bin/bash
# LinuxGSM alert_ifttt.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends IFTTT alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(
	cat << EOF
{
	"value1": "${selfname}",
	"value2": "${alerttitle}",
	"value3": "Server Name\n${servername}\n\nInformation\n${alertmessage}\n\nGame\n${gamename}\n\nServer IP\n${alertip}:${port}\n\nHostname\n${HOSTNAME}\n\n
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

fn_print_dots "Sending IFTTT alert"
iftttsend=$(curl --connect-timeout 3 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "https://maker.ifttt.com/trigger/${iftttevent}/with/key/${ifttttoken}" | grep "Bad Request")

if [ -n "${iftttsend}" ]; then
	fn_print_fail_nl "Sending IFTTT alert: ${pushbulletsend}"
	fn_script_log_fail "Sending IFTTT alert: ${pushbulletsend}"
else
	fn_print_ok_nl "Sending IFTTT alert"
	fn_script_log_pass "Sent IFTTT alert"
fi
