#!/bin/bash
# LGSM command_start.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Starts the server.

local modulename="Restarting"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

exitbypass=1
info_config.sh
command_stop.sh
command_start.sh