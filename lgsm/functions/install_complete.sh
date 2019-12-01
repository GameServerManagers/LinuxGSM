#!/bin/bash
# LinuxGSM install_complete.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Prints installation completion message and hints.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

echo -e ""
echo -e "================================="
echo -e "Install Complete!"
fn_script_log_info "Install Complete!"
echo -e ""
echo -e "To start server type:"
echo -e "./${selfname} start"
echo -e ""
core_exit.sh
