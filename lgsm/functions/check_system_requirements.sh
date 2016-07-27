#!/bin/bash
# LGSM check_system_requirements.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Checks RAM requirements

local commandname="CHECK"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

info_distro.sh

# RAM requirements in megabytes for each game or engine.
if [ "${gamename}" == "Rust" ]; then
	ramrequirementmb="4000"
	ramrequirementgb="4"
fi

# If the game or engine has a minimum RAM Requirement, compare it to system's available RAM.
if [ -n "${ramrequirement}" ]; then
	if [ "${physmemtotalmb}" -lt "${ramrequirementmb}" ]; then
		# Warn the user
		fn_print_warn "Insufficient memory: ${ramrequirementgb}G required, ${physmemtotal} available"
		sleep 1
		fn_print_warning "You may experiance poor performance from your server"
		sleep 1
	fi
fi
