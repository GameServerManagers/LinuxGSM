#!/bin/bash
# LinuxGSM install_complete.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Prints installation completion message and hints.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "================================="

if [ "${exitcode}" == "1" ]; then
	echo -e "Install Failed!"
	fn_script_log_fatal "Install Failed!"
elif [ "${exitcode}" == "2" ]; then
	echo -e "Install Completed with Errors!"
	fn_script_log_error "Install Completed with Errors!"
elif [ "${exitcode}" == "3" ]; then
	echo -e "Install Completed with Warnings!"
	fn_script_log_warn "Install Completed with Warnings!"
elif [ -z "${exitcode}" ] || [ "${exitcode}" == "0" ]; then
	echo -e "Install Complete!"
	fn_script_log_pass "Install Complete!"
fi

fn_script_log_info "Install Complete!"
echo -e ""
echo -e "To start server type:"
echo -e "./${selfname} start"
echo -e ""
core_exit.sh
