#!/bin/bash
# LinuxGSM install_server_files.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Installs server files.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_install_server_files(){
	if [ "${gamename}" == "Battlefield: 1942" ]; then
		remote_fileurl="http://files.gameservermanagers.com/BattleField1942/bf1942_lnxded-1.61-hacked-to-1.612.full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="bf1942_lnxded-1.61-hacked-to-1.612.full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="a86a5d3cd64ca59abcc9bb9f777c2e5d"
	elif [ "${gamename}" == "Call of Duty" ]; then
		remote_fileurl="http://files.gameservermanagers.com/CallOfDuty/cod-lnxded-1.5b-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="cod-lnxded-1.5-large.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="19629895a4cf6fd8f6d1ee198b5304cd"
	elif [ "${gamename}" == "Call of Duty: United Offensive" ]; then
		remote_fileurl="http://files.gameservermanagers.com/CallOfDutyUnitedOffensive/coduo-lnxded-1.51b-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="coduo-lnxded-1.51b-full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="f1804ef13036e2b4ab535db000b19e97"
	elif [ "${gamename}" == "Call of Duty 2" ]; then
		remote_fileurl="http://files.gameservermanagers.com/CallOfDuty2/cod2-lnxded-1.3-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="cod2-lnxded-1.3-full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="078128f83d06dc3d7699428dc2870214"
	elif [ "${gamename}" == "Call of Duty 4" ]; then
		remote_fileurl="http://files.gameservermanagers.com/CallOfDuty4/cod4x18_dedrun.tar.bz2"; local_filedir="${tmpdir}"; local_filename="cod4x18_dedrun.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="bebdfc1755626462bdaad49f6f926c08"
	elif [ "${gamename}" == "Call of Duty: World at War" ]; then
		remote_fileurl="http://files.gameservermanagers.com/CallOfDutyWorldAtWar/codwaw-lnxded-1.7-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="codwaw-lnxded-1.7-full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="0489697ff3bf678c109bfb377d1b7895"
	elif [ "${gamename}" == "GoldenEye: Source" ]; then
		remote_fileurl="http://files.gameservermanagers.com/GoldenEyeSource/GoldenEye_Source_v5.0.6_full_server.tar.bz2"; local_filedir="${tmpdir}"; local_filename="GoldenEye_Source_v5.0.6_full_server.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="ea227a150300abe346e757380325f84c"
	elif [ "${gamename}" == "Quake 2" ]; then
		remote_fileurl="http://files.gameservermanagers.com/Quake2/quake2-3.20-glibc-i386-full-linux2.0.tar.bz2"; local_filedir="${tmpdir}"; local_filename="quake2-3.20-glibc-i386-full-linux2.0.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="0b8c7e2d51f40b56b328c69e986e7c5f"
	elif [ "${gamename}" == "Quake 3: Arena" ]; then
		remote_fileurl="http://files.gameservermanagers.com/Quake3/quake3-1.32c-x86-full-linux.tar.bz2"; local_filedir="${tmpdir}"; local_filename="quake3-1.32c-x86-full-linux.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="fd7258d827474f67663dda297bff4306"
	elif [ "${gamename}" == "QuakeWorld" ]; then
		remote_fileurl="http://files.gameservermanagers.com/QuakeWorld/nquake.server.linux.083116.full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="nquake.server.linux.083116.full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="75a409cf08d808f075e4dacdc7b21b78"
	elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
		remote_fileurl="http://files.gameservermanagers.com/UnrealTournament2004/ut2004-server-3339-ultimate-linux.tar.bz2"; local_filedir="${tmpdir}"; local_filename="ut2004-server-3339-ultimate-linux.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="67c5e2cd9c2a4b04f163962ee41eff54"
	elif [ "${gamename}" == "Unreal Tournament 99" ]; then
		remote_fileurl="http://files.gameservermanagers.com/UnrealTournament99/ut99-server-451-ultimate-linux.tar.bz2"; local_filedir="${tmpdir}"; local_filename="ut99-server-451-ultimate-linux.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="49cb24d0550ff6ddeaba6007045c6edd"
	elif [ "${gamename}" == "Unreal Tournament" ]; then
		remote_fileurl="https://s3.amazonaws.com/unrealtournament/UnrealTournament-Client-XAN-3395761-Linux.zip"; local_filedir="${tmpdir}"; local_filename="UnrealTournament-Server-XAN-3395761-Linux.zip";  chmodx="noexecute" run="norun"; force="noforce"; md5="f04ad5b96865b19613303331ff4075eb"
	elif [ "${gamename}" == "Unreal Tournament 3" ]; then
		remote_fileurl="http://files.gameservermanagers.com/UnrealTournament3/UT3-linux-server-2.1.tar.bz2"; local_filedir="${tmpdir}"; local_filename="UT3-linux-server-2.1.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="2527437b46f1b47f20228d27d72395a6"
	elif [ "${gamename}" == "Wolfenstein: Enemy Territory" ]; then
		remote_fileurl="http://files.gameservermanagers.com/WolfensteinEnemyTerritory/enemy-territory.260b.tar.bz2"; local_filedir="${tmpdir}"; local_filename="enemy-territory.260b.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="f833f514bfcdd46b42c111f83350c5a7"
	fi
	fn_fetch_file "${remote_fileurl}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
	fn_dl_extract "${local_filedir}" "${local_filename}" "${serverfiles}"
}

fn_install_server_files_steamcmd(){
	counter="0"
	while [ "${counter}" == "0" ]||[ "${exitcode}" != "0" ]; do
		counter=$((counter+1))
		cd "${steamcmddir}"
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
				echo "Removing $(find ${serverfiles} -type d -print0 | grep -Ez '[^/]{30}$')"
				find ${serverfiles} -type d -print0 | grep -Ez '[^/]{30}$' | xargs -0 rm -rf
			fi
			if [ "${counter}" -ge "9" ]; then
				rm -rf "${steamcmddir}"
				check_steamcmd.sh
			fi

			# Detects if unbuffer command is available for 32 bit distributions only.
			info_distro.sh
			if [ $(command -v stdbuf 2>/dev/null) ]&&[ "${arch}" != "x86_64" ]; then
				unbuffer="stdbuf -i0 -o0 -e0"
			fi

			if [ "${counter}" -le "4" ]; then
				if [ "${engine}" == "goldsource" ]; then
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" ${branch} +quit
					local exitcode=$?
				else
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" ${branch} +quit
					local exitcode=$?

					if [ "${gamename}" == "Classic Offensive" ]; then
						${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid_co}" ${branch} +quit
						local exitcode=$?
					fi
				fi
			elif [ "${counter}" -ge "5" ]; then
				if [ "${engine}" == "goldsource" ]; then
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" ${branch} validate +quit
					local exitcode=$?
				else
					${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" ${branch} validate +quit
					local exitcode=$?

					if [ "${gamename}" == "Classic Offensive" ]; then
						${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid_co}" ${branch} -validate +quit
						local exitcode=$?
					fi
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
			${unbuffer} ./steamcmd.sh +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod ${appidmod} +app_update "${appid}" ${branch} -validate +quit
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
	install_minecraft_eula.sh
	update_minecraft.sh
elif [ "${gamename}" == "Mumble" ]; then
	update_mumble.sh
elif [ "${gamename}" == "Multi Theft Auto" ]; then
	update_mta.sh
elif [ "${gamename}" == "Factorio" ]; then
  update_factorio.sh
  install_factorio_save.sh
elif [ -z "${appid}" ]||[ "${gamename}" == "GoldenEye: Source" ]; then
	if [ "${gamename}" == "Unreal Tournament" ]; then
		install_unreal_tournament_eula.sh
	fi
	fn_install_server_files
fi

if [ -z "${autoinstall}" ]; then
	echo ""
	echo "================================="
	if ! fn_prompt_yn "Was the install successful?" Y; then
		install_retry.sh
	fi
fi
