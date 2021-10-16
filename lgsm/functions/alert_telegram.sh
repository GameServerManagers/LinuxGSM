#!/bin/bash
# LinuxGSM alert_telegram.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Telegram Messenger alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(cat <<EOF
{
	"chat_id": "${telegramchatid}",
	"parse_mode": "HTML",
	"text": "<b>${alertemoji} ${alertsubject} ${alertemoji}</b>\<br><br><b>Server name</b><br>${servername}<br><br><b>Trigger Message</b><br>${alerttriggermessage}<br><br><b>Game</b><br>${gamename}<br><br><b>Current Players</b><br>${alertplayers}<br><br><b>Map</b><br>${alertmap}<br><br><b>Server IP</b><br>${alertip}:${port}<br><br><b>Hostname</b><br>${HOSTNAME}<br><br><b>Version</b><br>${alertversion}<br><br><b>More info</b><br>${alerturl}",
	"disable_web_page_preview": "yes"
}
EOF
)

fn_print_dots "Sending Telegram alert"
telegramsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" ${curlcustomstring} "https://${telegramapi}/bot${telegramtoken}/sendMessage" | grep "error_code")

if [ -n "${telegramsend}" ]; then
	fn_print_fail_nl "Sending Telegram alert: ${telegramsend}"
	fn_script_log_fatal "Sending Telegram alert: ${telegramsend}"
else
	fn_print_ok_nl "Sending Telegram alert"
	fn_script_log_pass "Sent Telegram alert"
fi
