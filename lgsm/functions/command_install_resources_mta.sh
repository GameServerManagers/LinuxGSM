#!/bin/bash
# LinuxGSM command_install_resources_mta.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Installs the default resources for Multi Theft Auto.

local commandname="DEFAULT_RESOURCES"
local commandaction="Default Resources"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_install_resources(){
	echo ""
	echo "Installing Default Resources"
	echo "================================="
	fileurl="http://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip"; filedir="${tmpdir}"; filename="multitheftauto_resources.zip"; executecmd="noexecute" run="norun"; force="noforce"; md5="nomd5"
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
	fn_dl_extract "${filedir}" "${filename}" "${resourcesdir}"
	echo "Default Resources Installed."
}

fn_print_header

fn_print_warning_nl "Installing the default resources with existing resources may cause issues."
if fn_prompt_yn "Do you want to install MTA default resources?" Y; then
	fn_install_resources
fi
