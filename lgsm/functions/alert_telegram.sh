#!/bin/bash
# LinuxGSM alert_telegram.sh function
# Author: Bennet Becker <bennet@becker-dd.de>
# Website: https://bytegaming.de
# Description: Sends Telegram Message alert.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"


json=$(cat <<EOF
{
	"chat_id": "${telegramchatid}",
	"parse_mode": "HTML",
	"text": "${alertemoji} <b>${alertsubject}</b> ${alertemoji}\n<b>Message:</b> ${alertbody}\n<b>Server name:</b> ${servername}\n<b>Hostname:</b> ${HOSTNAME}\n<b>More info:</b> <a href='${alerturl}'>${alerturl}</a>",
	"disable_web_page_preview": "yes",
}
EOF
)

fn_print_dots "Sending Telegram Alert"
sleep 0.5
telegramsend=$(curl -sSL -H "Content-Type: application/json" -X POST -d """${json}""" "https://api.telegram.org/bot${telegramtoken}/sendMessage" | grep -Po '(?<="description":").*?(?=")'|uniq)

if [ -n "${telegramsend}" ]; then
	fn_print_fail_nl "Sending Telegram alert: ${telegramsend}"
	fn_script_log_fatal "Sending Telegram alert: ${telegramsend}"
else
	fn_print_ok_nl "Sending Telegram alert"
	fn_script_log_pass "Sent Telegram alert"
fi
