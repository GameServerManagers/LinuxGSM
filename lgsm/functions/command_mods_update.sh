#!/bin/bash
# LGSM command_mods_update.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Updates installed mods along with mods_list.sh.

local commandname="MODS"
local commandaction="Mod Update"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
