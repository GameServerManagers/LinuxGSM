#!/bin/bash
# LGSM fn_check_tmux function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

# Checks if tmux is installed as too many users do not RTFM or know how to use Google.

if [ "$(command -v tmux)" ]||[ "$(which tmux >/dev/null 2>&1)" ]||[ -f "/usr/bin/tmux" ]||[ -f "/bin/tmux" ]; then
	:
else
	fn_printfailnl "Tmux not installed"
	sleep 1
	fn_scriptlog "Tmux is not installed"
	echo "	* Tmux is required to run this server."
	# Suitable passive agressive message
	echo "	* Please see the the following link."
	echo "	* http://gameservermanagers.com/tmux-not-found"
	exit 127
fi
