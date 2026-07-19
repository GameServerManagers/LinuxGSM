#!/bin/bash
# LinuxGSM alert_flowtriq.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Flowtriq alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(
	cat << EOF
{
	"server_name": "${servername}",
	"alert_type": "${alertaction}",
	"game": "${gamename}",
	"message": "${alertmessage}",
	"server_ip": "${alertip}",
	"server_port": "${port}",
	"timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
EOF
)

if [ -n "${querytype}" ]; then
	json+=$(
		cat << EOF
	,
	"query_port": "${queryport}"
EOF
	)
fi

json+=$(
	cat << EOF

}
EOF
)

fn_print_dots "Sending Flowtriq alert"

flowtriqsend=$(curl --connect-timeout 3 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" "${flowtriqwebhook}")

if [ $? -eq 0 ] && [ -n "${flowtriqsend}" ]; then
	fn_print_ok_nl "Sending Flowtriq alert"
	fn_script_log_pass "Sending Flowtriq alert"
else
	fn_print_fail_nl "Sending Flowtriq alert: ${flowtriqsend}"
	fn_script_log_fail "Sending Flowtriq alert: ${flowtriqsend}"
fi
