#!/bin/bash
# LGSM fix_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="220416"

# Description: Downloads required glibc files and applys teh glibc fix if required

info_glibc.sh

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

glibcversion="$(ldd --version | sed 's/.* //;q')"
if [ "$(printf '%s\n'${glibcrequired}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibcrequired}" ]; then
	if [ "${glibcfix}" == "yes" ]; then 
		fn_print_info_nl "Glibc fix: Using Glibc fix"
		echo "	* glibc required: ${glibcrequired}"
		echo "	* glibc installed: ${glibcversion}"
		export LD_LIBRARY_PATH=:"${libdir}"
	else
		fn_print_warn_nl "Glibc fix: No Glibc fix available!"
		echo -en "\n"
		echo "	* glibc required: ${glibcrequired}"
		echo "	* glibc installed: ${glibcversion}"
		echo -en "\n"
		fn_print_infomation "The game server will probably not work. A distro upgrade is required!"
	fi
	echo -en "\n"
fi