#!/bin/bash
# LinuxGSM install_server_files.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs server files.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_server_files() {
	if [ "${shortname}" == "ahl" ]; then
		remote_fileurl="https://linuxgsm.download/ActionHalfLife/ahl-1.0-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ahl-1.0-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="4b502ed86fafd44b9b9dda99ee4cb44f"
	elif [ "${shortname}" == "bf1942" ]; then
		remote_fileurl="https://linuxgsm.download/BattleField1942/bf1942_lnxded-1.61-hacked-to-1.612.full-linuxgsm.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="bf1942_lnxded-1.61-hacked-to-1.612.full-linuxgsm.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="d58016b3c45f86a71bb56c39749ce941"
	elif [ "${shortname}" == "bfv" ]; then
		remote_fileurl="https://linuxgsm.download/BattlefieldVietnam/bfv_linded-v1.21-20041207_patch-linuxgsm.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="bfv_linded-v1.21-20041207_patch-linuxgsm.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="9a8117732b8abd99cc59f1f0fa92adfa"

	elif [ "${shortname}" == "cod" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDuty/cod-1.5b-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod-1.5b-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="a588df9db95f64ce5b5065fd94995bc1"
	elif [ "${shortname}" == "coduo" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDutyUnitedOffensive/coduo-1.51b-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="coduo-1.51b-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="deb2f9a66c9f3c7a23099c31c98242d0"
	elif [ "${shortname}" == "cod2" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDuty2/cod2-lnxded-1.3-full.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod2-lnxded-1.3-full.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="b8c4c611f01627dd43348e78478a3d41"
	elif [ "${shortname}" == "cod4" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDuty4/cod4x-21.2-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod4x-21.2-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="7c8d55d12e44f321f31ad1320567659a"
	elif [ "${shortname}" == "codwaw" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDutyWorldAtWar/codwaw-lnxded-1.7-full.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="codwaw-lnxded-1.7-full.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="2c6be1bb66ea631b9b2e7ae6216c6680"
	elif [ "${shortname}" == "cswon" ]; then
		remote_fileurl="https://linuxgsm.download/CounterStrikeWON2/cswon-3111e-cs15-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cswon-3111e-cs15-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="0be5f9f766e48b8bbd480dfa4a9d9aa0"
	elif [ "${shortname}" == "hlwon" ]; then
		remote_fileurl="https://linuxgsm.download/HalfLifeWON2/hlwon-3111e-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="hlwon-3111e-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="e64fda09d31f3acc977fb621b5ffd4fd"
	elif [ "${shortname}" == "mohaa" ]; then
		remote_fileurl="https://linuxgsm.download/MedalofHonorAlliedAssault/mohaa-1.12-rc3.5.1-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="mohaa-1.12-rc3.5.1-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="bf66cbe1f4aefb221e17924e7bf9bdb4"
	elif [ "${shortname}" == "ns" ]; then
		remote_fileurl="https://linuxgsm.download/NaturalSelection/ns-3.2-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ns-3.2-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="a44d9769f9a035b98a4d57a7d7e1f81b"
	elif [ "${shortname}" == "q2" ]; then
		remote_fileurl="https://linuxgsm.download/Quake2/q2-3.20-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="q2-3.20-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="f0abe39ed649765cd99b7e5e1c62b4f6"
	elif [ "${shortname}" == "q3" ]; then
		remote_fileurl="https://linuxgsm.download/Quake3/quake3-1.32c-x86-full-linux.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="quake3-1.32c-x86-full-linux.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="b0e26d8919fe9313fb9d8ded2360f3db"
	elif [ "${shortname}" == "q4" ]; then
		remote_fileurl="https://linuxgsm.download/Quake4/quake4-1.4.2-x86-linuxded.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="quake4-1.4.2-x86-linuxded.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="afe30b44f23c8ae2ce6f0f464473d8ba"
	elif [ "${shortname}" == "qw" ]; then
		remote_fileurl="https://linuxgsm.download/QuakeWorld/nquake.server.linux.190506.full.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="nquake.server.linux.190506.full.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="82055b7d973206c13a606db8ba288d03"
	elif [ "${shortname}" == "rtcw" ]; then
		remote_fileurl="https://linuxgsm.download/ReturnToCastleWolfenstein/rtcw-iortcw-1.51c-linux-amd64-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="rtcw-iortcw-1.51c-linux-amd64-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="6bb410ac0faf9048c2ca8f918b068ed0"
	elif [ "${shortname}" == "sfc" ]; then
		remote_fileurl="https://linuxgsm.download/SourceFortsClassic/sfc-1.0-rc7-fix-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="sfc-1.0-rc7-fix-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="a0e3980e944cd321c5f064d752a7431e"
	elif [ "${shortname}" == "sof2" ]; then
		remote_fileurl="https://linuxgsm.download/SoldierOfFortune2/sof2gold-1.03.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="sof2gold-1.03.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="201e23bab04207d00ce813d001c483d9"
	elif [ "${shortname}" == "ts" ]; then
		remote_fileurl="https://linuxgsm.download/TheSpecialists/ts-3.0-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ts-3.0-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="4ff0fdc126ec09c07d6a6f915cb9145f"
	elif [ "${shortname}" == "ut2k4" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament2004/ut2k4-3369.3-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ut2k4-3369.3-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="f0ce6b3d3c7831e1a45e2a436a6aaa3b"
	elif [ "${shortname}" == "ut99" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament99/ut99-469b-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ut99-469b-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="ccb9b0907f2f926204c911c3041df743"
	elif [ "${shortname}" == "ut" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament/ut-xan-3525360-linux-amd64-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ut-xan-3525360-linux-amd64-linuxgsm-20261102.tar.xz"
		chmodx="noexecute"
		run="norun"
		force="noforce"
		md5="ffcb25dd03d82489e0cb3d6b9779e818"
	elif [ "${shortname}" == "ut3" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament3/ut3-2.1-openspy-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ut3-2.1-openspy-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="a1ca829bd56d9a1abd17bf129e2bcb77"
	elif [ "${shortname}" == "vs" ]; then
		remote_fileurl="https://linuxgsm.download/VampireSlayer/vs-6.0-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="vs-6.0-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="c1f908ab27772d8c6ca8ee731d32ddda"
	elif [ "${shortname}" == "wet" ]; then
		remote_fileurl="https://linuxgsm.download/WolfensteinEnemyTerritory/enemy-territory.260b.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="enemy-territory.260b.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="581a333cc7eacda2f56d5a00fe11eafa"
	elif [ "${shortname}" == "samp" ]; then
		remote_fileurl="https://files.samp-sc.com/samp037svr_R2-1.tar.gz"
		local_filedir="${tmpdir}"
		local_filename="samp037svr_R2-1.tar.gz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="93705e165550c97484678236749198a4"
	elif [ "${shortname}" == "zmr" ]; then
		remote_fileurl="https://linuxgsm.download/ZombieMasterReborn/zmr-b6.1-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="zmr-b6.1-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="f451da013ed386d3081dfcfc390c7723"
	else
		fn_print_fail_nl "Installing ${gamename} Server failed, missing default configuration"
		fn_script_log_fail "Installing ${gamename} Server failed, missing default configuration"
		core_exit.sh
	fi
	fn_fetch_file "${remote_fileurl}" "" "" "" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
	fn_dl_extract "${local_filedir}" "${local_filename}" "${serverfiles}"
	fn_clear_tmp
}

if [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ] || [ "${shortname}" == "scpsl" ] || [ "${shortname}" == "ut" ]; then
	install_eula.sh
fi

echo -e ""
echo -e "${bold}${lightyellow}Installing ${gamename} Server${default}"
fn_messages_separator

if [ "${appid}" ]; then
	remotelocation="SteamCMD"
	forceupdate=1
	update_steamcmd.sh
	fn_check_steamcmd_appmanifest
fi

if [ "${shortname}" == "ts3" ]; then
	update_ts3.sh
elif [ "${shortname}" == "mc" ]; then
	update_mc.sh
elif [ "${shortname}" == "mcb" ]; then
	update_mcb.sh
elif [ "${shortname}" == "pmc" ]; then
	update_pmc.sh
elif [ "${shortname}" == "wmc" ] || [ "${shortname}" == "vpmc" ]; then
	update_pmc.sh
elif [ "${shortname}" == "mta" ]; then
	update_mta.sh
elif [ "${shortname}" == "fctr" ]; then
	update_fctr.sh
	install_factorio_save.sh
elif [ "${shortname}" == "fivem" ]; then
	update_fivem.sh
elif [ "${shortname}" == "hyt" ]; then
	update_hyt.sh
elif [ "${shortname}" == "jk2" ]; then
	update_jk2.sh
elif [ "${shortname}" == "jk3" ]; then
	update_jk3.sh
elif [ "${shortname}" == "luanti" ]; then
	update_luanti.sh
elif [ "${shortname}" == "orar" ]; then
	update_openra.sh
elif [ "${shortname}" == "vints" ]; then
	update_vints.sh
elif [ "${shortname}" == "bfe" ]; then
	update_bfe.sh
elif [ "${shortname}" == "bb" ]; then
	update_bb.sh
elif [ "${shortname}" == "ut99" ]; then
	fn_install_server_files
	update_ut99.sh
elif [ "${shortname}" == "xnt" ]; then
	update_xnt.sh
elif [ "${shortname}" == "etl" ]; then
	update_etl.sh
elif [ -z "${appid}" ] || [ "${shortname}" == "ahl" ] || [ "${shortname}" == "q4" ] || [ "${shortname}" == "ns" ] || [ "${shortname}" == "sfc" ] || [ "${shortname}" == "ts" ] || [ "${shortname}" == "vs" ] || [ "${shortname}" == "zmr" ]; then
	if [ "${shortname}" == "ut" ]; then
		install_eula.sh
	fi
	fn_install_server_files
fi

if [ -z "${autoinstall}" ]; then
	echo -e ""
	if ! fn_prompt_yn "Was the install successful?" Y; then
		install_retry.sh
	fi
fi
