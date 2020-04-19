#!/bin/bash
# LinuxGSM command_dev_debug.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Dev only: Enables debugging log to be saved to dev-debug.log.

local modulename="DEV-DEBUG"
local commandaction="Dev Debug"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ -f "${rootdir}/.dev-debug" ]; then
	rm "${rootdir:?}/.dev-debug"
	fn_print_ok_nl "Disabled dev-debug"
	fn_script_log_info "Disabled dev-debug"
else
	date '+%s' > "${rootdir}/.dev-debug"
	fn_print_ok_nl "Enabled dev-debug"
	fn_script_log_info "Enabled dev-debug"
fi

core_exit.sh
