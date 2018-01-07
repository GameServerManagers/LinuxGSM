#!/bin/bash
# LinuxGSM command_dev_gamedig.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Displays output of gamedig in json format.

local commandname="GAMEDIG"
local commandaction="Gamedig"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
