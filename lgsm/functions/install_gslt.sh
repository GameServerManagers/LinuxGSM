#!/bin/bash
# LGSM install_gslt.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Configures GSLT.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

echo ""
echo "Game Server Login Token"
echo "================================="
sleep 1
if [ "${gamename}" == "Counter-Strike: Global Offensive" ]||[ "${gamename}" == "Counter-Strike: Source" ]; then
	echo "GSLT is required to run a public ${gamename} server"
	fn_script_log_info "GSLT is required to run a public ${gamename} server"
else
	echo "GSLT is an optional feature for ${gamename} server"
	fn_script_log_info "GSLT is an optional feature for ${gamename} server"
fi

echo "Get more info and a token here:"
echo "https://gameservermanagers.com/gslt"
fn_script_log_info "Get more info and a token here:"
fn_script_log_info "https://gameservermanagers.com/gslt"
echo ""
if [ -z "${autoinstall}" ]; then
	echo "Enter token below (Can be blank)."
	echo -n "GSLT TOKEN: "
	read token
	sed -i -e "s/gslt=\"\"/gslt=\"${token}\"/g" "${rootdir}/${selfname}"
fi
sleep 1
echo "The GSLT can be changed by editing ${selfname}."
fn_script_log_info "The GSLT can be changed by editing ${selfname}."
echo ""