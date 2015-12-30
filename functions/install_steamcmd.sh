#!/bin/bash
# LGSM install_steamcmd.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Downloads SteamCMD on install.

echo ""
echo "Installing SteamCMD"
echo "================================="
sleep 1
steamcmddir="${rootdir}/steamcmd"
if [ ! -f "${steamcmddir}/steamcmd.sh" ]; then
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
else
	echo "SteamCMD already installed!"
fi
	# Checks that steamcmd is working correctly and will prompt Steam Guard if required.
	"${steamcmddir}"/steamcmd.sh +login "${steamuser}" "${steampass}" +quit
	if [ $? -ne 0 ]; then
		fn_printfailurenl "Error running SteamCMD"
	fi	
sleep 1
