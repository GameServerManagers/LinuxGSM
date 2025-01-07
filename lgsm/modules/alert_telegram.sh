#!/bin/bash
# LinuxGSM alert_telegram.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Telegram Messenger alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

json=$(
	cat << EOF
{
	"chat_id": "${telegramchatid}",
	"message_thread_id": "${telegramthreadid}",
	"parse_mode": "HTML",
	"disable_notification": "${telegramdisablenotification}",
	"text": "<b>${alerttitle}</b>\n\n<b>Server name</b>\n${servername}\n\n<b>Information</b>\n${alertmessage}\n\n<b>Game</b>\n${gamename}\n\n<b>Server IP</b>\n${alertip}:${port}\n\n<b>Hostname</b>\n${HOSTNAME}\n\n
EOF
)

if [ -n "${querytype}" ]; then
	json+=$(
		cat << EOF
<b>Is my Game Server Online?</b>\n<a href='https://ismygameserver.online/${imgsoquerytype}/${alertip}:${queryport}'>Check here</a>\n\n
EOF
	)
fi

if [ -n "${alerturl}" ]; then
	json+=$(
		cat << EOF
<b>More info</b>\n<a href='${alerturl}'>${alerturl}</a>\n\n
EOF
	)
fi

json+=$(
	cat << EOF
<b>Server Time</b>\n$(date)",
	"disable_web_page_preview": "yes"
}
EOF
)

fn_print_dots "Sending Telegram alert"
telegramsend=$(curl --connect-timeout 3 -sSL -H "Content-Type: application/json" -X POST -d "$(echo -n "${json}" | jq -c .)" ${curlcustomstring} "https://${telegramapi}/bot${telegramtoken}/sendMessage" | grep "error_code")

if [ -n "${telegramsend}" ]; then
	fn_print_fail_nl "Sending Telegram alert: ${telegramsend}"
	fn_script_log_fail "Sending Telegram alert: ${telegramsend}"
else
	fn_print_ok_nl "Sending Telegram alert"
	fn_script_log_pass "Sent Telegram alert"
fi
