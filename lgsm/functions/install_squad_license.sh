#!/bin/bash
# LinuxGSM install_squad_license.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Configures the Squad server's license.

local modulename="INSTALL"
local commandaction="Install"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

echo -e ""
echo -e "${lightyellow}Squad Server License${default}"
echo -e "================================="
fn_sleep_time
echo -e "Server license is an optional feature for ${gamename} server"
fn_script_log_info "Server license is an optional feature for ${gamename} server"

echo -e "Get more info and a server license here:"
echo -e "http://forums.joinsquad.com/topic/16519-server-licensing-general-info/"
fn_script_log_info "Get more info and a server license here:"
fn_script_log_info "http://forums.joinsquad.com/topic/16519-server-licensing-general-info/"
echo -e ""
fn_sleep_time
echo -e "The Squad server license can be changed by editing ${servercfgdir}/License.cfg."
fn_script_log_info "The Squad server license can be changed by editing ${selfname}."
echo -e ""
