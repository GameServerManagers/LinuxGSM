#!/bin/bash
# LinuxGSM install_server_files.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Installs server files.

local modulename="INSTALL"
local commandaction="Install"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

fn_install_server_files(){
	if [ "${shortname}" == "ahl" ]; then
		remote_fileurl="http://linuxgsm.download/ActionHalfLife/action_halflife-1.0.tar.bz2"; local_filedir="${tmpdir}"; local_filename="action_halflife-1.0.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="31430e670692b2eeaa0d1217db4dcb73"
	elif [ "${shortname}" == "bf1942" ]; then
		remote_fileurl="http://linuxgsm.download/BattleField1942/bf1942_lnxded-1.61-hacked-to-1.612.full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="bf1942_lnxded-1.61-hacked-to-1.612.full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="a86a5d3cd64ca59abcc9bb9f777c2e5d"
	elif [ "${shortname}" == "bb" ]; then
		remote_fileurl="http://linuxgsm.download/BrainBread/brainbread-v1.2-linuxserver.tar.bz2"; local_filedir="${tmpdir}"; local_filename="brainbread-v1.2-linuxserver.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="5c729a7e9eecfa81b71a6a1f7267f0fd"
	elif [ "${shortname}" == "cod" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDuty/cod-lnxded-1.5b-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="cod-lnxded-1.5-large.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="19629895a4cf6fd8f6d1ee198b5304cd"
	elif [ "${shortname}" == "coduo" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDutyUnitedOffensive/coduo-lnxded-1.51b-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="coduo-lnxded-1.51b-full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="f1804ef13036e2b4ab535db000b19e97"
	elif [ "${shortname}" == "cod2" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDuty2/cod2-lnxded-1.3-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="cod2-lnxded-1.3-full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="078128f83d06dc3d7699428dc2870214"
	elif [ "${shortname}" == "cod4" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDuty4/cod4x18_1772_dedrun.tar.bz2"; local_filedir="${tmpdir}"; local_filename="cod4x18_1772_dedrun.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="de29f29d79f9cc24574b838daa501e46"
	elif [ "${shortname}" == "codwaw" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDutyWorldAtWar/codwaw-lnxded-1.7-full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="codwaw-lnxded-1.7-full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="0489697ff3bf678c109bfb377d1b7895"
	elif [ "${shortname}" == "etl" ]; then
		remote_fileurl="http://linuxgsm.download/WolfensteinEnemyTerritory/etlegacy-v2.75-i386-et-260b.tar.bz2"; local_filedir="${tmpdir}"; local_filename="etlegacy-v2.75-i386-et-260b.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="92d7d4c26e0a295daed78cef623eeabb"
	elif [ "${shortname}" == "ges" ]; then
		remote_fileurl="http://linuxgsm.download/GoldenEyeSource/GoldenEye_Source_v5.0.6_full_server.tar.bz2"; local_filedir="${tmpdir}"; local_filename="GoldenEye_Source_v5.0.6_full_server.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="c45c16293096706e8b5e2cd64a6f2931"
	elif [ "${shortname}" == "mohaa" ]; then
		remote_fileurl="http://linuxgsm.download/MedalofHonorAlliedAssault/moh_revival_v1.12_RC3.5.1.tar.bz2"; local_filedir="${tmpdir}"; local_filename="moh_revival_v1.12_RC3.5.1.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="9d5924486a0cf5e46dd063216aad05c1"
	elif [ "${shortname}" == "ns" ]; then
		remote_fileurl="http://linuxgsm.download/NaturalSelection/ns_dedicated_server_v32.tar.bz2"; local_filedir="${tmpdir}"; local_filename="ns_dedicated_server_v32.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="499cf63324b76925ada6baf5f2eacd67"
	elif [ "${shortname}" == "q2" ]; then
		remote_fileurl="http://linuxgsm.download/Quake2/quake2-3.20-glibc-i386-full-linux2.0.tar.bz2"; local_filedir="${tmpdir}"; local_filename="quake2-3.20-glibc-i386-full-linux2.0.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="0b8c7e2d51f40b56b328c69e986e7c5f"
	elif [ "${shortname}" == "q3" ]; then
		remote_fileurl="http://linuxgsm.download/Quake3/quake3-1.32c-x86-full-linux.tar.bz2"; local_filedir="${tmpdir}"; local_filename="quake3-1.32c-x86-full-linux.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="fd7258d827474f67663dda297bff4306"
	elif [ "${shortname}" == "qw" ]; then
		remote_fileurl="http://linuxgsm.download/QuakeWorld/nquake.server.linux.190506.full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="nquake.server.linux.190506.full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="74405ec030463c5e1175e776ab572d32"
	elif [ "${shortname}" == "rtcw" ]; then
		remote_fileurl="http://linuxgsm.download/ReturnToCastleWolfenstein/iortcw-1.51c-x86_64-server-linux-20190507.tar.bz2"; local_filedir="${tmpdir}"; local_filename="iortcw-1.51c-x86_64-server-linux-20190507.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="6a3be9700372b228d1187422464e4212"
	elif [ "${shortname}" == "sfc" ]; then
		remote_fileurl="http://linuxgsm.download/SourceFortsClassic/SFClassic-1.0-RC7-fix.tar.bz2"; local_filedir="${tmpdir}"; local_filename="SFClassic-1.0-RC7-fix.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="e0d4cfd298a8a356053f92b1fa7d1002"
	elif [ "${shortname}" == "sof2" ]; then
		remote_fileurl="http://linuxgsm.download/SoldierOfFortune2/sof2gold-1.03.tar.bz2"; local_filedir="${tmpdir}"; local_filename="sof2gold-1.03.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="871b1dc0dafeeace65b198119e8fa200"
	elif [ "${shortname}" == "ts" ]; then
		remote_fileurl="http://linuxgsm.download/TheSpecialists/ts-3-linux-final.tar.bz2"; local_filedir="${tmpdir}"; local_filename="ts-3-linux-final.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="38e8a8325339f85a7745117802f940b7"
	elif [ "${shortname}" == "ut2k4" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament2004/ut2004-server-3369-2-ultimate-linux.tar.bz2"; local_filedir="${tmpdir}"; local_filename="ut2004-server-3369-2-ultimate-linux.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="67c5e2cd9c2a4b04f163962ee41eff54"
	elif [ "${shortname}" == "ut99" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament99/ut99-server-451-ultimate-linux.tar.bz2"; local_filedir="${tmpdir}"; local_filename="ut99-server-451-ultimate-linux.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="49cb24d0550ff6ddeaba6007045c6edd"
	elif [ "${shortname}" == "ut" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament/UnrealTournament-Server-XAN-3525360-Linux.zip"; local_filedir="${tmpdir}"; local_filename="UnrealTournament-Server-XAN-3525360-Linux.zip";  chmodx="noexecute" run="norun"; force="noforce"; md5="cad730ad6793ba6261f9a341ad7396eb"
	elif [ "${shortname}" == "ut3" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament3/UT3-linux-server-2.1.tar.bz2"; local_filedir="${tmpdir}"; local_filename="UT3-linux-server-2.1.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="2527437b46f1b47f20228d27d72395a6"
	elif [ "${shortname}" == "vs" ]; then
		remote_fileurl="http://linuxgsm.download/VampireSlayer/vs_l-6.0_full.tar.bz2"; local_filedir="${tmpdir}"; local_filename="vs_l-6.0_full.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="38a79e44b98578bbdc5b15818493a066"
	elif [ "${shortname}" == "wet" ]; then
		remote_fileurl="http://linuxgsm.download/WolfensteinEnemyTerritory/enemy-territory.260b.tar.bz2"; local_filedir="${tmpdir}"; local_filename="enemy-territory.260b.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="f833f514bfcdd46b42c111f83350c5a7"
	elif [ "${shortname}" == "samp" ]; then
		remote_fileurl="https://files.sa-mp.com/samp037svr_R2-1.tar.gz"; local_filedir="${tmpdir}"; local_filename="samp037svr_R2-1.tar.gz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="93705e165550c97484678236749198a4"
	elif [ "${shortname}" == "sol" ]; then
		remote_fileurl="https://static.soldat.pl/downloads/soldatserver2.8.1_1.7.1.zip"; local_filedir="${tmpdir}"; local_filename="soldatserver2.8.1_1.7.1.zip"; chmodx="nochmodx" run="norun"; force="noforce"; md5="994409c28520425965dec5c71ccb55e1"
	elif [ "${shortname}" == "zmr" ]; then
		remote_fileurl="http://linuxgsm.download/ZombieMasterReborn/zombie_master_reborn_b5_2.tar.bz2"; local_filedir="${tmpdir}"; local_filename="zombie_master_reborn_b5_2.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="d52ef2db376f5d21e3a4ceca85ec8761"
	fi
	fn_fetch_file "${remote_fileurl}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
	fn_dl_extract "${local_filedir}" "${local_filename}" "${serverfiles}"
}

fn_install_server_files_steamcmd(){
	counter="0"
	while [ "${counter}" == "0" ]||[ "${exitcode}" != "0" ]; do
		counter=$((counter+1))
		if [ -d "${steamcmddir}" ]; then
			cd "${steamcmddir}" || exit
		fi
		if [ "${counter}" -le "10" ]; then
			# Attempt 1-4: Standard attempt.
			# Attempt 5-6: Validate attempt.
			# Attempt 7-8: Validate, delete long name dir.
			# Attempt 9-10: Validate, delete long name dir, re-download SteamCMD.
			# Attempt 11: Failure.

			if [ "${counter}" -ge "2" ]; then
				fn_print_warning_nl "SteamCMD did not complete the download, retrying: Attempt ${counter}"
				fn_script_log "SteamCMD did not complete the download, retrying: Attempt ${counter}"
			fi

			if [ "${counter}" -ge "7" ]; then
				echo -e "Removing $(find "${serverfiles}" -type d -print0 | grep -Ez '[^/]{30}$')"
				find "${serverfiles}" -type d -print0 | grep -Ez '[^/]{30}$' | xargs -0 rm -rf
			fi
			if [ "${counter}" -ge "9" ]; then
				rm -rf "${steamcmddir:?}"
				check_steamcmd.sh
			fi

			# Detects if unbuffer command is available for 32 bit distributions only.
			info_distro.sh
			if [ "$(command -v stdbuf 2>/dev/null)" ]&&[ "${arch}" != "x86_64" ]; then
				unbuffer="stdbuf -i0 -o0 -e0"
			fi

			if [ "${counter}" -le "4" ]; then
				if [ "${appid}" == "90" ]; then
					${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" +quit
					local exitcode=$?
				else
					${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" -beta "${branch}" +quit
					local exitcode=$?
				fi
			elif [ "${counter}" -ge "5" ]; then
				if [ "${engine}" == "goldsource" ]; then
					${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" validate +quit
					local exitcode=$?
				else
					${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" -beta "${branch}" validate +quit
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
			${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" "${branch}" validate +quit
			local exitcode=$?
		done
	fi
}

echo -e ""
echo -e "${lightyellow}Installing ${gamename} Server${default}"
echo -e "================================="
fn_sleep_time

if [ "${appid}" ]; then
	fn_install_server_files_steamcmd
fi

if [ "${shortname}" == "ts3" ]; then
	update_ts3.sh
elif [ "${shortname}" == "mc" ]; then
	install_eula.sh
	update_minecraft.sh
elif [ "${shortname}" == "mcb" ]; then
	update_minecraft_bedrock.sh
elif [ "${shortname}" == "mumble" ]; then
	update_mumble.sh
elif [ "${shortname}" == "mta" ]; then
	update_mta.sh
elif [ "${shortname}" == "fctr" ]; then
	update_factorio.sh
	install_factorio_save.sh
elif [ -z "${appid}" ]||[ "${shortname}" == "ahl" ]||[ "${shortname}" == "bd" ]||[ "${shortname}" == "bb" ]||[ "${shortname}" == "ges" ]||[ "${shortname}" == "ns" ]||[ "${shortname}" == "sfc" ]||[ "${shortname}" == "sol" ]||[ "${shortname}" == "ts" ]||[ "${shortname}" == "vs" ]||[ "${shortname}" == "zmr" ]; then
	if [ "${shortname}" == "ut" ]; then
		install_eula.sh
	fi
	fn_install_server_files
fi

if [ -z "${autoinstall}" ]; then
	echo -e ""
	echo -e "================================="
	if ! fn_prompt_yn "Was the install successful?" Y; then
		install_retry.sh
	fi
fi
