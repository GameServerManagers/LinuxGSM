#!/bin/bash
# LGSM check_tmux.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Checks if tmux is installed as too many users do not RTFM or know how to use Google.

if [ "$(command -v tmux)" ]||[ "$(which tmux >/dev/null 2>&1)" ]||[ -f "/usr/bin/tmux" ]||[ -f "/bin/tmux" ]; then
	:
else
	fn_print_fail_nl "Tmux not installed"
	sleep 1
	fn_script_log_fatal "Tmux is not installed"
	echo "	* Tmux is required to run this server."
	# Suitable passive agressive message
	echo "	* Please see the the following link."
	echo "	* https://gameservermanagers.com/tmux-not-found"
	core_exit.sh
fi
