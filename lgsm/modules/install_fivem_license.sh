#!/bin/bash
# LinuxGSM install_fivem_license.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Explains how to set the FiveM server license key.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}${gamename} License Key${default}"
fn_messages_separator
echo -e "A license key is required to run a ${gamename} server."
fn_script_log_info "A license key is required to run a ${gamename} server."

echo -e "Get a free license key here:"
echo -e "${italic}https://portal.cfx.re/servers/registration-keys${default}"
fn_script_log_info "Get a free license key here:"
fn_script_log_info "https://portal.cfx.re/servers/registration-keys"
echo -e ""
fn_sleep_time_1
echo -e "Set the license key with sv_licenseKey in ${servercfgfullpath}."
fn_script_log_info "Set the license key with sv_licenseKey in ${servercfgfullpath}."
echo -e ""
