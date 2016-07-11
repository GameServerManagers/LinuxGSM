#!/bin/bash
# LGSM command_start.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Starts the server.

local commandname="RESTART"
local commandaction="Restarting"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

info_config.sh
exitbypass=1
command_stop.sh
command_start.sh