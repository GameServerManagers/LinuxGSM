#!/bin/bash
# LinuxGSM install_gslt.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Configures GSLT.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo -e ""
echo -e "${bold}${lightyellow}Game Server Login Token${default}"
fn_messages_separator
if [ "${shortname}" == "csgo" ] || [ "${shortname}" == "css" ] || [ "${shortname}" == "nmrih" ] || [ "${shortname}" == "bs" ]; then
	echo -e "GSLT is required to run a public ${gamename} server"
	fn_script_log_info "GSLT is required to run a public ${gamename} server"
else
	echo -e "GSLT is an optional feature for ${gamename} server"
	fn_script_log_info "GSLT is an optional feature for ${gamename} server"
fi

echo -e "Get more info and a token here:"
echo -e "https://docs.linuxgsm.com/steamcmd/gslt"
fn_script_log_info "Get more info and a token here:"
fn_script_log_info "https://docs.linuxgsm.com/steamcmd/gslt"
echo -e ""
if [ -z "${autoinstall}" ]; then
	if [ "${shortname}" != "tu" ]; then
		echo -e "Enter token below (Can be blank)."
		echo -n "GSLT TOKEN: "
		read -r token
		if ! grep -q "^gslt=" "${configdirserver}/${selfname}.cfg" > /dev/null 2>&1; then
			echo -e "\ngslt=\"${token}\"" >> "${configdirserver}/${selfname}.cfg"
		else
			sed -i -e "s/gslt=\"[^\"]*\"/gslt=\"${token}\"/g" "${configdirserver}/${selfname}.cfg"
		fi
	fi
fi

if [ "${shortname}" == "tu" ]; then
	echo -e "The GSLT can be changed by editing ${servercfgdir}/${servercfg}."
	fn_script_log_info "The GSLT can be changed by editing ${servercfgdir}/${servercfg}."
else
	echo -e "The GSLT can be changed by editing ${configdirserver}/${selfname}.cfg."
	fn_script_log_info "The GSLT can be changed by editing ${configdirserver}/${selfname}.cfg."
fi
fn_sleep_time_1
echo -e ""
