#!/bin/bash
# LinuxGSM info_parms.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: If specific parms are not set then this will be displayed in details.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

## Examples of filtering to get info from config files
# sed 's/foo//g' - remove foo
# tr -cd '[:digit:]' leave only digits
# tr -d '=\"; ' remove selected charectors =\";
# grep -v "foo" filter out lines that contain foo

unavailable="${red}UNAVAILABLE${default}"
zero="${red}0${default}"

fn_info_parms_ark(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	rconport=${rconport:-"0"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_parms_barotrauma(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
}

fn_info_parms_cod(){
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port:-"0"}
}

fn_info_parms_dst(){
	sharding=${sharding:-"NOT SET"}
	master=${master:-"NOT SET"}
	shard=${shard:-"NOT SET"}
	cluster=${cluster:-"NOT SET"}
	cave=${cave:-"NOT SET"}
}

fn_info_parms_factorio(){
	port=${port:-"0"}
	rconport=${rconport:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
}

fn_info_parms_hurtworld(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	maxplayers=${maxplayers:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
	creativemode=${creativemode:-"NOT SET"}
}

fn_info_parms_inss(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	defaultmap=${defaultmap:-"NOT SET"}
	defaultscenario=${defaultscenario:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_parms_jk2(){
	queryport=${port}
}

fn_info_parms_kf2(){
	queryport=${queryport:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_mordhau(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	beaconport=${beaconport:-"0"}
}

fn_info_parms_mohaa(){
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_mom(){
	port=${port:-"7777"}
	beaconport=${queryport:-"15000"}
}

fn_info_parms_mta(){
	queryport=$((port + 123))
}

fn_info_parms_projectzomboid(){
	adminpassword=${adminpassword:-"NOT SET"}
  queryport=${port:-"0"}
}

fn_info_parms_quakeworld(){
	port=${port:-"0"}
	queryport=${port:-"0"}
}

fn_info_parms_quake2(){
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_realvirtuality(){
	port=${port:-"0"}
	queryport=$((port + 1))
}

fn_info_parms_risingworld(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	httpqueryport=$((port - 1))
}

fn_info_parms_rtcw(){
	port=${port:-"0"}
	queryport="${port:-"0"}"
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_rust(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${port:-"0"}
	rconport=${rconport:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
	rconweb=${rconweb:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	saveinterval=${saveinterval:-"0"}
	tickrate=${tickrate:-"0"}
	# Part of random seed feature.
	if [ -z "${seed}" ]; then
		if [ ! -f "${datadir}/${selfname}-seed.txt" ]; then
			shuf -i 1-2147483647 -n 1 > "${datadir}/${selfname}-seed.txt"
		fi
		seed=$(cat "${datadir}/${selfname}-seed.txt")
	fi
}

fn_info_parms_samp(){
	queryport=${port:-"0"}
}

fn_info_parms_sof2(){
	port=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_source(){
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port:-"0"}
	clientport=${clientport:-"0"}
}

fn_info_parms_spark(){
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=$((port + 1))
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	webadminuser=${webadminuser:-"NOT SET"}
	webadminpass=${webadminpass:-"NOT SET"}
	webadminport=${webadminport:-"0"}
	mods=${mods:-"NOT SET"}
}

fn_info_parms_stickybots(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_parms_sof2(){
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_towerunite(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
}

fn_info_parms_teeworlds(){
  queryport=${port:-"0"}
}

fn_info_parms_pavlovvr(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
}

fn_info_parms_unreal(){
	defaultmap=${defaultmap:-"NOT SET"}
	queryport=$((port + 1))
}

fn_info_parms_unreal2(){
	defaultmap=${defaultmap:-"NOT SET"}
	queryport=$((port + 1))
}

fn_info_parms_unreal3(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_unturned(){
	servername=${selfname:-"NOT SET"}
	port=${port:-"0"}
	queryport=$((port + 1))
}

fn_info_parms_ut(){
	port=${port:-"0"}
}

fn_info_parms_vh(){
	port=${port:-"0"}
	queryport=$((port + 1))
	gameworld=${gameworld:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	servername=${servername:-"NOT SET"}
}

fn_info_parms_wf(){
	port=${port:-"0"}
	queryport="${port:-"0"}"
	webadminport=${webadminport:-"0"}
}

fn_info_parms_queryport(){
	queryport="${port:-"0"}"
}

if [ "${shortname}" == "ark" ]; then
	fn_info_parms_ark
elif [ "${shortname}" == "arma3" ]; then
	fn_info_parms_realvirtuality
elif [ "${shortname}" == "bt" ]; then
	fn_info_parms_barotrauma
elif [ "${shortname}" == "cod" ]||[ "${shortname}" == "coduo" ]||[ "${engine}" == "iw2.0" ]||[ "${engine}" == "iw3.0" ]; then
	fn_info_parms_cod
elif [ "${shortname}" == "fctr" ]; then
	fn_info_parms_factorio
elif [ "${shortname}" == "inss" ]; then
	fn_info_parms_inss
elif [ "${shortname}" == "jk2" ]; then
	fn_info_parms_jk2
elif [ "${shortname}" == "kf2" ]; then
	fn_info_parms_kf2
elif [ "${shortname}" == "mohaa" ]; then
	fn_info_parms_mohaa
elif [ "${shortname}" == "mom" ]; then
	fn_info_parms_mom
elif [ "${shortname}" == "pz" ]; then
	fn_info_parms_projectzomboid
elif [ "${shortname}" == "pvr" ]; then
	fn_info_parms_pavlovvr
elif [ "${shortname}" == "qw" ]; then
	fn_info_parms_quakeworld
elif [ "${shortname}" == "q2" ]||[ "${shortname}" == "q3" ]; then
	fn_info_parms_quake2
elif [ "${shortname}" == "rtcw" ]; then
	fn_info_parms_rtcw
elif [ "${shortname}" == "rust" ]; then
	fn_info_parms_rust
elif [ "${shortname}" == "samp" ]; then
  fn_info_parms_samp
elif [ "${shortname}" == "rw" ]; then
	fn_info_parms_risingworld
elif [ "${shortname}" == "sof2" ]; then
	fn_info_parms_sof2
elif [ "${shortname}" == "sbots" ]; then
	fn_info_parms_stickybots
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsrc" ]; then
	fn_info_parms_source
elif [ "${engine}" == "spark" ]; then
	fn_info_parms_spark
elif [ "${shortname}" == "tu" ]; then
	fn_info_parms_towerunite
elif [ "${shortname}" == "tw" ]; then
	fn_info_parms_teeworlds
elif [ "${shortname}" == "vh" ]; then
	fn_info_parms_vh
elif [ "${shortname}" == "mh" ]; then
	fn_info_parms_mordhau
elif [ "${shortname}" == "mta" ]; then
	fn_info_parms_mta
elif [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	fn_info_parms_unreal
elif [ "${engine}" == "unreal3" ]; then
	fn_info_parms_unreal3
elif [ "${shortname}" == "unt" ]; then
	fn_info_parms_unturned
elif [ "${shortname}" == "ut" ]; then
	fn_info_parms_ut
elif [ "${shortname}" == "wf" ]; then
	fn_info_parms_wf
# for servers that have a missing queryport from the config
elif [ "${shortname}" == "scpsl" ]||[ "${shortname}" == "scpslsm" ]; then
	fn_info_parms_queryport
fi
