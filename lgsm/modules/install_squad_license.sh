#!/bin/bash
# LinuxGSM install_squad_license.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Configures the Squad server's license.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}${gamename} Server License${default}"
fn_messages_separator
echo -e "Server license is an optional feature for ${gamename} server"
fn_script_log_info "Server license is an optional feature for ${gamename} server"

echo -e "Get more info and a server license here:"
echo -e "https://squad.fandom.com/wiki/Server_licensing"
fn_script_log_info "Get more info and a server license here:"
fn_script_log_info "https://squad.fandom.com/wiki/Server_licensing"
echo -e ""
fn_sleep_time_1
echo -e "The Squad server license can be changed by editing ${servercfgdir}/License.cfg."
fn_script_log_info "The Squad server license can be changed by editing ${selfname}."
echo -e ""
