#!/bin/bash
# LinuxGSM fix_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Downloads required Glibc files and applies the Glibc fix if required.

commandname="FIX"
commandaction="Fix"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

## i386

# libstdc++.so.6
local libstdc_servers_array=( "ARMA 3" "Blade Symphony" "Counter-Strike: Global Offensive" "Garry's Mod" "GoldenEye: Source" "Just Cause 2" "Team Fortress 2" )
for libstdc_server in "${libstdc_servers_array[@]}"
do
	if [ "${gamename}" == "${libstdc_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libstdc++.so.6" "${lgsmdir}/lib" "nochmodx" "norun" "noforce" "nomd5"
	fi
done

# libm.so.6
local libm_servers_array=( "Black Mesa: Deathmatch" "Codename CURE" "Day of Infamy" "Double Action: Boogaloo" "Empires Mod" "Fistful of Frags" "Garry's Mod" "GoldenEye: Source" "Insurgency" "Natural Selection 2" "NS2: Combat" "No More Room in Hell" "Pirates, Vikings, and Knights II" "Team Fortress 2" )
for libm_server in "${libm_servers_array[@]}"
do
	if [ "${gamename}" == "${libm_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libm.so.6" "${lgsmdir}/lib" "nochmodx" "norun" "noforce" "nomd5"
	fi
done

# libc.so.6
local libc_servers_array=( "Black Mesa: Deathmatch" "Blade Symphony" "Garry's Mod" "GoldenEye: Source" "Team Fortress 2" )
for libc_server in "${libc_servers_array[@]}"
do
	if [ "${gamename}" == "${libc_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libc.so.6" "${lgsmdir}/lib" "nochmodx" "norun" "noforce" "nomd5"
	fi
done

# libpthread.so.0
local libpthread_servers_array=( "Black Mesa: Deathmatch" "Blade Symphony" "Garry's Mod" )
for libpthread_server in "${libpthread_servers_array[@]}"
do
	if [ "${gamename}" == "${libpthread_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libpthread.so.0" "${lgsmdir}/lib" "nochmodx" "norun" "noforce" "nomd5"
	fi
done

## amd64

# libm.so.6
local libm_servers_array=( "Factorio" )
for libm_server in "${libm_servers_array[@]}"
do
	if [ "${gamename}" == "${libm_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/amd64" "libm.so.6" "${lgsmdir}/lib" "nochmodx" "norun" "noforce" "nomd5"
	fi
done

# libc.so.6
local libc_servers_array=( "Factorio" )
for libc_server in "${libc_servers_array[@]}"
do
	if [ "${gamename}" == "${libc_server}" ]; then
		fn_fetch_file_github "lgsm/lib/ubuntu12.04/amd64" "libc.so.6" "${lgsmdir}/lib" "nochmodx" "norun" "noforce" "nomd5"
	fi
done

export LD_LIBRARY_PATH=:"${libdir}"