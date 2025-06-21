#!/bin/bash
# LinuxGSM install_complete.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Prints installation completion message and hints.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""

if [ "${exitcode}" -eq 1 ]; then
	echo -e "${bold}${red}Install Failed!${default}"
	fn_script_log_fail "Install Failed!"
elif [ "${exitcode}" -eq 2 ]; then
	echo -e "${bold}${red}Install Completed with Errors!${default}}"
	fn_script_log_error "Install Completed with Errors!"
elif [ "${exitcode}" -eq 3 ]; then
	echo -e "${bold}${lightyellow}Install Completed with Warnings!${default}}"
	fn_script_log_warn "Install Completed with Warnings!"
elif [ -z "${exitcode}" ] || [ "${exitcode}" -eq 0 ]; then
	echo -e "${bold}${green}Install Complete!${default}"
	fn_script_log_pass "Install Complete!"
fi
fn_messages_separator

echo -e ""
echo -e "To start the ${gamename} server type:"
echo -e "${italic}./${selfname} start${default}"
echo -e ""
core_exit.sh
