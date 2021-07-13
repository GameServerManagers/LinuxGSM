#!/bin/bash
# LinuxGSM info_parms.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: If specific parms are not set then this will be displayed in details.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

unavailable="${red}UNAVAILABLE${default}"
zero="${red}0${default}"

fn_info_parms_ark(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	rconport=${rconport:-"0"}
	rawport=$((port+1))
	maxplayers=${maxplayers:-"0"}
}

fn_info_parms_bt(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
}

fn_info_parms_bt1944(){
	port=${port:-"0"}
	rconport=$((port+2))
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

fn_info_parms_fctr(){
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
	rconport=${rconport:-"0"}
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	defaultmap=${defaultmap:-"NOT SET"}
	defaultscenario=${defaultscenario:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_parms_kf2(){
	queryport=${queryport:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_mh(){
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
	queryport=$((port+123))
}

fn_info_parms_pz(){
	adminpassword=${adminpassword:-"NOT SET"}
	queryport=${port:-"0"}
}

fn_info_parms_qw(){
	port=${port:-"0"}
	queryport=${port:-"0"}
}

fn_info_parms_quake2(){
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_arma3(){
	port=${port:-"2302"}
	voiceport=${port:-"2302"}
	queryport=$((port+1))
	steammasterport=$((port+2))
	voiceunusedport=$((port+3))
	battleeyeport=$((port+4))
}

fn_info_parms_rw(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	httpqueryport=$((port-1))
}

fn_info_parms_rtcw(){
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_rust(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${port:-"0"}
	appport=${appport:-"0"}
	rconport=${rconport:-"0"}
	gamemode=${gamemode:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
	rconweb=${rconweb:-"NOT SET"}
	tickrate=${tickrate:-"0"}
	saveinterval=${saveinterval:-"0"}
	serverlevel=${serverlevel:-"NOT SET"}
	worldsize=${worldsize:-"0"}
}

fn_info_parms_samp(){
	queryport=${port:-"0"}
}

fn_info_parms_source(){
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	rconport=${port:-"0"}
	queryport=${port:-"0"}
	clientport=${clientport:-"0"}
	# Steamport can be between 26901-26910 and is normaly automaticly set.
	# Some servers might support -steamport parameter to set
	if [ "${steamport}" == "0" ]||[ -z "${steamport}" ]; then
		steamport="$(echo "${ssinfo}" | grep "${srcdslinuxpid}" | awk '{print $5}' | grep ":269" | cut -d ":" -f2)"
	fi
	steamport="${steamport:-"0"}"
}

fn_info_parms_spark(){
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=$((port+1))
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	webadminuser=${webadminuser:-"NOT SET"}
	webadminpass=${webadminpass:-"NOT SET"}
	webadminport=${webadminport:-"0"}
	# Commented out as displaying not set in details parameters
	#mods=${mods:-"NOT SET"}
}

fn_info_parms_st(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	httpport=${port:-"0"}
	worldtype=${worldtype:-"NOT SET"}
	autosaveinterval=${autosaveinterval:-"0"}
	clearinterval=${clearinterval:-"0"}
	worldname=${worldname:-"NOT SET"}

}

fn_info_parms_sbots(){
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

fn_info_parms_tu(){
	port=${port:-"0"}
	steamport=$((port+1))
	queryport=${queryport:-"0"}
}

fn_info_parms_pvr(){
	port=${port:-"0"}
	port401=$((port+400))
	queryport=${port:-"0"}
}

fn_info_parms_unreal(){
	defaultmap=${defaultmap:-"NOT SET"}
	queryport=$((port+1))
}

fn_info_parms_unreal2(){
	defaultmap=${defaultmap:-"NOT SET"}
	queryport=$((port+1))
}

fn_info_parms_ut3(){
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_unt(){
	servername=${selfname:-"NOT SET"}
	port=${port:-"0"}
	queryport=$((port+1))
}

fn_info_parms_ut(){
	port=${port:-"0"}
	queryport=$((port+1))
}

fn_info_parms_vh(){
	port=${port:-"0"}
	if [ "${public}" != "0" ]; then
		queryport=$((port+1))
	else
		querymode="1"
	fi
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
	fn_info_parms_arma3
elif [ "${shortname}" == "bt" ]; then
	fn_info_parms_bt
elif [ "${shortname}" == "bt1944" ]; then
	fn_info_parms_bt1944
elif [ "${shortname}" == "cod" ]||[ "${shortname}" == "coduo" ]||[ "${engine}" == "iw2.0" ]||[ "${engine}" == "iw3.0" ]; then
	fn_info_parms_cod
elif [ "${shortname}" == "fctr" ]; then
	fn_info_parms_fctr
elif [ "${shortname}" == "inss" ]; then
	fn_info_parms_inss
elif [ "${shortname}" == "kf2" ]; then
	fn_info_parms_kf2
elif [ "${shortname}" == "mohaa" ]; then
	fn_info_parms_mohaa
elif [ "${shortname}" == "mom" ]; then
	fn_info_parms_mom
elif [ "${shortname}" == "pz" ]; then
	fn_info_parms_pz
elif [ "${shortname}" == "pvr" ]; then
	fn_info_parms_pvr
elif [ "${shortname}" == "qw" ]; then
	fn_info_parms_qw
elif [ "${shortname}" == "q2" ]||[ "${shortname}" == "q3" ]; then
	fn_info_parms_quake2
elif [ "${shortname}" == "rtcw" ]; then
	fn_info_parms_rtcw
elif [ "${shortname}" == "rust" ]; then
	fn_info_parms_rust
elif [ "${shortname}" == "st" ]; then
	fn_info_parms_st
elif [ "${shortname}" == "rw" ]; then
	fn_info_parms_rw
elif [ "${shortname}" == "sof2" ]; then
	fn_info_parms_sof2
elif [ "${shortname}" == "sbots" ]; then
	fn_info_parms_sbots
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsrc" ]; then
	fn_info_parms_source
elif [ "${engine}" == "spark" ]; then
	fn_info_parms_spark
elif [ "${shortname}" == "tu" ]; then
	fn_info_parms_tu
elif [ "${shortname}" == "vh" ]; then
	fn_info_parms_vh
elif [ "${shortname}" == "mh" ]; then
	fn_info_parms_mh
elif [ "${shortname}" == "mta" ]; then
	fn_info_parms_mta
elif [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	fn_info_parms_unreal
elif [ "${shortname}" == "ut3" ]; then
	fn_info_parms_ut3
elif [ "${shortname}" == "unt" ]; then
	fn_info_parms_unt
elif [ "${shortname}" == "ut" ]; then
	fn_info_parms_ut
elif [ "${shortname}" == "wf" ]; then
	fn_info_parms_wf
# for servers that have a missing queryport from the game config.
elif [ "${shortname}" == "samp" ]||[ "${shortname}" == "scpsl" ]||[ "${shortname}" == "scpslsm" ]||[ "${shortname}" == "jk2" ]||[ "${shortname}" == "tw" ]; then
	fn_info_parms_queryport
fi
