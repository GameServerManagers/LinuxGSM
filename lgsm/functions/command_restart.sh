#!/bin/bash
# LinuxGSM command_restart.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Restarts the server.

local commandname="RESTART"
local commandaction="Restarting"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

info_config.sh
exitbypass=1
command_stop.sh
command_start.sh

core_exit.sh
