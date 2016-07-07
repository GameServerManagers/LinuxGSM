#!/bin/bash
# LGSM command_start.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Starts the server.

local modulename="Restarting"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

exitbypass=1
info_config.sh
command_stop.sh
command_start.sh