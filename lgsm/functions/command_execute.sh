#!/bin/bash
# LGSM command_execute.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Send message to server

local modulename="Execute"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

TMUX_BIN=tmux

check.sh

execute()
{
	$TMUX_BIN send -t ${servicename} "$*" "enter"
	echo "Command executed: '$*'"
}
