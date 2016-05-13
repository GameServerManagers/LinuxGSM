#!/bin/bash
# LGSM finstall_serverfiles.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

fn_steaminstallcommand(){
check.sh
counter="0"
while [ "${counter}" == "0" ]||[ "$(grep -wc 0x402 .finstall_serverfiles.sh.tmp)" -ge "1" ]||[ "$(grep -wc 0x406 .finstall_serverfiles.sh.tmp)" -ge "1" ]||[ "$(grep -wc 0x6 .finstall_serverfiles.sh.tmp)" -ge "1" ]||[ "$(grep -wc 0x106 .finstall_serverfiles.sh.tmp)" -ge "1" ]; do
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
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" +quit |tee .finstall_serverfiles.sh.tmp
			else
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" ${branch} +quit |tee .finstall_serverfiles.sh.tmp
			fi
		elif [ "${counter}" -ge "5" ]; then
			if [ "${engine}" == "goldsource" ]; then
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" -validate +quit |tee .finstall_serverfiles.sh.tmp
			else
				${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" ${branch} -validate +quit |tee .finstall_serverfiles.sh.tmp
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
		${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" -validate +quit |tee .finstall_serverfiles.sh.tmp
	done
fi
rm -f .finstall_serverfiles.sh.tmp
}

echo ""
echo "Installing ${gamename} Server"
echo "================================="
sleep 1
mkdir -pv "${filesdir}"
fn_steaminstallcommand
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
