#!/bin/bash
# LinuxGSM alert_telegram.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Telegram Messenger alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

jsoninfo=$(
	cat << EOF
{
	"chat_id": "${telegramchatid}",
	"message_thread_id": "${telegramthreadid}",
	"parse_mode": "HTML",
	"disable_notification": "${telegramdisablenotification}",
	"text": "<b>${alerttitle}</b>\n\n<b>Server name</b>\n${servername}\n\n<b>Information</b>\n${alertmessage}\n\n<b>Game</b>\n${gamename}\n\n<b>Server IP</b>\n${alertip}:${port}\n\n<b>Hostname</b>\n${HOSTNAME}\n\n<b>More info</b>\n<a href='${alerturl}'>${alerturl}</a>\n\n<b>Server Time</b>\n$(date)",
	"disable_web_page_preview": "yes"
}
EOF
)

jsonnoinfo=$(
	cat << EOF
{
	"chat_id": "${telegramchatid}",
	"message_thread_id": "${telegramthreadid}",
	"parse_mode": "HTML",
	"disable_notification": "${telegramdisablenotification}",
	"text": "<b>${alerttitle}</b>\n\n<b>Server name</b>\n${servername}\n\n<b>Information</b>\n${alertmessage}\n\n<b>Game</b>\n${gamename}\n\n<b>Server IP</b>\n${alertip}:${port}\n\n<b>Hostname</b>\n${HOSTNAME}\n\n<b>Server Time</b>\n$(date)",
	"disable_web_page_preview": "yes"
}
EOF
)

if [ -z "${alerturl}" ]; then
	json="${jsonnoinfo}"
else
	json="${jsoninfo}"
fi

fn_print_dots "Sending Telegram alert"
telegramsend=$(curl --connect-timeout 10 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" ${curlcustomstring} "https://${telegramapi}/bot${telegramtoken}/sendMessage" | grep "error_code")

if [ -n "${telegramsend}" ]; then
	fn_print_fail_nl "Sending Telegram alert: ${telegramsend}"
	fn_script_log_fail "Sending Telegram alert: ${telegramsend}"
else
	fn_print_ok_nl "Sending Telegram alert"
	fn_script_log_pass "Sent Telegram alert"
fi
