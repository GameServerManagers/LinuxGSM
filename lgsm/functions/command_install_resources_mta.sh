#!/bin/bash
# LinuxGSM command_install_resources_mta.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Installs the default resources for Multi Theft Auto.

local commandname="DEFAULT_RESOURCES"
local commandaction="Default Resources"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_resources(){
	echo ""
	echo "Installing Default Resources"
	echo "================================="
	fn_fetch_file "http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip" "${tmpdir}" "mtasa-resources-latest.zip" "nochmodx" "norun" "noforce" "nomd5"
	fn_dl_extract "${tmpdir}" "mtasa-resources-latest.zip" "${resourcesdir}"
	echo "Default Resources Installed."
}

fn_print_header

fn_print_warning_nl "Installing the default resources with existing resources may cause issues."
if [[ -z ${autoinstall} ]]; then
	if fn_prompt_yn "Do you want to install MTA default resources?" Y; then
		fn_install_resources
	fi
else
	echo "Installing MTA default resources..."
fi
