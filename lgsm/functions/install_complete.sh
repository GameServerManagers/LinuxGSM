#!/bin/bash
# LinuxGSM install_complete.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
# Description: Prints installation completion message and hints.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "================================="
echo -e "Install Complete!"
fn_script_log_info "Install Complete!"
echo -e ""
echo -e "To start server type:"
echo -e "./${selfname} start"
echo -e ""
core_exit.sh
