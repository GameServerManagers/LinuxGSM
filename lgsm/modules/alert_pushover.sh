#!/bin/bash
# LinuxGSM alert_pushover.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Pushover alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

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

if [ -z "${alerturl}" ]; then
	pushoversend=$(curl --connect-timeout 3 -sS -F token="${pushovertoken}" -F user="${pushoveruserkey}" -F html="1" -F sound="${alertsound}" -F priority="${alertpriority}" -F title="${alerttitle}" -F message=" <b>Server name</b><br>${servername}<br><br><b>Information</b><br>${alertmessage}<br><br><b>Game</b><br>${gamename}<br><br><b>Server IP</b><br>${alertip}:${port}<br><br><b>Hostname</b><br>${HOSTNAME}<br><br>Server Time<br>$(date)" "https://api.pushover.net/1/messages.json" | grep errors)
else
	pushoversend=$(curl --connect-timeout 3 -sS -F token="${pushovertoken}" -F user="${pushoveruserkey}" -F html="1" -F sound="${alertsound}" -F priority="${alertpriority}" -F title="${alerttitle}" -F message=" <b>Server name</b><br>${servername}<br><br><b>Information</b><br>${alertmessage}<br><br><b>Game</b><br>${gamename}<br><br><b>Server IP</b><br>${alertip}:${port}<br><br><b>Hostname</b><br>${HOSTNAME}<br><br><b>More info</b><br><a href='${alerturl}'>${alerturl}</a><br><br>Server Time<br>$(date)" "https://api.pushover.net/1/messages.json" | grep errors)
fi

if [ -n "${pushoversend}" ]; then
	fn_print_fail_nl "Sending Pushover alert: ${pushoversend}"
	fn_script_log_fail "Sending Pushover alert: ${pushoversend}"
else
	fn_print_ok_nl "Sending Pushover alert"
	fn_script_log_pass "Sent Pushover alert"
fi
