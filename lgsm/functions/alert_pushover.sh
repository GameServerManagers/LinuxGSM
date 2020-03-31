#!/bin/bash
# LinuxGSM alert_pushover.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Sends Pushover alert.

local modulename="ALERT"
local commandaction="Alert"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_print_dots "Sending Pushover alert"

# Different alerts are given different priorities and notification sounds.
if [ "${alertsound}" == "1" ]; then
	alertsound=""
	alertpriority="0"
elif [ "${alertsound}" == "2" ]; then
	# restarted.
	alertsound="siren"
	alertpriority="1"
else
	alertsound=""
	alertpriority="0"
fi

pushoversend=$(curl -sS -F token="${pushovertoken}" -F user="${pushoveruserkey}" -F html="1" -F sound="${alertsound}"  -F priority="${alertpriority}" -F title="${alertemoji} ${alertsubject} ${alertemoji}" -F message=" <b>Message</b><br>${alertbody}<br><br><b>Game</b><br>${gamename}<br><br><b>Server name</b><br>${servername}<br><br><b>Hostname</b><br>${HOSTNAME}<br><br><b>Server IP</b><br><a href='https://www.gametracker.com/server_info/${alertip}:${port}'>${alertip}:${port}</a><br><br><b>More info</b><br><a href='${alerturl}'>${alerturl}</a>" "https://api.pushover.net/1/messages.json" | grep errors)

if [ "${pushoversend}" ]; then
	fn_print_fail_nl "Sending Pushover alert: ${pushoversend}"
	fn_script_log_fatal "Sending Pushover alert: ${pushoversend}"
else
	fn_print_ok_nl "Sending Pushover alert"
	fn_script_log_pass "Sent Pushover alert"
fi
