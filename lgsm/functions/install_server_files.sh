#!/bin/bash
# LGSM install_server_files.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Installs server files.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_install_server_files(){
	if [ "${gamename}" == "Unreal Tournament 99" ]; then
		fileurl="http://files.gameservermanagers.com/UnrealTournament99/ut99-server-451-ultimate-linux.tar.bz2"; filedir="${lgsmdir}/tmp"; filename="ut99-server-451-ultimate-linux.tar.bz2"; executecmd="noexecute" run="norun"; force="noforce"; md5="49cb24d0550ff6ddeaba6007045c6edd"
	elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
		fileurl="http://files.gameservermanagers.com/UnrealTournament2004/ut2004-server-3339-ultimate-linux.tar.bz2"; filedir="${lgsmdir}/tmp"; filename="ut2004-server-3339-ultimate-linux.tar.bz2";  executecmd="noexecute" run="norun"; force="noforce"; md5="67c5e2cd9c2a4b04f163962ee41eff54"
	elif [ "${gamename}" == "Unreal Tournament 3" ]; then
		fileurl="http://files.gameservermanagers.com/UnrealTournament3/UT3-linux-server-2.1.tar.bz2"; filedir="${lgsmdir}/tmp"; filename="UT3-linux-server-2.1.tar.bz2";  executecmd="noexecute" run="norun"; force="noforce"; md5="6c22fcef9e2e03ed154df97569af540c"
	elif [ "${gamename}" == "Battlefield: 1942" ]; then
		fileurl="http://files.gameservermanagers.com/BattleField1942/bf1942_lnxded-1.61-hacked-to-1.612.full.tar.gz"; filedir="${lgsmdir}/tmp"; filename="bf1942_lnxded-1.61-hacked-to-1.612.full.tar.gz";  executecmd="noexecute" run="norun"; force="noforce"; md5="7e9d2538a62b228f2de7176b44659aa9"
	elif [ "${gamename}" == "Enemy Territory" ]; then
		fileurl="http://files.gameservermanagers.com/WolfensteinEnemyTerritory/enemy-territory.260b.tar.bz2"; filedir="${lgsmdir}/tmp"; filename="enemy-territory.260b.tar.gz";  executecmd="noexecute" run="norun"; force="noforce"; md5="ded32053e470fe15d9403ec4a0ab7e89"
	elif [ "${gamename}" == "Unreal Tournament" ]; then
		fileurl="http://files.gameservermanagers.com/UnrealTournament/UnrealTournament-Server-XAN-3045522-Linux.zip"; filedir="${lgsmdir}/tmp"; filename="UnrealTournament-Server-XAN-3045522-Linux.zip";  executecmd="noexecute" run="norun"; force="noforce"; md5="553fed5645a9fc623e92563049bf79f6"
	elif [ "${gamename}" == "GoldenEye: Source" ]; then
		fileurl="http://files.gameservermanagers.com/GoldenEyeSource/GoldenEye_Source_v5.0.1_full_server_linux.tar.bz2"; filedir="${lgsmdir}/tmp"; filename="GoldenEye_Source_v5.0.1_server_full_Linux.tar.bz2";  executecmd="noexecute" run="norun"; force="noforce"; md5="ea227a150300abe346e757380325f84c"
	fi
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
	fn_dl_extract "${filedir}" "${filename}" "${filesdir}"
}

fn_install_server_files_steamcmd(){
	counter="0"
	while [ "${counter}" == "0" ]||[ "${exitcode}" != "0" ]; do
		counter=$((counter+1))
		cd "${rootdir}/steamcmd"
		if [ "${counter}" -le "10" ]; then
			# Attempt 1-4: Standard attempt
			# Attempt 5-6: Validate attempt
			# Attempt 7-8: Validate, delete long name dir
			# Attempt 9-10: Validate, delete long name dir, re-download SteamCMD
			# Attempt 11: Failure

			if [ "${counter}" -ge "2" ]; then
				fn_print_warning_nl "SteamCMD did not complete the download, retrying: Attempt ${counter}"
				fn_script_log "SteamCMD did not complete the download, retrying: Attempt ${counter}"
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
			if [ $(command -v stdbuf) ]; then
				unbuffer="stdbuf -i0 -o0 -e0"
			fi

			if [ "${counter}" -le "4" ]; then
				if [ "${engine}" == "goldsource" ]; then
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" ${branch} +quit
					local exitcode=$?
				else
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" ${branch} +quit
					local exitcode=$?
				fi
			elif [ "${counter}" -ge "5" ]; then
				if [ "${engine}" == "goldsource" ]; then
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" ${branch} -validate +quit
					local exitcode=$?
				else
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_update "${appid}" ${branch} -validate +quit
					local exitcode=$?
				fi
			fi
		elif [ "${counter}" -ge "11" ]; then
			fn_print_failure_nl "SteamCMD did not complete the download, too many retrys"
			fn_script_log "SteamCMD did not complete the download, too many retrys"
			break
		fi
	done

	# Goldsource servers commonly fail to download all the server files required.
	# Validating a few of times may reduce the chance of this issue.
	if [ "${engine}" == "goldsource" ]; then
		fn_print_information_nl "Goldsource servers commonly fail to download all the server files required. Validating a few of times may reduce the chance of this issue."
		counter="0"
		while [ "${counter}" -le "4" ]; do
			counter=$((counter+1))
			${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${filesdir}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" ${branch} -validate +quit
			local exitcode=$?
		done
	fi
}

echo ""
echo "Installing ${gamename} Server"
echo "================================="
sleep 1

if [ -n "${appid}" ]; then
	fn_install_server_files_steamcmd
fi

if [ "${gamename}" == "TeamSpeak 3" ]; then
	update_ts3.sh
elif [ "${gamename}" == "Minecraft" ]; then
	update_minecraft.sh
	install_minecraft_eula.sh
elif [ "${gamename}" == "Mumble" ]; then
	update_mumble.sh
elif [ -z "${appid}" ]||[ "${gamename}" == "GoldenEye: Source" ]; then
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
