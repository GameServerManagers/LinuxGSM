#!/bin/bash
# LinuxGSM alert_pushbullet.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Sends Pushbullet alert including the server status.

local commandname="ALERT"
local commandaction="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# converts text to ascii then passes to curl. allowing special characters to be sent e.g %
# http://stackoverflow.com/a/10660730
fn_rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # If echo is faster, let's just echo it.
}

pbalertbody=$(fn_rawurlencode "${alertbody}")
pbalertsubject=$(fn_rawurlencode "${alertsubject}")

fn_print_dots "Sending Pushbullet alert"
sleep 1
pushbulletsend=$(curl --silent -u """${pushbullettoken}"":" -d channel_tag="${channeltag}" -d type="note" -d body="${pbalertbody}" -d title="${pbalertsubject}" 'https://api.pushbullet.com/v2/pushes'|grep -o invalid_access_token|uniq)

if [ "${pushbulletsend}" == "invalid_access_token" ]; then
	fn_print_fail_nl "Sending Pushbullet alert: invalid_access_token"
	fn_script_log_fatal "Sending Pushbullet alert: invalid_access_token"
else
	fn_print_ok_nl "Sending Pushbullet alert"
	fn_script_log_pass "Sent Pushbullet alert"
fi