#!/bin/bash
# LGSM install_fix_steam.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

fn_steamclientfix(){
echo ""
echo "Applying steamclient.so fix"
echo "================================="
sleep 1
# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
mkdir -pv "${HOME}/.steam/sdk32"
cp -v "${rootdir}/steamcmd/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so"
sleep 1
}

# Server specific
fn_libsteamfix(){
echo ""
echo "Applying libsteam.so and steamclient.so fixes"
echo "================================="
sleep 1
if [ "${gamename}" == "Garry's Mod" ]; then
	# Fixes: .steam/sdk32/libsteam.so: cannot open shared object file: No such file or directory
	mkdir -pv "${HOME}/.steam/sdk32"
	cp -v "${filesdir}/bin/libsteam.so" "${HOME}/.steam/sdk32/libsteam.so"
elif [ "${gamename}" == "Serious Sam 3: BFE" ]; then
	# Fixes: .steam/bin32/libsteam.so: cannot open shared object file: No such file or directory
	mkdir -pv "${HOME}/.steam/bin32"
	cp -v "${filesdir}/Bin/libsteam.so" "${HOME}/.steam/bin32/libsteam.so"
elif [ "${gamename}" == "Hurtworld" ]; then
	# Fixes: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam, or a local steamclient.so.
	cp -v "${rootdir}/steamcmd/linux32/steamclient.so" "${filesdir}/Hurtworld_Data/Plugins/x86/steamclient.so"
	cp -v "${rootdir}/steamcmd/linux32/steamclient.so" "${filesdir}/Hurtworld_Data/Plugins/x86_64/steamclient.so"
fi
sleep 1
}

fn_steamclientfix
if [ "${gamename}" == "Garry's Mod" ]||[ "${gamename}" == "Serious Sam 3: BFE" ]||[ "${gamename}" == "Hurtworld" ]; then
	fn_libsteamfix
fi
