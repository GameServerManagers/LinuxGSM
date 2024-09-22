#!/bin/bash
# LinuxGSM install_complete.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Prints installation completion message and hints.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
fn_messages_separator

if [ "${exitcode}" == "1" ]; then
	echo -e "${bold}${red}Install Failed!${default}"
	fn_script_log_fail "Install Failed!"
elif [ "${exitcode}" == "2" ]; then
	echo -e "${bold}${red}Install Completed with Errors!${default}}"
	fn_script_log_error "Install Completed with Errors!"
elif [ "${exitcode}" == "3" ]; then
	echo -e "${bold}${lightyellow}Install Completed with Warnings!${default}}"
	fn_script_log_warn "Install Completed with Warnings!"
elif [ -z "${exitcode}" ] || [ "${exitcode}" == "0" ]; then
	echo -e "${bold}${green}Install Complete!${default}"
	fn_script_log_pass "Install Complete!"
fi

fn_script_log_info "Install Complete!"
echo -e ""
echo -e "To start server type:"
echo -e "./${selfname} start"
echo -e ""
core_exit.sh
