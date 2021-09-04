#!/bin/bash
# LinuxGSM fix_steamcmd.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues related to SteamCMD.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# function to simplify the steamclient.so fix
# example
# fn_fix_steamclient_so 32|64 (bit) "${serverfiles}/linux32/"
fn_fix_steamclient_so(){
	# $1 type of fix 32 or 64 as possible values
	# $2 as destination where the lib will be copied to
	if [ "$1" == "32" ]; then
		# steamclient.so x86 fix.
		if [ ! -f "${2}/steamclient.so" ]; then
			fixname="steamclient.so x86"
			fn_fix_msg_start
			if [ ! -d "${2}" ]; then
				mkdir -p "${2}"
			fi
			if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
				cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${2}/steamclient.so"
			elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
				cp "${steamcmddir}/linux32/steamclient.so" "${2}/steamclient.so"
			fi
			fn_fix_msg_end
		fi
	elif [ "$1" == "64" ]; then
		# steamclient.so x86_64 fix.
		if [ ! -f "${2}/steamclient.so" ]; then
			fixname="steamclient.so x86_64"
			fn_fix_msg_start
			if [ ! -d "${2}" ]; then
				mkdir -p "${2}"
			fi
			if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
				cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${2}/steamclient.so"
			elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
				cp "${steamcmddir}/linux64/steamclient.so" "${2}/steamclient.so"
			fi
			fn_fix_msg_end
		fi
	fi
}

# Helps fix: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
if [ ! -f "${HOME}/.steam/sdk64/steamclient.so" ]; then
	fixname="steamclient.so sdk64"
	fn_fix_msg_start
	mkdir -p "${HOME}/.steam/sdk64"
	if [ -f "${HOME}/.steam/steamcmd/linux64/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux64/steamclient.so" "${HOME}/.steam/sdk64/steamclient.so"
	elif [ -f "${steamcmddir}/linux64/steamclient.so" ]; then
		cp "${steamcmddir}/linux64/steamclient.so" "${HOME}/.steam/sdk64/steamclient.so"
	fi
	fn_fix_msg_end
fi

# Helps fix: [S_API FAIL] SteamAPI_Init() failed; unable to locate a running instance of Steam,or a local steamclient.so.
if [ ! -f "${HOME}/.steam/sdk32/steamclient.so" ]; then
	fixname="steamclient.so sdk32"
	fn_fix_msg_start
	mkdir -p "${HOME}/.steam/sdk32"
	if [ -f "${HOME}/.steam/steamcmd/linux32/steamclient.so" ]; then
		cp "${HOME}/.steam/steamcmd/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so"
	elif [ -f "${steamcmddir}/linux32/steamclient.so" ]; then
		cp "${steamcmddir}/linux32/steamclient.so" "${HOME}/.steam/sdk32/steamclient.so"
	fi
	fn_fix_msg_end
fi

# steamclient.so fixes
if [ "${shortname}" == "bo" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/BODS_Data/Plugins/x86"
	fn_fix_steamclient_so "64" "${serverfiles}/BODS_Data/Plugins/x86_64"
elif [ "${shortname}" == "cmw" ]; then
	fn_fix_steamclient_so "32" "${executabledir}/lib"
elif [ "${shortname}" == "cs" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}"
elif [ "${shortname}" == "col" ]; then
	fn_fix_steamclient_so "64" "${serverfiles}"
elif [ "${shortname}" == "ins" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/bin"
elif [ "${shortname}" == "pz" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/linux32"
	fn_fix_steamclient_so "64" "${serverfiles}/linux64"
elif [ "${shortname}" == "pvr" ]; then
	fn_fix_steamclient_so "64" "${executabledir}"
elif [ "${shortname}" == "ss3" ]; then
	fn_fix_steamclient_so "32" "${serverfiles}/Bin"
elif [ "${shortname}" == "tu" ];then
	fn_fix_steamclient_so "64" "${executabledir}"
elif [ "${shortname}" == "unt" ]; then
	fn_fix_steamclient_so "64" "${serverfiles}"
elif [ "${shortname}" == "wurm" ]; then
	fn_fix_steamclient_so "64" "${serverfiles}/nativelibs"
fi
