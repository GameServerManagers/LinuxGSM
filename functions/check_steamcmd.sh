#!/bin/bash
# LGSM check_steamcmd.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="160316"

# Description: Checks SteamCMD is installed and correct.


fn_install_steamcmd(){
echo "Installing steamCMD"
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
echo ""
}


fn_check_steamcmd_user(){
# Checks steamuser is setup. 
if [ "${steamuser}" == "username" ]; then
	fn_printfailnl "Steam login not set. Update steamuser."	
	echo "	* Change steamuser=\"username\" to a valid steam login."
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "edit ${selfname}. change steamuser=\"username\" to a valid steam login."
		exit 1
	fi
fi
# Anonymous user is set if steamuser is missing
if [ -z "${steamuser}" ]; then
	fn_printwarnnl "Steam login not set. Using anonymous login."
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "Steam login not set. Using anonymous login."
	fi
	steamuser="anonymous"
	steampass=""
	sleep 2
fi	
}

fn_check_steamcmd_sh(){
# Checks if SteamCMD exists when starting or updating a server.
# Installs if missing.
steamcmddir="${rootdir}/steamcmd"
if [ ! -f "${steamcmddir}/steamcmd.sh" ]; then
	if [ "${function_selfname}" == "command_install.sh" ]; then
		fn_install_steamcmd
	else	
		fn_printwarnnl "SteamCMD is missing"
		fn_scriptlog "SteamCMD is missing"
		sleep 1
		fn_install_steamcmd
	fi
elif [ "${function_selfname}" == "command_install.sh" ]; then
	fn_printinfomation "SteamCMD is already installed..."
	fn_printokeol	
fi
}

fn_check_steamcmd_guard(){
if [ "${function_selfname}" == "command_update.sh" ]||[ "${function_selfname}" == "command_validate.sh" ]; then
	# Checks that steamcmd is working correctly and will prompt Steam Guard if required.
	"${steamcmddir}"/steamcmd.sh +login "${steamuser}" "${steampass}" +quit
	if [ $? -ne 0 ]; then
		fn_printfailurenl "Error running SteamCMD"	
	fi		
fi		
}

if [ "${gamename}" == "Unreal Tournament 99" ]||[ "${gamename}" == "Unreal Tournament 2004" ]||[ "${gamename}" == "Mumble" ]||[ "${gamename}" == "Teamspeak 3" ]; then
	: # These servers do not require SteamCMD. Check is skipped.
else
	fn_check_steamcmd_user
	fn_check_steamcmd_sh
	fn_check_steamcmd_guard
fi