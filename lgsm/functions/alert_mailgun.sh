#!/bin/bash
# LinuxGSM alert_mailgun.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends Mailgun Email alert.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_print_dots "Sending Email (Mailgun) alert"
sleep 0.5
mailgunsend=$(curl -s --user "api:${mailguntoken}" -F from="LinuxGSM <${mailgunemailfrom}>" -F to="LinuxGSM Admin <${mailgunemail}>" -F subject="${alertemoji} ${alertsubject} ${alertemoji}" --form-string html="<br><br><b>Message</b><br>${alertbody}<br><br><b>Game</b><br>${gamename}<br><br><b>Server name</b><br>${servername}<br><br><b>Hostname</b><br>${HOSTNAME}<br><br><b>Server IP</b><br><a href='https://www.gametracker.com/server_info/${ip}:${port}'>${ip}:${port}</a><br><br><b>More info</b><br><a href='${alerturl}'>${alerturl}</a>" https://api.mailgun.net/v3/${mailgundomain}/messages)

if [ -z "${mailgunsend}" ]; then
	fn_print_fail_nl "Sending Email (Mailgun) alert"
	fn_script_log_fatal "Sending Email (Mailgun) alert"
else
	fn_print_ok_nl "Sending Email (Mailgun) alert"
	fn_script_log_pass "Sent Email (Mailgun) alert"
fi

