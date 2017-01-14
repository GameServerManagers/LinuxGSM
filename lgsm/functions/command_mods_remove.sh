#!/bin/bash
# LGSM command_mods_uninstall.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Uninstall mods along with mods_list.sh.

local commandname="MODS"
local commandaction="Mod Remove"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
