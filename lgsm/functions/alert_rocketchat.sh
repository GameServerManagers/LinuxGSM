#!/bin/bash
# LinuxGSM alert_rocketchat.sh function
# Author: Alasdair Haig
# Website: https://linuxgsm.com
# Description: Sends Rocketchat alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if ! command -v jq > /dev/null; then
	fn_print_fail_nl "Sending Rocketchat alert: jq is missing."
	fn_script_log_fatal "Sending Rocketchat alert: jq is missing."
fi

json=$(cat <<EOF
{
   "alias":"Yggdragsil",
   "text":"* ${alertemoji} ${alertsubject}* + \n ${alertbody}",
   "attachments":[
      {
         "title":"Linuxgsm Alert",
         "text":"Hostname: ${HOSTNAME}",
         "color":"#36a64f",
         "fields":[
            {
               "short":true,
               "title":"Game:",
               "value":"${gamename}"
            },
            {
               "short":true,
               "title":"Server IP:",
               "value":"${alertip}:${port}"
            },
            {
               "short":true,
               "title":"Server Name:",
               "value":"${servername}"
            }
         ]
      }
   ]
}
EOF
)

fn_print_dots "Sending Rocketchat alert"

rocketlaunch=$(curl -sSL -H "Content-Type:application/json" -X POST -d "$(echo -n "$json" | jq -c .)" "${rocketchatwebhook}")

if [ "${rocketlaunch}" == "ok" ]; then
	fn_print_ok_nl "Sending Rocketchat alert"
	fn_script_log_pass "Sending Rocketchat alert"
else
    fn_print_fail_nl "Sending Rocketchat alert: ${rocketlaunch}"
	fn_script_log_fatal "Sending Rocketchat alert: ${rocketlaunch}"
fi
