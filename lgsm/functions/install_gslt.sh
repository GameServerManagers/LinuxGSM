#!/usr/bin/env bash
# LinuxGSM install_gslt.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Configures GSLT.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo ""
echo "Game Server Login Token"
echo "================================="
fn_sleep_time
if [ "${shortname}" == "csgo" ]||[ "${shortname}" == "css" ]||[ "${shortname}" == "nmrih" ]||[ "${shortname}" == "bs" ]; then
	echo "GSLT is required to run a public ${gamename} server"
	fn_script_log_info "GSLT is required to run a public ${gamename} server"
else
	echo "GSLT is an optional feature for ${gamename} server"
	fn_script_log_info "GSLT is an optional feature for ${gamename} server"
fi

echo "Get more info and a token here:"
echo "https://linuxgsm.com/gslt"
fn_script_log_info "Get more info and a token here:"
fn_script_log_info "https://linuxgsm.com/gslt"
echo ""
if [ -z "${autoinstall}" ]; then
	if [ "${shortname}" != "tu" ]; then
		echo "Enter token below (Can be blank)."
		echo -n "GSLT TOKEN: "
		read -r token
		if ! grep -q "^gslt=" "${configdirserver}/${servicename}.cfg" > /dev/null 2>&1; then
			echo -e "\ngslt=\"${token}\"" >> "${configdirserver}/${servicename}.cfg"
		else
			sed -i -e "s/gslt=\"[^\"]*\"/gslt=\"${token}\"/g" "${configdirserver}/${servicename}.cfg"
		fi
	fi
fi
fn_sleep_time
if [ "${shortname}" == "tu" ]; then
	echo "The GSLT can be changed by editing ${servercfgdir}/${servercfg}."
	fn_script_log_info "The GSLT can be changed by editing ${servercfgdir}/${servercfg}."
else
	echo "The GSLT can be changed by editing ${configdirserver}/${servicename}.cfg."
	fn_script_log_info "The GSLT can be changed by editing ${configdirserver}/${servicename}.cfg."
fi
echo ""
