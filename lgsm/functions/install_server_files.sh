#!/bin/bash
# LinuxGSM install_server_files.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Installs server files.

modulegroup="INSTALL"
function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_server_files(){
	if [ "${shortname}" == "ahl" ]; then
		remote_fileurl="http://linuxgsm.download/ActionHalfLife/action_halflife-1.0.tar.xz"; local_filedir="${tmpdir}"; local_filename="action_halflife-1.0.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="61d7b79fd714888b6d65944fdaafa94a"
	elif [ "${shortname}" == "bf1942" ]; then
		remote_fileurl="http://linuxgsm.download/BattleField1942/bf1942_lnxded-1.61-hacked-to-1.612.full.tar.xz"; local_filedir="${tmpdir}"; local_filename="bf1942_lnxded-1.61-hacked-to-1.612.full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="4223bf4ed85f5162c24b2cba51249b9e"
	elif [ "${shortname}" == "bb" ]; then
		remote_fileurl="http://linuxgsm.download/BrainBread/brainbread-v1.2-linuxserver.tar.xz"; local_filedir="${tmpdir}"; local_filename="brainbread-v1.2-linuxserver.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="55f227183b736397806d5b6db6143f15"
	elif [ "${shortname}" == "cod" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDuty/cod-lnxded-1.5b-full.tar.xz"; local_filedir="${tmpdir}"; local_filename="cod-lnxded-1.5-large.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="ee0ad1ccbfa1fd27fde01a4a431a5c2f"
	elif [ "${shortname}" == "coduo" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDutyUnitedOffensive/coduo-lnxded-1.51b-full.tar.xz"; local_filedir="${tmpdir}"; local_filename="coduo-lnxded-1.51b-full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="35cabccd67adcda44aaebc59405915b9"
	elif [ "${shortname}" == "cod2" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDuty2/cod2-lnxded-1.3-full.tar.xz"; local_filedir="${tmpdir}"; local_filename="cod2-lnxded-1.3-full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="b8c4c611f01627dd43348e78478a3d41"
	elif [ "${shortname}" == "cod4" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDuty4/cod4x18_1790_lnxded.tar.xz"; local_filedir="${tmpdir}"; local_filename="cod4x18_1790_lnxded.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="30609db2afde09d22498fbab3a427d11"
	elif [ "${shortname}" == "codwaw" ]; then
		remote_fileurl="http://linuxgsm.download/CallOfDutyWorldAtWar/codwaw-lnxded-1.7-full.tar.xz"; local_filedir="${tmpdir}"; local_filename="codwaw-lnxded-1.7-full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="2c6be1bb66ea631b9b2e7ae6216c6680"
	elif [ "${shortname}" == "etl" ]; then
		remote_fileurl="http://linuxgsm.download/WolfensteinEnemyTerritory/etlegacy-v2.76-i386-et-260b.tar.xz"; local_filedir="${tmpdir}"; local_filename="etlegacy-v2.75-i386-et-260b.tar.bz2"; chmodx="nochmodx" run="norun"; force="noforce"; md5="178a00233cec1e25b69d130107ce1a79"
	elif [ "${shortname}" == "ges" ]; then
		remote_fileurl="http://linuxgsm.download/GoldenEyeSource/GoldenEye_Source_v5.0.6_full_server.tar.xz"; local_filedir="${tmpdir}"; local_filename="GoldenEye_Source_v5.0.6_full_server.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="e31481f280eed40c9145816bd4f6dc45"
	elif [ "${shortname}" == "mohaa" ]; then
		remote_fileurl="http://linuxgsm.download/MedalofHonorAlliedAssault/moh_revival_v1.12_RC3.5.1.tar.xz"; local_filedir="${tmpdir}"; local_filename="moh_revival_v1.12_RC3.5.1.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="7c664538999252eeaf2b6d9949416480"
	elif [ "${shortname}" == "ns" ]; then
		remote_fileurl="http://linuxgsm.download/NaturalSelection/ns_dedicated_server_v32.tar.xz"; local_filedir="${tmpdir}"; local_filename="ns_dedicated_server_v32.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="23ec3cadd93d8bb1c475bad5b9cce370"
	elif [ "${shortname}" == "q2" ]; then
		remote_fileurl="http://linuxgsm.download/Quake2/quake2-3.20-glibc-i386-full-linux2.0.tar.xz"; local_filedir="${tmpdir}"; local_filename="quake2-3.20-glibc-i386-full-linux2.0.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="2908164a32d4808bb720f2161f6b0c82"
	elif [ "${shortname}" == "q3" ]; then
		remote_fileurl="http://linuxgsm.download/Quake3/quake3-1.32c-x86-full-linux.tar.xz"; local_filedir="${tmpdir}"; local_filename="quake3-1.32c-x86-full-linux.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="b0e26d8919fe9313fb9d8ded2360f3db"
	elif [ "${shortname}" == "qw" ]; then
		remote_fileurl="http://linuxgsm.download/QuakeWorld/nquake.server.linux.190506.full.tar.xz"; local_filedir="${tmpdir}"; local_filename="nquake.server.linux.190506.full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="82055b7d973206c13a606db8ba288d03"
	elif [ "${shortname}" == "rtcw" ]; then
		remote_fileurl="http://linuxgsm.download/ReturnToCastleWolfenstein/iortcw-1.51c-x86_64-server-linux-20190507.tar.xz"; local_filedir="${tmpdir}"; local_filename="iortcw-1.51c-x86_64-server-linux-20190507.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="df6ff664d37dd0d22787848bdb3cac5f"
	elif [ "${shortname}" == "sfc" ]; then
		remote_fileurl="http://linuxgsm.download/SourceFortsClassic/SFClassic-1.0-RC7-fix.tar.xz"; local_filedir="${tmpdir}"; local_filename="SFClassic-1.0-RC7-fix.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="70077137185700e28fe6bbb6021d12bc"
	elif [ "${shortname}" == "sof2" ]; then
		remote_fileurl="http://linuxgsm.download/SoldierOfFortune2/sof2gold-1.03.tar.xz"; local_filedir="${tmpdir}"; local_filename="sof2gold-1.03.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="201e23bab04207d00ce813d001c483d9"
	elif [ "${shortname}" == "ts" ]; then
		remote_fileurl="http://linuxgsm.download/TheSpecialists/ts-3-linux-final.tar.xz"; local_filedir="${tmpdir}"; local_filename="ts-3-linux-final.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="3c66ecff6e3644f7ac88015732a0fb93"
	elif [ "${shortname}" == "ut2k4" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament2004/ut2004-server-3369-2-ultimate-linux.tar.xz"; local_filedir="${tmpdir}"; local_filename="ut2004-server-3369-2-ultimate-linux.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="8ebcb9b8f703905053d13a35c3af3e79"
	elif [ "${shortname}" == "ut99" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament99/ut99-server-451-ultimate-linux.tar.xz"; local_filedir="${tmpdir}"; local_filename="ut99-server-451-ultimate-linux.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="42c6839f8cb95907eeef71a1838aa1f7"
	elif [ "${shortname}" == "ut" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament/UnrealTournament-Server-XAN-3525360-Linux.tar.xz"; local_filedir="${tmpdir}"; local_filename="UnrealTournament-Server-XAN-3525360-Linux.tar.xz";  chmodx="noexecute" run="norun"; force="noforce"; md5="41dd92015713a78211eaccf503b72393"
	elif [ "${shortname}" == "ut3" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament3/UT3-linux-server-2.1.tar.xz"; local_filedir="${tmpdir}"; local_filename="UT3-linux-server-2.1.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="6b92b083c7ab416399e2183a22fda1df"
	elif [ "${shortname}" == "vs" ]; then
		remote_fileurl="http://linuxgsm.download/VampireSlayer/vs_l-6.0_full.tar.xz"; local_filedir="${tmpdir}"; local_filename="vs_l-6.0_full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="b322f79e0abd31847493c52acf802667"
	elif [ "${shortname}" == "wet" ]; then
		remote_fileurl="http://linuxgsm.download/WolfensteinEnemyTerritory/enemy-territory.260b.tar.xz"; local_filedir="${tmpdir}"; local_filename="enemy-territory.260b.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="581a333cc7eacda2f56d5a00fe11eafa"
	elif [ "${shortname}" == "samp" ]; then
		remote_fileurl="https://files.sa-mp.com/samp037svr_R2-1.tar.gz"; local_filedir="${tmpdir}"; local_filename="samp037svr_R2-1.tar.gz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="93705e165550c97484678236749198a4"
	elif [ "${shortname}" == "zmr" ]; then
		remote_fileurl="http://linuxgsm.download/ZombieMasterReborn/zombie_master_reborn_b5_2.tar.xz"; local_filedir="${tmpdir}"; local_filename="zombie_master_reborn_b5_2.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="4b9b9832e863d03981a40c26065792a6"
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
				# If GoldSrc (appid 90) servers. GoldSrc (appid 90) require extra commands.
				if [ "${appid}" == "90" ]; then
					# If using a specific branch.
					if [ -n "${branch}" ]; then
							${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" +quit
					else
							${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" +quit
					fi
				elif [ "${shortname}" == "ac" ]; then
					${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" +quit
				# All other servers.
				else
					if [ -n "${branch}" ]; then
						${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update -beta "${branch}" +quit
					else
						${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" +quit
					fi
				fi
				local exitcode=$?
			elif [ "${counter}" -ge "5" ]; then
				# If GoldSrc (appid 90) servers. GoldSrc (appid 90) require extra commands.
				if [ "${appid}" == "90" ]; then
					# If using a specific branch.
					if [ -n "${branch}" ]; then
						${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" validate +quit
					else
						${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" validate +quit
					fi
					local exitcode=$?
				elif [ "${shortname}" == "ac" ]; then
					${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" +quit
					local exitcode=$?
				# All other servers.
				else
					if [ -n "${branch}" ]; then
						${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" -beta "${branch}" validate +quit
					else
						${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_update "${appid}" validate +quit
					fi
					local exitcode=$?
				fi
			fi
		elif [ "${counter}" -ge "11" ]; then
			fn_print_failure_nl "SteamCMD did not complete the download, too many retrys"
			fn_script_log "SteamCMD did not complete the download, too many retrys"
			break
		fi
	done

	# GoldSrc (appid 90) servers commonly fail to download all the server files required.
	# Validating a few of times may reduce the chance of this issue.
	if [ "${appid}" == "90" ]; then
		fn_print_information_nl "GoldSrc servers commonly fail to download all the server files required. Validating a few of times may reduce the chance of this issue."
		counter="0"
		while [ "${counter}" -le "4" ]; do
			counter=$((counter+1))
			if [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" "${branch}" validate +quit
			else
				${unbuffer} ${steamcmdcommand} +login "${steamuser}" "${steampass}" +force_install_dir "${serverfiles}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" validate +quit
			fi
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
