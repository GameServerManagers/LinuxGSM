#!/bin/bash
# LinuxGSM alert_matrix.sh module
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Matrix alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(cat <<EOF
{
  "msgtype":"m.notice", 
  "body":"**${alertemoji} ${alertsubject} ${alertemoji}**\n\n**Server name**\n${servername}\n\n**Message**\n${alertbody}\n\n**Game**\n${gamename}\n\n**Server IP**\n[${alertip}:${port}](https://www.gametracker.com/server_info/${alertip}:${port})\n\n**Hostname**\n${HOSTNAME}\n\n**More info**\n[${alerturl}](${alerturl})", 
  "format": "org.matrix.custom.html", 
  "formatted_body": "<p><b>${alertemoji} ${alertsubject} ${alertemoji}</b></p>\n<p><b>Server name</b></p><p>${servername}</p>\n<p><b>Message</b></p><p>${alertbody}</p>\n<p><b>Game</b></p><p>${gamename}</p>\n<p><b>Server IP</b></p><p><a href=\'https://www.gametracker.com/server_info/${alertip}:${port}\'>${alertip}:${port}</a></p>\n<p><b>Hostname</b></p><p>${HOSTNAME}</p>\n<p><b>More info</b></p><a href=\'${alerturl}\'>${alerturl}</a>"
}
EOF
)

fn_print_dots "Sending Matrix alert"
matrixsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d """${json}""" "https://${matrixhomeserver}/_matrix/client/r0/rooms/${matrixroom}/send/m.room.message?access_token=${matrixtoken}" | grep "error")


if [ -n "${matrixsend}" ]; then
	fn_print_fail_nl "Sending Matrix alert: ${matrixsend}"
	fn_script_log_fatal "Sending Matrix alert: ${matrixsend}"
else
	fn_print_ok_nl "Sending Matrix alert"
	fn_script_log_pass "Sent Matrix alert"
fi
