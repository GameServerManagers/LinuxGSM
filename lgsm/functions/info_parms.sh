#!/bin/bash
# LinuxGSM info_parms.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: If specific parms are not set then this will be displayed in details.

local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

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

fn_info_parms_realvirtuality(){
	port=${port:-"0"}
	queryport=$((port + 1))
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

fn_info_parms_eco(){
	queryport=${webadminport}
}

fn_info_parms_factorio(){
	port=${port:-"0"}
	rconport=${rconport:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
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

fn_info_parms_hurtworld(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	maxplayers=${maxplayers:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
	creativemode=${creativemode:-"NOT SET"}
}

fn_info_parms_projectzomboid(){
	adminpassword=${adminpassword:-"NOT SET"}
}

fn_info_parms_quakeworld(){
	port=${port:-"0"}
	queryport=${port}
}

fn_info_parms_quake2(){
	port=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_risingworld(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${port}
	httpqueryport=$((port - 1))

}

fn_info_parms_rtcw(){
	port=${port:-"0"}
	queryport="${port}"
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_parms_rust(){
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${port}
	rconport=${rconport:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
	rconweb=${rconweb:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	saveinterval=${saveinterval:-"0"}
	tickrate=${tickrate:-"0"}
}

fn_info_parms_source(){
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port}
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

fn_info_config_towerunite(){
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
	serverpassword=${serverpassword:-"NOT SET"}
	adminpassword=${adminpassword:-"NOT SET"}
}

fn_info_parms_unturned(){
	servername=${servicename:-"NOT SET"}
	port=${port:-"0"}
	queryport=${port}
}
fn_info_parms_kf2(){
	queryport=${queryport:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

# ARK: Survival Evolved
if [ "${shortname}" == "ark" ]; then
	fn_info_parms_ark
# ARMA 3
elif [ "${shortname}" == "arma3" ]; then
	fn_info_parms_realvirtuality
# Call of Duty
elif [ "${shortname}" == "cod" ]||[ "${shortname}" == "coduo" ]||[ "${engine}" == "iw2.0" ]||[ "${engine}" == "iw3.0" ]; then
	fn_info_parms_cod
# Eco
elif [ "${shortname}" == "eco" ]; then
	fn_info_parms_eco
# Factorio
elif [ "${shortname}" == "fctr" ]; then
	fn_info_parms_factorio
elif [ "${shortname}" == "inss" ]; then
	fn_info_parms_inss
elif [ "${shortname}" == "kf2" ]; then
	fn_info_parms_kf2
# Project Zomboid
elif [ "${shortname}" == "pz" ]; then
	fn_info_parms_projectzomboid
elif [ "${shortname}" == "qw" ]; then
	fn_info_parms_quakeworld
elif [ "${shortname}" == "q2" ]||[ "${shortname}" == "q3" ]; then
	fn_info_parms_quake2
elif [ "${shortname}" == "rtcw" ]; then
	fn_info_parms_rtcw
# Rust
elif [ "${shortname}" == "rust" ]; then
	fn_info_parms_rust
# Rising World
elif [ "${shortname}" == "rw" ]; then
	fn_info_parms_risingworld
# Sticky Bots
elif [ "${shortname}" == "sbots" ]; then
	fn_info_parms_stickybots
# Serious Sam
elif [ "${shortname}" == "ss3" ]; then
	fn_info_config_seriousengine35
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	fn_info_parms_source
# Spark
elif [ "${engine}" == "spark" ]; then
	fn_info_parms_spark
elif [ "${shortname}" == "tu" ]; then
	fn_info_config_towerunite
# Unreal/Unreal 2 engine
elif [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	fn_info_parms_unreal
# Unreal 3 engine
elif [ "${engine}" == "unreal3" ]; then
	fn_info_parms_unreal3
elif [ "${shortname}" == "unt" ]; then
	fn_info_parms_unturned
fi
