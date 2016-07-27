#!/bin/bash
# LGSM info_config.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Gets specific details from config files.

local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

## Examples of filtering to get info from config files
# sed 's/foo//g' - remove foo
# tr -cd '[:digit:]' leave only digits
# tr -d '=\"; ' remove selected charectors =\";
# grep -v "foo" filter out lines that contain foo

unavailable="${red}UNAVAILABLE${default}"
zero="${red}0${default}"

fn_info_config_avalanche(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
		port="${zero}"
	else
		servername=$(grep "Name" "${servercfgfullpath}" | sed 's/Name//g' | tr -d '=", \n')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed 's/Password//g' | tr -d '=", \n')
		slots=$(grep "MaxPlayers" "${servercfgfullpath}" | tr -cd '[:digit:]')
		port=$(grep "BindPort" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
		port=${port:-"0"}

		# check if the ip exists in the config file. Failing this will fall back to the default.
		ipconfigcheck=$(grep "BindIP" "${servercfgfullpath}" | sed 's/BindIP//g' | tr -d '=", \n')
		if [ -n "${ipconfigcheck}" ]; then
			ip="${ipconfigcheck}"
		fi
	fi
}

fn_info_config_dontstarve(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
		gamemode="${unavailable}"
		tickrate="${zero}"
		port="${zero}"
	else
		servername=$(grep "default_server_name = " "${servercfgfullpath}" | sed 's/default_server_name = //g')
		serverpassword=$(grep "server_password = " "${servercfgfullpath}" | grep -v "#" | sed 's/server_password = //g')
		slots=$(grep "max_players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gamemode=$(grep "game_mode = " "${servercfgfullpath}" | grep -v "#" | sed 's/game_mode = //g')
		tickrate=$(grep "tick_rate" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
		gamemode=${gamemode:-"NOT SET"}
		tickrate=${tickrate:-"0"}
		port=${port:-"0"}
	fi
}

fn_info_config_projectzomboid(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		slots="${zero}"
		port="${zero}"
	else
		servername=$(grep "PublicName=" "${servercfgfullpath}" | sed 's/PublicName=//g' | tr -d '=", \n')
		slots=$(grep "MaxPlayers=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "DefaultPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		slots=${slots:-"0"}
		port=${port:-"0"}
	fi
}

fn_info_config_idtech3(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
	else
		servername=$(grep "set sv_hostname " "${servercfgfullpath}" | sed 's/set sv_hostname //g' | tr -d '=\"; ')
		serverpassword=$(grep "set g_password" "${servercfgfullpath}" | sed 's/set g_password//g' | tr -d '=\"; '| cut -f1 -d "/")
		slots=$(grep "set sv_maxClients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
	fi
}

fn_info_config_realvirtuality(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		adminpassword="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | grep -v "//" | sed 's/\<hostname\>//g' | tr -d '=\"; ')
		adminpassword=$(grep "passwordAdmin" "${servercfgfullpath}" | grep -v "//" | sed 's/\passwordAdmin//g' | tr -d '=\"; ')
		serverpassword=$(grep "password =" "${servercfgfullpath}" | grep -v "//" | sed 's/\password//g' | tr -d '=\"; ')
		slots=$(grep "maxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
	fi
}

fn_info_config_seriousengine35(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
		gamemode="${unavailable}"
		slots="${zero}"
		port="${zero}"
	else
		servername=$(grep "prj_strMultiplayerSessionName" "${servercfgfullpath}" | sed 's/prj_strMultiplayerSessionName = //g' | tr -d '=\"; ')
		rconpassword=$(grep "rcts_strAdminPassword" "${servercfgfullpath}" | sed 's/rcts_strAdminPassword = //g' | tr -d '=\"; ')
		gamemode=$(grep "gam_idGameMode" "${servercfgfullpath}" | grep -v "#" | sed 's/gam_idGameMode//g' | tr -d '=\"; ')
		slots=$(grep "gam_ctMaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "prj_uwPort" "${servercfgfullpath}" | tr -d '\r' | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		slots=${slots:-"0"}
		port=${port:-"0"}
	fi
}

fn_info_config_source(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | sed 's/hostname //g' | sed 's/"//g')
		serverpassword=$(grep "sv_password" "${servercfgfullpath}" | sed 's/sv_password //g' | sed 's/"//g')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed 's/rcon_password //g' | sed 's/"//g')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
	fi
}

fn_info_config_starbound(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
		port="21025"
		queryport="21025"
		rconport="21026"
		slots="8"
	else
		servername=$(grep "serverName" "${servercfgfullpath}" | sed 's/"serverName" \: //g' | grep -oP '"\K[^"]+(?=["])')
		rconpassword=$(grep "rconServerPassword" "${servercfgfullpath}" | sed 's/"rconServerPassword" \: //g' | grep -oP '"\K[^"]+(?=["])')
		port=$(grep "gameServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "queryServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		rconport=$(grep "rconServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		slots=$(grep "maxPlayers" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"21025"}
		queryport=${queryport:-"21025"}
		rconport=${rconport:-"21026"}
		slots=${slots:-"8"}
	fi
}

fn_info_config_teamspeak3(){
	if [ ! -f "${servercfgfullpath}" ]; then
		dbplugin="${unavailable}"
		port="9987"
		queryport="10011"
		fileport="30033"
	else
		# check if the ip exists in the config file. Failing this will fall back to the default.
		ipconfigcheck=$(grep "voice_ip=" "${servercfgfullpath}" | sed 's/voice_ip=//g')
		if [ -n "${ipconfigcheck}" ]; then
			ip="${ipconfigcheck}"
		fi
		dbplugin=$(grep "dbplugin=" "${servercfgfullpath}" | sed 's/dbplugin=//g')
		port=$(grep "default_voice_port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "query_port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		fileport=$(grep "filetransfer_port=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		port=${port:-"9987"}
		queryport=${queryport:-"10011"}
		fileport=${fileport:-"30033"}
	fi
}

fn_info_config_mumble(){
	if [ ! -f "${servercfgfullpath}" ]; then
		port="64738"
		queryport="${port}"
	else
		# check if the ip exists in the config file. Failing this will fall back to the default.
		ipconfigcheck=${cat "${servercfgfullpath}" | grep "host=" | awk -F'=' '{ print $2}'
		if [ -n "${ipconfigcheck}" ]; then
			ip="${ipconfigcheck}"
		fi
		port=$(cat "${servercfgfullpath}" | grep 'port=' | awk -F'=' '{ print $2 }')
		queryport="${port}"

		# Not Set
		port=${port:-"64738"}
		queryport=${queryport:-"64738"}
	fi
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
		servername="${unavailable}"
		port="${zero}"
		gameworld="${unavailable}"
		slots="${zero}"
	else
		servername=$(grep "worldname=" "${servercfgfullpath}" | sed 's/worldname=//g')
		port=$(grep "port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gameworld=$(grep "world=" "${servercfgfullpath}" | sed 's/world=//g')
		slots=$(grep "maxplayers=" "${servercfgfullpath}" | sed 's/maxplayers=//g')

		# Not Set
		servername=${servername:-"NOT SET"}
		port=${port:-"0"}
		gameworld=${gameworld:-"NOT SET"}
		slots=${slots:-"0"}
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
			webadminuser=$(grep "AdminUsername=" "${servercfgfullpath}" | sed 's/AdminUsername=//g')
			webadminpass=$(grep "UTServerAdmin.UTServerAdmin" "${servercfgfullpath}" -A 2 | grep "AdminPassword=" | sed 's/AdminPassword=//g')
		else
			webadminuser=$(grep "AdminName=" "${servercfgfullpath}" | sed 's/AdminName=//g')
			webadminpass="${adminpassword}"
		fi

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		gsqueryport=${gsqueryport:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"0"}
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
# Quake Love
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
# Starbound
elif [ "${engine}" == "starbound" ]; then
	fn_info_config_starbound
#TeamSpeak
elif [ "${gamename}" == "Teamspeak 3" ]; then
	fn_info_config_teamspeak3
elif [ "${gamename}" == "Mumble" ]; then
	fn_info_config_mumble
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
