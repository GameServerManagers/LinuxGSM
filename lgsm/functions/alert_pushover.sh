#!/bin/bash
# LinuxGSM alert_pushover.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Pushover alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

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

pushoversend=$(curl --connect-timeout 10 -sS -F token="${pushovertoken}" -F user="${pushoveruserkey}" -F html="1" -F sound="${alertsound}"  -F priority="${alertpriority}" -F title="${alertemoji} ${alerttitle} ${alertemoji}" -F message="Server name<br>${servername}<br><br>Trigger Message<br>${alerttriggermessage}<br><br>Game<br>${gamename}<br><br>Current Players<br>${alertplayers}<br><br>Map<br>${alertmap}<br><br>Server IP<br>${alertip}:${port}<br><br>Hostname<br>${HOSTNAME}<br><br>Version<br>${alertversion}<br><br>More info<br>${alerturl}" "https://api.pushover.net/1/messages.json" | grep errors)

if [ -n "${pushoversend}" ]; then
	fn_print_fail_nl "Sending Pushover alert: ${pushoversend}"
	fn_script_log_fatal "Sending Pushover alert: ${pushoversend}"
else
	fn_print_ok_nl "Sending Pushover alert"
	fn_script_log_pass "Sent Pushover alert"
fi
