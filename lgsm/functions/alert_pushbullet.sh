#!/bin/bash
# LGSM alert_pushbullet.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends Pushbullet alert including the server status.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_print_dots "Sending Pushbullet alert"
sleep 1

pushbulletsend=$(curl --silent -u """${pushbullettoken}"":" -d type="note" -d body="${alertbody}" -d title="${alertsubject}" 'https://api.pushbullet.com/v2/pushes'|grep -o invalid_access_token|uniq)

if [ "${pushbulletsend}" == "invalid_access_token" ]; then
	fn_print_fail_nl "Sending Pushbullet alert: invalid_access_token"
	fn_script_log_fatal "Sending Pushbullet alert: invalid_access_token"
else
	fn_print_ok_nl "Sending Pushbullet alert"
	fn_script_log_pass "Sent Pushbullet alert"
fi