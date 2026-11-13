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
		remote_fileurl="https://linuxgsm.download/BattleField1942/bf1942-1.612-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="bf1942-1.612-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="0a3ae8721d3b14d81912b01fbfbd5cb2"
	elif [ "${shortname}" == "bfv" ]; then
		remote_fileurl="https://linuxgsm.download/BattlefieldVietnam/bfv-1.21-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="bfv-1.21-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="532bc18529c7cb86fb41c79ec61c5283"

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
		remote_fileurl="https://linuxgsm.download/CallOfDuty2/cod2-1.3-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod2-1.3-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="e7dfaaf11f3f714c60e2ac1057476aa4"
	elif [ "${shortname}" == "cod4" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDuty4/cod4x-21.2-linux-i386-linuxgsm-20261102.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod4x-21.2-linux-i386-linuxgsm-20261102.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="7c8d55d12e44f321f31ad1320567659a"
	elif [ "${shortname}" == "codwaw" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDutyWorldAtWar/codwaw-1.7-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="codwaw-1.7-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="d7bdc6b2a671c3e07184e1a3262ec14c"
	elif [ "${shortname}" == "cswon" ]; then
		remote_fileurl="https://linuxgsm.download/CounterStrikeWON2/cswon-3111e-cs15-linux-i386-linuxgsm-20261104.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cswon-3111e-cs15-linux-i386-linuxgsm-20261104.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="97f91d5a3b70ddff0fc9b2fd4ea1cfd6"
	elif [ "${shortname}" == "hlwon" ]; then
		remote_fileurl="https://linuxgsm.download/HalfLifeWON2/hlwon-3111e-linux-i386-linuxgsm-20261104.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="hlwon-3111e-linux-i386-linuxgsm-20261104.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="d4a57dc07648853138a700cacc84aef2"
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
		remote_fileurl="https://linuxgsm.download/Quake3/q3-1.32c-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="q3-1.32c-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="e6c958f4e01845d06bd5b8f3835bafa0"
	elif [ "${shortname}" == "q4" ]; then
		remote_fileurl="https://linuxgsm.download/Quake4/q4-1.4.2-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="q4-1.4.2-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="7aaa88fb0ba0c533fe23b7b993fd6530"
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
		remote_fileurl="https://linuxgsm.download/SoldierOfFortune2/sof2-1.03-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="sof2-1.03-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="d8cd9ad624290a1de1c72e43aa35195e"
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
		remote_fileurl="https://linuxgsm.download/WolfensteinEnemyTerritory/wet-2.60b-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="wet-2.60b-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="60b7483c22db98effc3622dbb9e5710f"
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
	fn_fetch_file "${remote_fileurl}" "" "" "" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${force}" "${md5}"
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
elif [ "${shortname}" == "tm2020" ]; then
	update_tm2020.sh
elif [ "${shortname}" == "bmp" ]; then
	update_bmp.sh
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
elif [ "${shortname}" == "qw" ]; then
	update_qw.sh
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
