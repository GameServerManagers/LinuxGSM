#!/bin/bash
# LinuxGSM check_status.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks the process status of the server. Either online or offline.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

status=$(tmux -L "${socketname}" list-sessions -F "#{session_name}" 2> /dev/null | grep -Ecx "^${sessionname}")
