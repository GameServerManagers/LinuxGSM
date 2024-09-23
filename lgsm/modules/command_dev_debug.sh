#!/bin/bash
# LinuxGSM command_dev_debug.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Dev only: Enables debugging log to be saved to dev-debug.log.

commandname="DEV-DEBUG"
commandaction="Developer debug"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_reset

fn_print_dots ""
check.sh
core_logs.sh

if [ -f "${rootdir}/.dev-debug" ]; then
	rm -f "${rootdir:?}/.dev-debug"
	fn_print_ok_nl "Disabled dev-debug"
	fn_script_log_info "Disabled dev-debug"
else
	date '+%s' > "${rootdir}/.dev-debug"
	fn_print_ok_nl "Enabled dev-debug"
	fn_script_log_info "Enabled dev-debug"
fi

core_exit.sh
