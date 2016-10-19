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

		servername=$(grep "Name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/Name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		port=$(grep "BindPort" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		ip=$(grep "BindIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/BindIP//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		
		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
		port=${port:-"0"}
		
		# Misc Variables
		ipsetinconfig=1
		ipinconfigvar="BindIP"
	fi
}

fn_info_config_bf1942(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
		port="${zero}"
		queryport="${zero}"
	else

		servername=$(grep "game.serverName " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverName //g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "game.serverPassword" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/game.serverPassword//g' | tr -d '=\";,:' | xargs)
		slots=$(grep "game.serverMaxPlayers" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		port=$(grep "game.serverPort" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		queryport="22000"
		ip=$(grep "game.serverIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverIP//g' | tr -d '=\";,:' | xargs)
		
		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
		port=${port:-"0"}
		
		# Misc Variables
		ipsetinconfig=1
		ipinconfigvar="game.serverIP"
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
		servername=$(grep "default_server_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/default_server_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "server_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "max_players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gamemode=$(grep "game_mode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/game_mode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
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

		servername=$(grep "motd" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/motd//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon.password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/rcon.password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconport=$(grep "rcon.port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		slots=$(grep "max-players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server-port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gamemode=$(grep "gamemode" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gameworld=$(grep "level-name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/level-name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ip=$(grep "server-ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/server-ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		
		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"NOT SET"}
		slots=${slots:-"NOT SET"}
		port=${port:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
		
		# Misc Variables
		ipsetinconfig=1
		ipinconfigvar="server-ip"
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
		servername=$(grep "PublicName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/PublicName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Password" | sed  -e '/^#/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "RCONPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/RCONPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "DefaultPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gameworld=$(grep "Map" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Map" | sed -e '/^#/d' -e 's/Map//g' | tr -d '=\";' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		slots=${slots:-"NOT SET"}
		port=${port:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_config_quakelive(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
	else
		rconpassword=$(grep "zmq_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set zmq_rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "sv_maxClients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		ip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
		
		# Misc Variables
		ipsetinconfig=1
		ipinconfigvar="set net_ip"
	fi
}

fn_info_config_wolfensteinenemyterritory(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
		port="${zero}"
	else
		port=$(grep "set net_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		rconpassword=$(grep "set zmq_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set zmq_rcon_password //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//g' -e '/^\//d' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "set sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "set g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "set sv_maxclients" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		ip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		slots=${slots:-"0"}
		port=${port:-"27960"}
		
		# Misc Variables
		ipsetinconfig=1
		ipinconfigvar="set net_ip"
	fi
}

fn_info_config_realvirtuality(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		adminpassword="${unavailable}"
		serverpassword="${unavailable}"
		slots="${zero}"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "passwordAdmin" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/passwordAdmin//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "maxPlayers" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

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
		servername=$(grep "prj_strMultiplayerSessionName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/prj_strMultiplayerSessionName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcts_strAdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/rcts_strAdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		gamemode=$(grep "gam_idGameMode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/gam_idGameMode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "gam_ctMaxPlayers" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		port=$(grep "prj_uwPort" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

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
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "sv_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/sv_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

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
		servername=$(grep "serverName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/serverName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rconServerPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/rconServerPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
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
		dbplugin=$(grep "dbplugin=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/dbplugin=//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "default_voice_port" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "query_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		fileport=$(grep "filetransfer_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		ip=$(grep "voice_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/voice_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		
		# Not Set
		port=${port:-"9987"}
		queryport=${queryport:-"10011"}
		fileport=${fileport:-"30033"}
		
		# Misc Variables
		ipsetinconfig=1
		ipinconfigvar="voice_ip"
	fi
}

fn_info_config_mumble(){
	if [ ! -f "${servercfgfullpath}" ]; then
		port="64738"
		queryport="${port}"
		servername="Mumble"
	else
		port=$(grep "port=" "${servercfgfullpath}" | awk -F "=" '{ print $2 }' )
		ip=$(grep "host=" "${servercfgfullpath}" | awk -F "=" '{ print $2 }' )
		
		# Not Set
		port=${port:-"64738"}
		queryport=${queryport:-"64738"}
		servername="Mumble Port ${port}"
		
		# Misc variables
		ipsetinconfig=1
		ipinconfigvar="voice_ip"
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
		servername=$(grep "sv_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^sv_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^password" | sed -e '/^#/d' -e 's/^password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "sv_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^sv_rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
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
		servername=$(grep "worldname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/worldname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "port" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gameworld=$(grep "world=" "${servercfgfullpath}" | grep -v "//" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/world=//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		slots=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

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
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "Port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Port" | grep -v "#" | tr -cd '[:digit:]')
		gsqueryport=$(grep "OldQueryPortNumber" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		webadminport=$(grep "ListenPort" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ "${engine}" == "unreal" ]; then
			webadminuser=$(grep "AdminUsername" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminUsername//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
			webadminpass=$(grep "UTServerAdmin.UTServerAdmin" "${servercfgfullpath}" -A 4 | grep "AdminPassword" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		else
			webadminuser=$(grep "AdminName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
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
# Battlefield: 1942
elif [ "${gamename}" == "Battlefield: 1942" ]; then
	fn_info_config_bf1942
# Dont Starve Together
elif [ "${engine}" == "dontstarve" ]; then
	fn_info_config_dontstarve
# Quake Live
elif [ "${gamename}" == "Quake Live" ]; then
	fn_info_config_quakelive
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
elif [ "${gamename}" == "Wolfenstein: Enemy Territory" ]; then
	fn_info_config_wolfensteinenemyterritory
fi
