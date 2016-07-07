#!/bin/bash
# LGSM dev_debug.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Dev only: enables debuging log to be saved to dev-debug.log.

local modulename="Dev Debug"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"


if [ -f ".dev-debug" ]; then
	rm .dev-debug
	fn_print_ok_nl "Disabled dev-debug"
	fn_script_log_info "Disabled dev-debug"
else
	date > .dev-debug
	fn_print_ok_nl "Enabled dev-debug"
	fn_script_log_info "Enabled dev-debug"
fi
core_exit.sh