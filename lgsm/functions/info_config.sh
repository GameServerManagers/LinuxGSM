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
# tr -d '=\"; ' remove selected characters =\";
# grep -v "foo" filter out lines that contain foo
# cut -f1 -d "/" remove everything after /

fn_info_config_avalanche(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
		port="${zero}"
	else

		servername=$(grep "Name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/Name//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/Password//g' | tr -d '=\";,:' | xargs)
		slots=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		port=$(grep "BindPort" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
		port=${port:-"0"}

		# check if the ip exists in the config file. Failing this will fall back to the default.
		ipconfigcheck=$(grep "BindIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/BindIP//g' | tr -d '=\";,:' | xargs)
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
		servername=$(grep "default_server_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/default_server_name//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "server_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_password//g' | tr -d '=\";,:' | xargs)
		slots=$(grep "max_players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gamemode=$(grep "game_mode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/game_mode//g' | tr -d '=\";,:' | xargs)
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

fn_info_config_minecraft(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
		rconport="${zero}"
		slots="${zero}"
		port="${zero}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else

		servername=$(grep "motd" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/motd//g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rcon.password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/rcon.password//g' | tr -d '=\";,:' | xargs)
		rconport=$(grep "rcon.port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		slots=$(grep "max-players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server-port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gamemode=$(grep "gamemode" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gameworld=$(grep "level-name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/level-name//g' | tr -d '=\";,:' | xargs)

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"NOT SET"}
		slots=${slots:-"NOT SET"}
		port=${port:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}

		# check if the ip exists in the config file. Failing this will fall back to the default.
		ipconfigcheck=$(grep "server-ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/server-ip//g' | tr -d '=\";,:' | xargs)
		if [ -n "${ipconfigcheck}" ]; then
			ip="${ipconfigcheck}"
		fi
	fi
}

fn_info_config_projectzomboid(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		slots="${zero}"
		port="${zero}"
		gameworld="${unavailable}"
	else
		servername=$(grep "PublicName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/PublicName//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Password" | sed  -e '/^#/d' -e 's/Password//g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "RCONPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/RCONPassword//g' | tr -d '=\";,:' | xargs)
		slots=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "DefaultPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gameworld=$(grep "Map" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Map" | sed -e '/^#/d' -e 's/Map//g' | tr -d '=\";' | xargs)

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		slots=${slots:-"NOT SET"}
		port=${port:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_config_idtech3(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"

		slots="${zero}"
	else
		rconpassword=$(grep "zmq_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set zmq_rcon_password//g' | tr -d '=\";,:' | xargs)
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password//g' | tr -d '=\";,:' | xargs)
		slots=$(grep "sv_maxClients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
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
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | xargs)
		adminpassword=$(grep "passwordAdmin" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/passwordAdmin//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/password//g' | tr -d '=\";,:' | xargs)
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
		servername=$(grep "prj_strMultiplayerSessionName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/prj_strMultiplayerSessionName//g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rcts_strAdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/rcts_strAdminPassword//g' | tr -d '=\";,:' | xargs)
		gamemode=$(grep "gam_idGameMode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/gam_idGameMode//g' | tr -d '=\";,:' | xargs)
		slots=$(grep "gam_ctMaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "prj_uwPort" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

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
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "sv_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/sv_password//g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/rcon_password//g' | tr -d '=\";,:' | xargs)

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
		servername=$(grep "serverName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/serverName//g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconServerPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/rconServerPassword//g' | tr -d '=\";,:' | xargs)
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
		dbplugin=$(grep "dbplugin=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/dbplugin=//g' | tr -d '=\";,:' | xargs)
		port=$(grep "default_voice_port" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "query_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		fileport=$(grep "filetransfer_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		port=${port:-"9987"}
		queryport=${queryport:-"10011"}
		fileport=${fileport:-"30033"}

		# check if the ip exists in the config file. Failing this will fall back to the default.
		ipconfigcheck=$(grep "voice_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/voice_ip//g' | tr -d '=\";,:' | xargs)
		if [ -n "${ipconfigcheck}" ]; then
			ip="${ipconfigcheck}"
		fi
	fi
}

fn_info_config_mumble(){
	if [ ! -f "${servercfgfullpath}" ]; then
		port="64738"
		queryport="${port}"
		servername="Mumble"
	else
		port=$(grep "port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^;/d' -e 's/port//g' | tr -d '=\";,:' | xargs)
		queryport="${port}"

		# Not Set
		port=${port:-"64738"}
		queryport=${queryport:-"64738"}
		servername="Mumble Port ${port}"

		# check if the ip exists in the config file. Failing this will fall back to the default.
		ipconfigcheck=$(cat "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^;/d' -e 's/voice_ip//g' | tr -d '=\";,:' | xargs)
		if [ -n "${ipconfigcheck}" ]; then
			ip="${ipconfigcheck}"
		fi
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
		servername=$(grep "sv_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^sv_name//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^password" | sed -e '/^#/d' -e 's/^password//g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "sv_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^sv_rcon_password//g' | tr -d '=\";,:' | xargs)
		port=$(grep "sv_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		slots=$(grep "sv_max_clients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

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
		servername=$(grep "worldname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/worldname//g' | tr -d '=\";,:' | xargs)
		port=$(grep "port" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gameworld=$(grep "world=" "${servercfgfullpath}" | grep -v "#" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/world=//g' | tr -d '=\";,:' | xargs)
		slots=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

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
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | xargs)
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | xargs)
		port=$(grep "Port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Port" | grep -v "#" | tr -cd '[:digit:]')
		gsqueryport=$(grep "OldQueryPortNumber" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | xargs)
		webadminport=$(grep "ListenPort" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ "${engine}" == "unreal" ]; then
			webadminuser=$(grep "AdminUsername" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminUsername//g' | tr -d '=\";,:' | xargs)
			webadminpass=$(grep "UTServerAdmin.UTServerAdmin" "${servercfgfullpath}" -A 4 | grep "AdminPassword" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | xargs)
		else
			webadminuser=$(grep "AdminName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminName//g' | tr -d '=\";,:' | xargs)
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

fn_info_config_sdtd(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminpass="${unavailable}"
		telnetenabled="${unavailable}"
		telnetport="${zero}"
		telnetpass="${unavailable}"
		slots="${unavailable}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		serverpassword=$(grep "ServerPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		port=$(grep "ServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$((port + 1))

		webadminenabled=$(grep "ControlPanelEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		webadminport=$(grep "ControlPanelPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminpass=$(grep "ControlPanelPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		telnetenabled=$(grep "TelnetEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		telnetport=$(grep "TelnetPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		telnetpass=$(grep "TelnetPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")

		slots=$(grep "ServerMaxPlayerCount" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gamemode=$(grep "GameMode" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		gameworld=$(grep "GameWorld" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"0"}
		webadminpass=${webadminpass:-"NOT SET"}
		telnetenabled=${telnetenabled:-"NOT SET"}
		telnetport=${telnetport:-"0"}
		telnetpass=${telnetpass:-"NOT SET"}
		slots=${slots:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

# Just Cause 2
if [ "${engine}" == "avalanche" ]; then
	fn_info_config_avalanche
# Dont Starve Together
elif [ "${engine}" == "dontstarve" ]; then
	fn_info_config_dontstarve
# Quake Live
elif [ "${engine}" == "idtech3" ]; then
	fn_info_config_idtech3
# Minecraft
elif [ "${engine}" == "lwjgl2" ]; then
	fn_info_config_minecraft
# Project Zomboid
elif [ "${engine}" == "projectzomboid" ]; then
	fn_info_config_projectzomboid
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
# TeamSpeak 3
elif [ "${gamename}" == "TeamSpeak 3" ]; then
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
# 7 Day To Die (unity3d)
elif [ "${gamename}" == "7 Days To Die" ]; then
	fn_info_config_sdtd
fi
