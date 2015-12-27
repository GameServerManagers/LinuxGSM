#!/bin/bash
# LGSM check_steamcmd.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="261215"

# Description: Downloads SteamCMD on install and checks if missing before running functions that require SteamCMD


if [ "${gamename}" == "Unreal Tournament 99" ]||[ "${gamename}" == "Unreal Tournament 2004" ]; then
	: # These servers do not require SteamCMD. Check is skipped.
elif [ "${modulename}" == "Starting" ]||[ "${modulename}" == "Update" ]||[ "${modulename}" == "Validate" ]; then
	# Checks if SteamCMD exists when starting or updating a server.
	# Re-installs if missing.
	steamcmddir="${rootdir}/steamcmd"
	if [ ! -f "${steamcmddir}/steamcmd.sh" ]; then
		fn_printwarnnl "SteamCMD is missing"
		fn_scriptlog "SteamCMD is missing"
		sleep 1
		if [ ! -d "${steamcmddir}" ]; then
			mkdir -v "${steamcmddir}"
		fi
		curl=$(curl --fail -o "${steamcmddir}/steamcmd_linux.tar.gz" "http://media.steampowered.com/client/steamcmd_linux.tar.gz" 2>&1)
		exitcode=$?
		echo -e "downloading steamcmd_linux.tar.gz...\c"
		if [ $exitcode -eq 0 ]; then
			fn_printokeol
		else
			fn_printfaileol
			echo "${curl}"
			echo -e "${githuburl}\n"
			exit $exitcode
		fi
		tar --verbose -zxf "${steamcmddir}/steamcmd_linux.tar.gz" -C "${steamcmddir}"
		rm -v "${steamcmddir}/steamcmd_linux.tar.gz"
		chmod +x "${steamcmddir}/steamcmd.sh"
	fi		
	if [ "${modulename}" == "Update" ]||[ "${modulename}" == "Validate" ]; then
		# Checks that steamcmd is working correctly and will prompt Steam Guard if required.
		"${steamcmddir}"/steamcmd.sh +login "${steamuser}" "${steampass}" +quit
		if [ $? -ne 0 ]; then
			fn_printfailurenl "Error running SteamCMD"	
		fi		
	fi	
fi
