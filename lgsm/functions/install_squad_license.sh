#!/bin/bash
# LinuxGSM install_squad_license.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Configures the Squad server's license.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo ""
echo "Squad Server License"
echo "================================="
sleep 1
echo "Server license is an optional feature for ${gamename} server"
fn_script_log_info "Server license is an optional feature for ${gamename} server"

echo "Get more info and a server license here:"
echo "http://forums.joinsquad.com/topic/16519-server-licensing-general-info/"
fn_script_log_info "Get more info and a server license here:"
fn_script_log_info "http://forums.joinsquad.com/topic/16519-server-licensing-general-info/"
echo ""
sleep 1
echo "The Squad server license can be changed by editing ${servercfgdir}/License.cfg."
fn_script_log_info "The Squad server license can be changed by editing ${selfname}."
echo ""