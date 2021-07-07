#!/bin/bash
# LinuxGSM alert_gotify.sh module
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends Gotify alert.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

content=(message="${alertsubject}, ${servername}, ${alertbody}. More info: ${alerturl}")

fn_print_dots "Sending Gotify alert"

gotifysend=$(curl --connect-timeout 10 -sSL "$gotifywebhook"?token="$gotifytoken" -F "title=LinuxGSM" -F "$content" -F "priority=5")

if [ -n "${gotifysend}" ]; then
	fn_print_ok_nl "Sending Gotify alert"
	fn_script_log_pass "Sending Gotify alert"
else
	fn_print_fail_nl "Sending Gotify alert: ${gotifysend}"
	fn_script_log_fatal "Sending Gotify alert: ${gotifysend}"
fi
