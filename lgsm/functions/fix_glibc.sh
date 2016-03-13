#!/bin/bash
# LGSM fix_glibc.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="020116"

info_glibc.sh

# Blade Symphony
if [ "${gamename}" == "Blade Symphony" ]; then
	:
# Dont Starve Together
elif [ "${gamename}" == "Don't Starve Together" ]; then
	:
# Double Action: Boogaloo
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	fn_fetch_file_github "lgsm/lib/ubuntu12.04/i386" "libm.so.6" "${lgsmdir}/lib" "noexecutecmd" "norun" "noforce" "nomd5"

# Fistful of Frags
elif [ "${gamename}" == "Fistful of Frags" ]; then
	:
# Garry's Mod
elif [ "${gamename}" == "Garry's Mod" ]; then
	:
# Insurgency
elif [ "${gamename}" == "Insurgency" ]; then
	:
elif [ "${gamename}" == "Left 4 Dead" ]; then
	:
# Natural Selection 2
elif [ "${gamename}" == "Natural Selection 2" ]; then
	:
# NS2: Combat
elif [ "${gamename}" == "NS2: Combat" ]; then
	:
# No More Room in Hell
elif [ "${gamename}" == "No More Room in Hell" ]; then
	:
# ARMA 3
elif [ "${gamename}" == "ARMA 3" ]; then
	:
# Just Cause 2
elif [ "${gamename}" == "Just Cause 2" ]; then
	:
# Serious Sam 3: BFE
elif [ "${gamename}" == "Serious Sam 3: BFE" ]; then
	:
fi


if [ "$(printf '%s\n$glibc_required\n' $glibc_version | sort -V | head -n 1)" != "${glibc_required}" ]; then
	echo "Version $(ldd --version | sed -n '1s/.* //p') is lower than $glibc_required"
	if [ "${glibcfix}" == "yes" ]; then 
		echo "applied glibc fix"
		echo "export LD_LIBRARY_PATH=:"${libdir}"
		export LD_LIBRARY_PATH=:"${lgsmdir}/lib/ubuntu12.04/i386"
	else
		echo "no glibc fix available you need to upgrade bro!!"
	fi	
else
	echo "GLIBC is OK no fix required"
fi