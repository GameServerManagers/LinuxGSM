#!/bin/bash
# LGSM install_complete.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Prints installation completion message and hints.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ "${gamename}" == "Don't Starve Together" ]; then
  echo ""
  echo "An Authentication Token is required to run this server!"
  echo "Follow the instructions in this link to obtain this key"
  echo "  https://gameservermanagers.com/dst-auth-token"
fi
echo "================================="
echo "Install Complete!"
fn_script_log_info "Install Complete!"
echo ""
echo "To start server type:"
echo "./${selfname} start"
echo ""
core_exit.sh