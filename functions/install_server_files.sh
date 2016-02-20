#!/bin/bash
# LGSM install_server_files.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="050216"


fn_install_server_files(){
if [ "${gamename}" == "Unreal Tournament 99" ]; then
	fileurl="http://gameservermanagers.com/files/ut-server-451-complete.tar.bz2"; filedir="${lgsmdir}/tmp"; filename="ut-server-451-complete.tar.bz2"; run="norun"; force="noforce"; md5="e623fdff5ed600a9bfccab852e18d34d"
fi
fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${run}" "${force}" "${md5}"
fn_dl_extract "${filedir}" "${filename}" "${filesdir}"
}

#!/bin/bash
# LGSM install_serverfiles.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

fn_install_server_files_steamcmd(){
check.sh
mkdir -pv "${filesdir}"
counter="0"
while [ "${counter}" == "0" ]||[ "$(grep -wc 0x402 .install_serverfiles.sh.tmp)" -ge "1" ]||[ "$(grep -wc 0x406 .install_serverfiles.sh.tmp)" -ge "1" ]||[ "$(grep -wc 0x6 .install_serverfiles.sh.tmp)" -ge "1" ]||[ "$(grep -wc 0x106 .install_serverfiles.sh.tmp)" -ge "1" ]; do
	counter=$((counter+1))
	cd "${rootdir}/steamcmd"
	if [ "${counter}" -le "10" ]; then
		# Attempt 1-4: Standard attempt
		# Attempt 5-6: Validate attempt
		# Attempt 7-8: Validate, delete long name dir
		# Attempt 9-10: Validate, delete long name dir, re-download SteamCMD
		# Attempt 11: Failure

		if [ "${counter}" -ge "2" ]; then
			fn_printwarningnl "SteamCMD did not complete the download, retrying: Attempt ${counter}:"
		fi

		if [ "${counter}" -ge "7" ]; then
			echo "Removing $(find ${filesdir} -type d -print0 | grep -Ez '[^/]{30}$')"
			find ${filesdir} -type d -print0 | grep -Ez '[^/]{30}$' | xargs -0 rm -rf
		fi
		if [ "${counter}" -ge "9" ]; then
			rm -rf "${rootdir}/steamcmd"
			check_steamcmd.sh
		fi

		# Detects if unbuffer command is available.
		if [ $(command -v unbuffer) ]; then
			unbuffer=unbuffer
		fi

		if [ "${counter}" -le "4" ]; then
			if [ "${engine}" == "goldsource" ]; then
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" +quit |tee .install_serverfiles.sh.tmp
			else
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" +quit |tee .install_serverfiles.sh.tmp
			fi
		elif [ "${counter}" -ge "5" ]; then
			if [ "${engine}" == "goldsource" ]; then
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" -validate +quit |tee .install_serverfiles.sh.tmp
			else
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" -validate +quit |tee .install_serverfiles.sh.tmp
			fi
		fi
	elif [ "${counter}" -ge "11" ]; then
		fn_printfailurenl "SteamCMD did not complete the download, too many retrys"
		break
	fi

done

# Goldsource servers commonly fail to download all the server files required.
# Validating a few of times may reduce the chance of this issue.
if [ "${engine}" == "goldsource" ]; then
	counter="0"
	while [ "${counter}" -le "4" ]; do
		counter=$((counter+1))
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" -validate +quit |tee .install_serverfiles.sh.tmp
	done
fi
rm -f .install_serverfiles.sh.tmp
}

echo ""
echo "Installing ${gamename} Server"
echo "================================="
sleep 1
if [ -n "${appid}" ]; then
	fn_install_server_files_steamcmd
fi

if [ -z "${appid}" ]||[ "${gamename}" == "GoldenEye: Source" ]; then
	fn_install_server_files
fi

if [ -z "${autoinstall}" ]; then
	echo ""
	echo "================================="
	while true; do
	read -e -i "y" -p "Was the install successful? [Y/n]" yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) install_retry.sh;;
			* ) echo "Please answer yes or no.";;
		esac
	done
fi