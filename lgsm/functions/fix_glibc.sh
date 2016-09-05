#!/bin/bash
# LGSM fix_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Downloads required Glibc files and applies the Glibc fix if required.

local commandname="FIX"
local commandaction="Fix"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

local libstdc_servers_array=( "ARMA 3" "Blade Symphony" "Garry's Mod" "GoldenEye: Source" "Just Cause 2" )
for libstdc_server in "${libstdc_servers_array[@]}"
do
	if [ "${gamename}" == "${libstdc_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libstdc++.so.6" "${lgsmdir}/lib" "noexecutecmd" "norun" "noforce" "nomd5"
	fi
done

local libm_servers_array=( "Black Mesa: Deathmatch" "Codename CURE" "Day of Infamy" "Double Action: Boogaloo" "Empires Mod" "Fistful of Frags" "Garry's Mod" "GoldenEye: Source" "Insurgency" "Natural Selection 2" "NS2: Combat" "No More Room in Hell" )
for libm_server in "${libm_servers_array[@]}"
do
	if [ "${gamename}" == "${libm_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libm.so.6" "${lgsmdir}/lib" "noexecutecmd" "norun" "noforce" "nomd5"
	fi
done

local libc_servers_array=( "Black Mesa: Deathmatch" "Blade Symphony" "Garry's Mod" "GoldenEye: Source" )
for libc_server in "${libc_servers_array[@]}"
do
	if [ "${gamename}" == "${libc_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libc.so.6" "${lgsmdir}/lib" "noexecutecmd" "norun" "noforce" "nomd5"
	fi
done

local libpthread_servers_array=( "Black Mesa: Deathmatch" "Blade Symphony" "Garry's Mod" )
for libpthread_server in "${libpthread_servers_array[@]}"
do
	if [ "${gamename}" == "${libpthread_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libpthread.so.0" "${lgsmdir}/lib" "noexecutecmd" "norun" "noforce" "nomd5"
	fi
done

export LD_LIBRARY_PATH=:"${libdir}"