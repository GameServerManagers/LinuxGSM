#!/bin/bash
# LinuxGSM install_server_files.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs server files.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_server_files(){
	if [ "${shortname}" == "ahl" ]; then
		remote_fileurl="http://linuxgsm.download/ActionHalfLife/action_halflife-1.0.tar.xz"; local_filedir="${tmpdir}"; local_filename="action_halflife-1.0.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="61d7b79fd714888b6d65944fdaafa94a"
	elif [ "${shortname}" == "bf1942" ]; then
		remote_fileurl="http://linuxgsm.download/BattleField1942/bf1942_lnxded-1.61-hacked-to-1.612.full.tar.xz"; local_filedir="${tmpdir}"; local_filename="bf1942_lnxded-1.61-hacked-to-1.612.full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="4223bf4ed85f5162c24b2cba51249b9e"
	elif [ "${shortname}" == "bfv" ];then
		remote_fileurl="http://linuxgsm.download/BattlefieldVietnam/bfv_linded-v1.21-20041207_patch.tar.xz"; local_filedir="${tmpdir}"; local_filename="bfv_linded-v1.21-20041207_patch.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="e3b4962cdd9d41e23c6fed65101bccde"
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
		remote_fileurl="http://linuxgsm.download/UnrealTournament2004/ut2004-server-3369-3-ultimate-linux.tar.xz"; local_filedir="${tmpdir}"; local_filename="ut2004-server-3369-3-ultimate-linux.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="9fceaab68554749f4b45be66613b9a15"
	elif [ "${shortname}" == "ut99" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament99/ut99-server-469a-ultimate-linux.tar.xz"; local_filedir="${tmpdir}"; local_filename="ut99-server-469a-ultimate-linux.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="e3f2ffaab8e23b98d9e825d0244e8b9d"
	elif [ "${shortname}" == "ut" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament/UnrealTournament-Server-XAN-3525360-Linux.tar.xz"; local_filedir="${tmpdir}"; local_filename="UnrealTournament-Server-XAN-3525360-Linux.tar.xz";  chmodx="noexecute" run="norun"; force="noforce"; md5="41dd92015713a78211eaccf503b72393"
	elif [ "${shortname}" == "ut3" ]; then
		remote_fileurl="http://linuxgsm.download/UnrealTournament3/UT3-linux-server-2.1.tar.xz"; local_filedir="${tmpdir}"; local_filename="UT3-linux-server-2.1.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="8876cca61e3f83ea08db25208bde6ac6"
	elif [ "${shortname}" == "vs" ]; then
		remote_fileurl="http://linuxgsm.download/VampireSlayer/vs_l-6.0_full.tar.xz"; local_filedir="${tmpdir}"; local_filename="vs_l-6.0_full.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="b322f79e0abd31847493c52acf802667"
	elif [ "${shortname}" == "wet" ]; then
		remote_fileurl="http://linuxgsm.download/WolfensteinEnemyTerritory/enemy-territory.260b.tar.xz"; local_filedir="${tmpdir}"; local_filename="enemy-territory.260b.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="581a333cc7eacda2f56d5a00fe11eafa"
	elif [ "${shortname}" == "samp" ]; then
		remote_fileurl="https://files.sa-mp.com/samp037svr_R2-1.tar.gz"; local_filedir="${tmpdir}"; local_filename="samp037svr_R2-1.tar.gz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="93705e165550c97484678236749198a4"
	elif [ "${shortname}" == "zmr" ]; then
		remote_fileurl="http://linuxgsm.download/ZombieMasterReborn/zombie_master_reborn_b5_2.tar.xz"; local_filedir="${tmpdir}"; local_filename="zombie_master_reborn_b5_2.tar.xz"; chmodx="nochmodx" run="norun"; force="noforce"; md5="4b9b9832e863d03981a40c26065792a6"
	fi
	fn_fetch_file "${remote_fileurl}" "" "" "" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
	fn_dl_extract "${local_filedir}" "${local_filename}" "${serverfiles}"
}

echo -e ""
echo -e "${lightyellow}Installing ${gamename} Server${default}"
echo -e "================================="
fn_sleep_time

if [ "${appid}" ]; then
	fn_dl_steamcmd
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
elif [ "${shortname}" == "jk2" ]; then
	update_jediknight2.sh
elif [ "${shortname}" == "vints" ]; then
	update_vintagestory.sh
elif [ -z "${appid}" ]||[ "${shortname}" == "ahl" ]||[ "${shortname}" == "bd" ]||[ "${shortname}" == "bb" ]||[ "${shortname}" == "ns" ]||[ "${shortname}" == "sfc" ]||[ "${shortname}" == "ts" ]||[ "${shortname}" == "vs" ]||[ "${shortname}" == "zmr" ]; then
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
