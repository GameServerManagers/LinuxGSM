#!/bin/bash
# LinuxGSM alert_ntfy.sh module
# Author: Daniel Gibbs (Original Structure), rconjoe (ntfy Adaptation)
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Sends ntfy alert.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Default ntfy server if not set in config
if [ -z "${ntfyserver}" ]; then
	ntfyserver="https://ntfy.sh"
fi

# Construct the target URL
ntfyurl="${ntfyserver}/${ntfytopic}"

# Determine priority based on alertsound or config override
# ntfy priorities: 1 (min), 2 (low), 3 (default), 4 (high), 5 (max)
if [ -n "${ntfypriority}" ]; then
	priority="${ntfypriority}"
elif [ "${alertsound}" == "2" ]; then
	# High priority for monitor failures/permissions issues
	priority="4"
else
	# Default priority for standard notifications
	priority="3"
fi

# Determine tags based on alertemoji or config override
if [ -n "${ntfytags}" ]; then
	tags="${ntfytags}"
else
	# Use the alert emoji as a tag
	tags="${alertemoji}"
fi

# Construct the message body
message="Server Name: ${servername}
Information: ${alertmessage}
Game: ${gamename}
Server IP: ${alertip}:${port}
Hostname: ${HOSTNAME}
Server Time: $(date)"

# Add optional links if available
if [ -n "${querytype}" ]; then
	message+="\nIs my Game Server Online?: https://ismygameserver.online/${imgsoquerytype}/${alertip}:${queryport}"
fi

# Use alerturl for the click action if available
clickurl=""
if [ -n "${alerturl}" ]; then
	message+="\nMore info: ${alerturl}"
	clickurl="${alerturl}"
fi

# Prepare curl command
# Start with base command and add headers
cmd=(curl --connect-timeout 10 -sS -X POST)
cmd+=(-H "Title: ${alerttitle}")
cmd+=(-H "Priority: ${priority}")
cmd+=(-H "Tags: ${tags}")

# Add icon if available
if [ -n "${alerticon}" ]; then
	cmd+=(-H "Icon: ${alerticon}")
fi

# Add click URL if available
if [ -n "${clickurl}" ]; then
	cmd+=(-H "Click: ${clickurl}")
fi

# Add authentication header if token is provided
if [ -n "${ntfytoken}" ]; then
	cmd+=(-H "Authorization: Bearer ${ntfytoken}")
# Add basic auth if username/password provided (and token isn't)
elif [ -n "${ntfyusername}" ] && [ -n "${ntfypassword}" ]; then
	cmd+=(-u "${ntfyusername}:${ntfypassword}")
fi

# Add message body and target URL
cmd+=(-d "${message}" "${ntfyurl}")

fn_print_dots "Sending ntfy alert to ${ntfyurl}"

# Execute the command
ntfysend=$("${cmd[@]}")
exitcode=$?

# Check exit code and response
if [ "${exitcode}" -eq 0 ] && [[ "${ntfysend}" != *"\"code\":"* ]] && [[ "${ntfysend}" != *"401"* ]] && [[ "${ntfysend}" != *"404"* ]]; then
	fn_print_ok_nl "Sending ntfy alert to ${ntfyurl}"
	fn_script_log_pass "Sending ntfy alert to ${ntfyurl}"
else
	fn_print_fail_nl "Sending ntfy alert to ${ntfyurl}: ${ntfysend} (Exit code: ${exitcode})"
	fn_script_log_fail "Sending ntfy alert to ${ntfyurl}: ${ntfysend} (Exit code: ${exitcode})"
fi
