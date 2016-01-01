#!/bin/bash
# LGSM fix_steamcmd.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="010116"

# Description: fixes various issues related to steamCMD.

fn_msg_start(){
	fn_printdots "Applying ${fixname} fix: ${gamename}"
	sleep 1
	fn_printinfo "Applying ${fixname} fix: ${gamename}"
	fn_scriptlog "Applying ${fixname} fix: ${gamename}"
	sleep 1
}

fn_msg_end(){
	if [ $? -ne 0 ]; then
		fn_printfailnl "Applying ${fixname} fix: ${gamename}"
		fn_scriptlog "Failure! Applying ${fixname} fix: ${gamename}"
	else
		fn_printoknl "Applying ${fixname} fix: ${gamename}"
		fn_scriptlog "Complete! Applying ${fixname} fix: ${gamename}"
	fi	
}


# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
if [ ! -f "${HOME}/.steam/sdk32/steamclient.so" ]; then
	local fixname="steamclient.so general"
	fn_msg_start
	mkdir -pv "${HOME}/.steam/sdk32" >> "${scriptlog}"
	cp -v "${rootdir}/steamcmd/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so" >> "${scriptlog}"
	fn_msg_end
fi

if [ "${gamename}" == "Serious Sam 3: BFE" ]; then
	# Fixes: .steam/bin32/libsteam.so: cannot open shared object file: No such file or directory
	if [ ! -f "${HOME}/.steam/bin32/libsteam.so" ]; then
		local fixname="libsteam.so"
		fn_msg_start
		mkdir -pv "${HOME}/.steam/bin32" >> "${scriptlog}"
		cp -v "${filesdir}/Bin/libsteam.so" "${HOME}/.steam/bin32/libsteam.so" >> "${scriptlog}"
		fn_msg_end
	fi
elif [ "${gamename}" == "Hurtworld" ]; then
	# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam, or a local steamclient.so.

	if [ ! -f "${filesdir}/Hurtworld_Data/Plugins/x86/steamclient.so" ]; then
		local fixname="steamclient.so x86"
		fn_msg_start
		cp -v "${rootdir}/steamcmd/linux32/steamclient.so" "${filesdir}/Hurtworld_Data/Plugins/x86/steamclient.so" >> "${scriptlog}"
		fn_msg_end
	fi	
	if [ ! -f "${filesdir}/Hurtworld_Data/Plugins/x86_64/steamclient.so" ]; then
		local fixname="steamclient.so x86_64"
		fn_msg_start	
		cp -v "${rootdir}/steamcmd/linux32/steamclient.so" "${filesdir}/Hurtworld_Data/Plugins/x86_64/steamclient.so" >> "${scriptlog}"
		fn_msg_end
	fi
fi
