#!/bin/bash
# LinuxGSM install_server_files.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs server files.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_server_files() {
	if [ "${shortname}" == "ahl" ]; then
		remote_fileurl="https://linuxgsm.download/ActionHalfLife/action_halflife-1.0.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="action_halflife-1.0.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="61d7b79fd714888b6d65944fdaafa94a"
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
		remote_fileurl="https://linuxgsm.download/CallOfDuty/cod-lnxded-1.5b-full.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod-lnxded-1.5-large.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="ee0ad1ccbfa1fd27fde01a4a431a5c2f"
	elif [ "${shortname}" == "coduo" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDutyUnitedOffensive/coduo-lnxded-1.51b-full.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="coduo-lnxded-1.51b-full.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="35cabccd67adcda44aaebc59405915b9"
	elif [ "${shortname}" == "cod2" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDuty2/cod2-1.3-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod2-1.3-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="e7dfaaf11f3f714c60e2ac1057476aa4"
	elif [ "${shortname}" == "cod4" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDuty4/cod4x18_lnxded.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="cod4x18_lnxded.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="d255b59b9756d7dbead67718208512ee"
	elif [ "${shortname}" == "codwaw" ]; then
		remote_fileurl="https://linuxgsm.download/CallOfDutyWorldAtWar/codwaw-1.7-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="codwaw-1.7-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="d7bdc6b2a671c3e07184e1a3262ec14c"
	elif [ "${shortname}" == "cswon" ]; then
		remote_fileurl="https://linuxgsm.download/CounterStrikeWON2/hlds_l-3111e-cs15-won2-linuxgsm.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="hlds_l-3111e-cs15-won2-linuxgsm.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="8109a66e2e906ff2c309e3a6b412132a"
	elif [ "${shortname}" == "hlwon" ]; then
		remote_fileurl="https://linuxgsm.download/HalfLifeWON2/hlds_l-3111e-won2-linuxgsm.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="hlds_l-3111e-won2-linuxgsm.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="83164405c744a5e424814e67eacf27fb"
	elif [ "${shortname}" == "mohaa" ]; then
		remote_fileurl="https://linuxgsm.download/MedalofHonorAlliedAssault/moh_revival_v1.12_RC3.5.1.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="moh_revival_v1.12_RC3.5.1.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="7c664538999252eeaf2b6d9949416480"
	elif [ "${shortname}" == "ns" ]; then
		remote_fileurl="https://linuxgsm.download/NaturalSelection/ns_dedicated_server_v32.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ns_dedicated_server_v32.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="23ec3cadd93d8bb1c475bad5b9cce370"
	elif [ "${shortname}" == "q2" ]; then
		remote_fileurl="https://linuxgsm.download/Quake2/quake2-3.20-glibc-i386-full-linux2.0.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="quake2-3.20-glibc-i386-full-linux2.0.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="2908164a32d4808bb720f2161f6b0c82"
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
	elif [ "${shortname}" == "qw" ]; then
		remote_fileurl="https://linuxgsm.download/QuakeWorld/nquake.server.linux.190506.full.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="nquake.server.linux.190506.full.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="82055b7d973206c13a606db8ba288d03"
	elif [ "${shortname}" == "rtcw" ]; then
		remote_fileurl="https://linuxgsm.download/ReturnToCastleWolfenstein/iortcw-1.51c-x86_64-server-linux-20190507.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="iortcw-1.51c-x86_64-server-linux-20190507.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="df6ff664d37dd0d22787848bdb3cac5f"
	elif [ "${shortname}" == "sfc" ]; then
		remote_fileurl="https://linuxgsm.download/SourceFortsClassic/SFClassic-1.0-RC7-fix.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="SFClassic-1.0-RC7-fix.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="70077137185700e28fe6bbb6021d12bc"
	elif [ "${shortname}" == "sof2" ]; then
		remote_fileurl="https://linuxgsm.download/SoldierOfFortune2/sof2-1.03-linux-i386-linuxgsm-20261101.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="sof2-1.03-linux-i386-linuxgsm-20261101.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="d8cd9ad624290a1de1c72e43aa35195e"
	elif [ "${shortname}" == "ts" ]; then
		remote_fileurl="https://linuxgsm.download/TheSpecialists/ts-3-linux-final.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ts-3-linux-final.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="3c66ecff6e3644f7ac88015732a0fb93"
	elif [ "${shortname}" == "ut2k4" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament2004/ut2004-server-3369-3-ultimate-linux.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ut2004-server-3369-3-ultimate-linux.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="9fceaab68554749f4b45be66613b9a15"
	elif [ "${shortname}" == "ut99" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament99/ut99-server-469b-ultimate-linux.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="ut99-server-469b-ultimate-linux.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="dba3f1122a5e60ee45ece7422fcf78f5"
	elif [ "${shortname}" == "ut" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament/UnrealTournament-Server-XAN-3525360-Linux.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="UnrealTournament-Server-XAN-3525360-Linux.tar.xz"
		chmodx="noexecute"
		run="norun"
		force="noforce"
		md5="41dd92015713a78211eaccf503b72393"
	elif [ "${shortname}" == "ut3" ]; then
		remote_fileurl="https://linuxgsm.download/UnrealTournament3/UT3-linux-server-2.1-openspy.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="UT3-linux-server-2.1-openspy.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="f60b745613a8676666eb6a2450cbdc8e"
	elif [ "${shortname}" == "vs" ]; then
		remote_fileurl="https://linuxgsm.download/VampireSlayer/vs_l-6.0_full.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="vs_l-6.0_full.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="b322f79e0abd31847493c52acf802667"
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
		remote_fileurl="https://linuxgsm.download/ZombieMasterReborn/zombie_master_reborn_b6_1.tar.xz"
		local_filedir="${tmpdir}"
		local_filename="zombie_master_reborn_b6_1.tar.xz"
		chmodx="nochmodx"
		run="norun"
		force="noforce"
		md5="0188ae86dbc9376f11ae3032dba2d665"
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
