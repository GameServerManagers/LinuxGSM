#!/bin/bash
# LGSM info_parms.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Gets specific details from server parameters.

local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

## Examples of filtering to get info from config files
# sed 's/foo//g' - remove foo
# tr -cd '[:digit:]' leave only digits
# tr -d '=\"; ' remove selected charectors =\";
# grep -v "foo" filter out lines that contain foo

unavailable="${red}UNAVAILABLE${default}"
zero="${red}0${default}"

fn_info_config_idtech3(){
	# Not Set
	port=${port:-"NOT SET"}
	rconport=${rconport:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
	statsport=${statsport:-"0"}
	statspassword=${statspassword:-"NOT SET"}
	mappool=${mappool:-"NOT SET"}
	rconpassword=${rconpassword:-"NOT SET"}
}

fn_info_config_realvirtuality(){
	port=$(grep "^serverport=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	queryport=$(grep "^steamqueryport=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	masterport=$(grep "^steamport=" "${servercfgfullpath}" | tr -cd '[:digit:]')

	# Not Set
	port=${port:-"2302"}
	queryport=${queryport:-"2303"}
	masterport=${masterport:-"2304"}
}

fn_info_config_source(){
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	clientport=${clientport:-"0"}
}

fn_info_config_teeworlds(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="unnamed server"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		port="8303"
		slots="12"
	else
		servername=$(grep "sv_name" "${servercfgfullpath}" | sed 's/sv_name //g' | sed 's/"//g')
		serverpassword=$(grep "password " "${servercfgfullpath}" | awk '!/sv_rcon_password/'| sed 's/password //g' | tr -d '=\"; ')
		rconpassword=$(grep "sv_rcon_password" "${servercfgfullpath}" | sed 's/sv_rcon_password //g' | tr -d '=\"; ')
		port=$(grep "sv_port" "${servercfgfullpath}" | tr -cd '[:digit:]')
		slots=$(grep "sv_max_clients" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"8303"}
		slots=${slots:-"12"}
	fi
}

fn_info_config_terraria(){
	if [ ! -f "${servercfgfullpath}" ]; then
		port="0"
	else
		port=$(grep "port=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		port=${port:-"0"}
	fi
}

fn_info_config_unreal(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port="${zero}"
		gsqueryport="${zero}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed 's/ServerName=//g')
		serverpassword=$(grep "GamePassword=" "${servercfgfullpath}" | sed 's/GamePassword=//g')
		adminpassword=$(grep "AdminPassword=" "${servercfgfullpath}" | sed 's/AdminPassword=//g')
		port=$(grep "Port=" "${servercfgfullpath}" | grep -v "Master" | grep -v "LAN" | grep -v "Proxy" | grep -v "Listen" | tr -d '\r' | tr -cd '[:digit:]')
		gsqueryport=$(grep "OldQueryPortNumber=" "${servercfgfullpath}" | tr -d '\r' | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled=" "${servercfgfullpath}" | sed 's/bEnabled=//g' | tr -d '\r')
		webadminport=$(grep "ListenPort=" "${servercfgfullpath}" | tr -d '\r' | tr -cd '[:digit:]')
		if [ "${engine}" == "unreal" ]; then
			webadminuser=$(grep "AdminUsername=" "${servercfgfullpath}" | sed 's/\AdminUsername=//g')
			webadminpass=$(grep "UTServerAdmin.UTServerAdmin" "${servercfgfullpath}" -A 2 | grep "AdminPassword=" | sed 's/\AdminPassword=//g')
		else
			webadminuser=$(grep "AdminName=" "${servercfgfullpath}" | sed 's/\AdminName=//g')
			webadminpass=$(grep "AdminPassword=" "${servercfgfullpath}" | sed 's/\AdminPassword=//g')
		fi

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		gsqueryport=${gsqueryport:-"NOT SET"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"NOT SET"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi
}

## Just Cause 2
if [ "${engine}" == "avalanche" ]; then
	fn_info_config_avalanche
## Dont Starve Together
elif [ "${engine}" == "dontstarve" ]; then
	fn_info_config_dontstarve
## Project Zomboid
elif [ "${engine}" == "projectzomboid" ]; then
	fn_info_config_projectzomboid
# Quake Live
elif [ "${engine}" == "idtech3" ]; then
	fn_info_config_idtech3
# ARMA 3
elif [ "${engine}" == "realvirtuality" ]; then
	fn_info_config_realvirtuality
# Serious Sam
elif [ "${engine}" == "seriousengine35" ]; then
	fn_info_config_seriousengine35
# Source Engine Games
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	fn_info_config_source
# Teeworlds
elif [ "${engine}" == "teeworlds" ]; then
	fn_info_config_teeworlds
# Terraria
elif [ "${engine}" == "terraria" ]; then
	fn_info_config_terraria
# Unreal/Unreal 2 engine
elif [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	fn_info_config_unreal
fi
