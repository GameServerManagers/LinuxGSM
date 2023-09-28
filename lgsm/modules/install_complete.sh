#!/bin/bash
# LinuxGSM install_complete.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Prints installation completion message and hints.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}=================================${default}"

if [ "${exitcode}" == "1" ]; then
	echo -e "${red}Install Failed!${default}"
	fn_script_log_fatal "Install Failed!"
elif [ "${exitcode}" == "2" ]; then
	echo -e "${red}Install Completed with Errors!${default}}"
	fn_script_log_error "Install Completed with Errors!"
elif [ "${exitcode}" == "3" ]; then
	echo -e "${lightyellow}Install Completed with Warnings!${default}}"
	fn_script_log_warn "Install Completed with Warnings!"
elif [ -z "${exitcode}" ] || [ "${exitcode}" == "0" ]; then
	echo -e "${green}Install Complete!${default}"
	fn_script_log_pass "Install Complete!"
fi

echo -e ""
echo -e "To start the ${gamename} server type:"
echo -e "${italic}./${selfname} start${default}"
echo -e ""
core_exit.sh
