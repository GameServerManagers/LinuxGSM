#!/bin/bash
# LinuxGSM install_complete.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Prints installation completion message and hints.

commandname="INSTALL"
commandaction="Install"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo "================================="
echo "Install Complete!"
fn_script_log_info "Install Complete!"
echo ""
echo "To start server type:"
echo "./${selfname} start"
echo ""
core_exit.sh