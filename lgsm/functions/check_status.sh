#!/bin/bash
# LinuxGSM check_status.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Checks the process status of the server. Either online or offline.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

status=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -Ecx "^${sessionname}")
