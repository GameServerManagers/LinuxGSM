#!/bin/bash
# LGSM fix_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Downloads required glibc files and applys teh glibc fix if required

local commandnane="FIX"
local commandaction="Fix"
local selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

local libstdc_servers_array=( "ARMA 3" "Blade Symphony" "Garry's Mod" "Just Cause 2" )
for libstdc_server in "${libstdc_servers_array[@]}"
do
	if [ "${gamename}" == "${libstdc_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libstdc++.so.6" "${lgsmdir}/lib" "noexecutecmd" "norun" "noforce" "nomd5"
	fi
done

local libm_servers_array=( "Double Action: Boogaloo" "Fistful of Frags" "Insurgency" "Natural Selection 2" "NS2: Combat" "No More Room in Hell" )
for libm_server in "${libm_servers_array[@]}"
do
	if [ "${gamename}" == "${libm_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libm.so.6" "${lgsmdir}/lib" "noexecutecmd" "norun" "noforce" "nomd5"
	fi
done

export LD_LIBRARY_PATH=:"${libdir}"