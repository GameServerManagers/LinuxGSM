#!/bin/bash
# LGSM fn_details_config function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

# Description: Gets specific details from config files.

## Examples of filtering to get info from config files
# sed 's/foo//g' - remove foo
# tr -cd '[:digit:]' leave only digits
# tr -d '=\"; ' remove selected charectors =\";
# grep -v "foo" filter out lines that contain foo

fn_servercfgfullpath(){
if [ ! -f "${servercfgfullpath}" ]; then
	servercfgfullpath="\e[0;31mMISSING!\e[0m ${servercfgfullpath}"
fi
}

## Just Cause 2
if [ "${engine}" == "avalanche" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "Name" "${servercfgfullpath}" | sed 's/Name//g' | tr -d '=", \n')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# ip
	if [ -f "${servercfgfullpath}" ]; then
		# check if the ip exists in the config file. Failing this will fall back to the default.
		configipcheck=$(grep "BindIP" "${servercfgfullpath}" | sed 's/BindIP//g' | tr -d '=", \n')
	fi
	if [ -n "${configipcheck}" ]; then
		ip=$(grep "BindIP" "${servercfgfullpath}" | sed 's/BindIP//g' | tr -d '=", \n')
	fi

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed 's/Password//g' | tr -d '=", \n')
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "MaxPlayers" "${servercfgfullpath}" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="NOT SET"
		fi
	else
		slots="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "BindPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	fn_servercfgfullpath

## Dont Starve Together
elif [ "${engine}" == "dontstarve" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "default_server_name = " "${servercfgfullpath}" | sed 's/default_server_name = //g')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "server_password = " "${servercfgfullpath}" | grep -v "#" | sed 's/server_password = //g')
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "max_players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="NOT SET"
		fi
	else
		slots="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# game mode
	if [ -f "${servercfgfullpath}" ]; then
		gamemode=$(grep "game_mode = " "${servercfgfullpath}" | grep -v "#" | sed 's/game_mode = //g')
		if [ ! -n "${gamemode}" ]; then
			gamemode="NOT SET"
		fi
	else
		gamemode="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# tickrate
	if [ -f "${servercfgfullpath}" ]; then
		tickrate=$(grep "tick_rate" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ ! -n "${tickrate}" ]; then
			tickrate="NOT SET"
		fi
	else
		tickrate="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "server_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	fn_servercfgfullpath

## Project Zomboid
elif [ "${engine}" == "projectzomboid" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "PublicName=" "${servercfgfullpath}" | sed 's/PublicName=//g' | tr -d '=", \n')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "MaxPlayers=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="NOT SET"
		fi
	else
		slots="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "DefaultPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	fn_servercfgfullpath

# ARMA 3
elif [ "${engine}" == "realvirtuality" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "hostname" "${servercfgfullpath}" | grep -v "//" | sed -e 's/\<hostname\>//g' | tr -d '=\"; ')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# admin password
	if [ -f "${servercfgfullpath}" ]; then
		adminpassword=$(grep "passwordAdmin" "${servercfgfullpath}" | grep -v "//" | sed -e 's/\passwordAdmin//g' | tr -d '=\"; ')
		if [ ! -n "${adminpassword}" ]; then
			adminpassword="NOT SET"
		fi
	else
		adminpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "password =" "${servercfgfullpath}" | grep -v "//" | sed -e 's/\password//g' | tr -d '=\"; ')
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "maxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="NOT SET"
		fi
	else
		slots="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "serverport=" "${servercfgfullpath}" | grep -v // | tr -d '\r' | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	# query port
	if [ -f "${servercfgfullpath}" ]; then
		queryport=$(grep "steamqueryport=" "${servercfgfullpath}" | grep -v // | tr -d '\r' | tr -cd '[:digit:]')
	fi
	if [ ! -n "${queryport}" ]; then
		queryport="0"
	fi

	# master port
	if [ -f "${servercfgfullpath}" ]; then
		masterport=$(grep "steamport=" "${servercfgfullpath}" | grep -v // | tr -d '\r' | tr -cd '[:digit:]')
	fi
	if [ ! -n "${masterport}" ]; then
		masterport="0"
	fi

	fn_servercfgfullpath

elif [ "${engine}" == "seriousengine35" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "prj_strMultiplayerSessionName" "${servercfgfullpath}" | sed 's/prj_strMultiplayerSessionName = //g' | tr -d '=\"; ')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# rcon password
	if [ -f "${servercfgfullpath}" ]; then
		rconpassword=$(grep "rcts_strAdminPassword" "${servercfgfullpath}" | sed 's/rcts_strAdminPassword = //g' | tr -d '=\"; ')
		if [ ! -n "${rconpassword}" ]; then
			rconpassword="NOT SET"
		fi
	else
		rconpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "gam_ctMaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="NOT SET"
		fi
	else
		slots="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# game mode
	if [ -f "${servercfgfullpath}" ]; then
		gamemode=$(grep "gam_idGameMode" "${servercfgfullpath}" | grep -v "#" | sed 's/gam_idGameMode//g' | tr -d '=\"; ')
		if [ ! -n "${gamemode}" ]; then
			gamemode="NOT SET"
		fi
	else
		gamemode="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "prj_uwPort" "${servercfgfullpath}" | tr -d '\r' | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	# query port
	if [ -f "${servercfgfullpath}" ]; then
		queryport=$((${port} + 1))
	fi
	if [ ! -n "${queryport}" ]; then
		queryport="0"
	fi

	fn_servercfgfullpath

elif [ "${engine}" == "source" ] || [ "${engine}" == "goldsource" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "hostname" "${servercfgfullpath}" | sed 's/hostname //g' | sed 's/"//g')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "sv_password" "${servercfgfullpath}" | sed 's/sv_password //g' | sed 's/"//g')
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# rcon password
	if [ -f "${servercfgfullpath}" ]; then
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed 's/rcon_password //g' | sed 's/"//g')
		if [ ! -n "${rconpassword}" ]; then
			rconpassword="NOT SET"
		fi
	else
		rconpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	fn_servercfgfullpath

elif [ "${engine}" == "spark" ]; then

	# query port
	if [ -f "${servercfgfullpath}" ]; then
		queryport=$((port + 1))
	fi
	if [ ! -n "${queryport}" ]; then
		queryport="0"
	fi

	fn_servercfgfullpath

elif [ "${gamename}" == "Teamspeak 3" ]; then

	# ip
	if [ -f "${servercfgfullpath}" ]; then
		# check if the ip exists in the config file. Failing this will fall back to the default.
		configipcheck=$(grep "voice_ip=" "${servercfgfullpath}" | sed 's/\voice_ip=//g')
	fi
	if [ -n "${configipcheck}" ]; then
		ip=$(grep "voice_ip=" "${servercfgfullpath}" | sed 's/\voice_ip=//g')
	fi

	# dbplugin
	if [ -f "${servercfgfullpath}" ]; then
		dbplugin=$(grep "dbplugin=" "${servercfgfullpath}" | sed 's/\dbplugin=//g')
		if [ ! -n "${dbplugin}" ]; then
			dbplugin="NOT SET"
		fi
	else
		dbplugin="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "default_voice_port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="9987"
	fi

	# query port
	if [ -f "${servercfgfullpath}" ]; then
		queryport=$(grep "query_port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${queryport}" ]; then
		queryport="10011"
	fi

	# file port
	if [ -f "${servercfgfullpath}" ]; then
		fileport=$(grep "filetransfer_port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${fileport}" ]; then
		fileport="30033"
	fi

	fn_servercfgfullpath

elif [ "${engine}" == "teeworlds" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "sv_name" "${servercfgfullpath}" | sed 's/sv_name //g' | sed 's/"//g')
		if [ ! -n "${servername}" ]; then
			servername="unnamed server"
		fi
	else
		servername="unnamed server"
	fi

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "password " "${servercfgfullpath}" | awk '!/sv_rcon_password/'| sed 's/password //g' | tr -d '=\"; ')
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi	

	# rcon password
	if [ -f "${servercfgfullpath}" ]; then
		rconpassword=$(grep "sv_rcon_password" "${servercfgfullpath}" | sed 's/sv_rcon_password //g' | tr -d '=\"; ')
		if [ ! -n "${rconpassword}" ]; then
			rconpassword="NOT SET"
		fi
	else
		rconpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "sv_port" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="8303"
	fi

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "sv_max_clients" "${servercfgfullpath}" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="12"
		fi
	else
		slots="12"
	fi

	fn_servercfgfullpath

elif [ "${engine}" == "terraria" ]; then

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

elif [ "${engine}" == "unity3d" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "ServerPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# webadmin enabled
	if [ -f "${servercfgfullpath}" ]; then
		webadminenabled=$(grep "ControlPanelEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${webadminenabled}" ]; then
			webadminenabled="NOT SET"
		fi
	else
		webadminenabled="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# webadmin port
	if [ -f "${servercfgfullpath}" ]; then
		webadminport=$(grep "ControlPanelPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${webadminport}" ]; then
		webadminport="0"
	fi

	# webadmin enabled
	if [ -f "${servercfgfullpath}" ]; then
		webadminenabled=$(grep "ControlPanelEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${webadminenabled}" ]; then
			webadminenabled="NOT SET"
		fi
	else
		webadminenabled="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# webadmin password
	if [ -f "${servercfgfullpath}" ]; then
		webadminpass=$(grep "ControlPanelPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${webadminpass}" ]; then
			webadminpass="NOT SET"
		fi
	else
		webadminpass="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# telnet enabled
	if [ -f "${servercfgfullpath}" ]; then
		telnetenabled=$(grep "TelnetEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${telnetenabled}" ]; then
			telnetenabled="NOT SET"
		fi
	else
		telnetenabled="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# telnet port
	if [ -f "${servercfgfullpath}" ]; then
		telnetport=$(grep "TelnetPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${telnetport}" ]; then
		telnetport="0"
	fi

	# telnet password
	if [ -f "${servercfgfullpath}" ]; then
		telnetpass=$(grep "TelnetEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${telnetpass}" ]; then
			telnetpass="NOT SET"
		fi
	else
		telnetpass="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "ServerMaxPlayerCount" "${servercfgfullpath}" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="NOT SET"
		fi
	else
		slots="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# game mode
	if [ -f "${servercfgfullpath}" ]; then
		gamemode=$(grep "GameMode" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${gamemode}" ]; then
			gamemode="NOT SET"
		fi
	else
		gamemode="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# game world
	if [ -f "${servercfgfullpath}" ]; then
		gameworld=$(grep "GameWorld" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		if [ ! -n "${gameworld}" ]; then
			gameworld="NOT SET"
		fi
	else
		gameworld="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "sv_port" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	# query port
	if [ -f "${servercfgfullpath}" ]; then
		queryport=$((port + 1))
	fi
	if [ ! -n "${queryport}" ]; then
		queryport="0"
	fi

	fn_servercfgfullpath

elif [ "${engine}" == "unreal" ] || [ "${engine}" == "unreal2" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed 's/ServerName=//g')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "GamePassword=" "${servercfgfullpath}" | sed 's/GamePassword=//g')
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# admin password
	if [ -f "${servercfgfullpath}" ]; then
		adminpassword=$(grep "AdminPassword=" "${servercfgfullpath}" | sed 's/AdminPassword=//g')
		if [ ! -n "${adminpassword}" ]; then
			adminpassword="NOT SET"
		fi
	else
		adminpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi	

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "Port=" "${servercfgfullpath}" | grep -v "Master" | grep -v "LAN" | grep -v "Proxy" | grep -v "Listen" | tr -d '\r' | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	# query port
	if [ -f "${servercfgfullpath}" ]; then
		queryport=$((port + 1))
	fi
	if [ ! -n "${queryport}" ]; then
		queryport="0"
	fi

	# gamespy query port
	if [ -f "${servercfgfullpath}" ]; then
		gsqueryport=$(grep "OldQueryPortNumber=" "${servercfgfullpath}" | tr -d '\r' | tr -cd '[:digit:]')
	fi
	if [ ! -n "${gsqueryport}" ]; then
		gsqueryport="0"
	fi

	# query port
	if [ -f "${servercfgfullpath}" ]; then
		udplinkport=$((port + 2))
	fi
	if [ ! -n "${udplinkport}" ]; then
		udplinkport="0"
	fi

	# webadmin enabled
	if [ -f "${servercfgfullpath}" ]; then
		webadminenabled=$(grep "bEnabled=" "${servercfgfullpath}" | sed 's/bEnabled=//g' | tr -d '\r')
		if [ ! -n "${webadminenabled}" ]; then
			webadminenabled="NOT SET"
		fi
	else
		webadminenabled="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# webadmin port
	if [ -f "${servercfgfullpath}" ]; then
		webadminport=$(grep "ListenPort=" "${servercfgfullpath}" | tr -d '\r' | tr -cd '[:digit:]')
	fi
	if [ ! -n "${webadminport}" ]; then
		webadminport="0"
	fi

	if [ "${engine}" == "unreal" ]; then

		# webadmin user
		if [ -f "${servercfgfullpath}" ]; then
			webadminuser=$(grep "AdminUsername=" "${servercfgfullpath}" | sed 's/\AdminUsername=//g')
			if [ ! -n "${webadminuser}" ]; then
				webadminuser="NOT SET"
			fi
		else
			webadminuser="\e[0;31mUNAVAILABLE\e[0m"
		fi

		# webadmin password
		if [ -f "${servercfgfullpath}" ]; then
			webadminpass=$(grep "UTServerAdmin.UTServerAdmin" "${servercfgfullpath}" -A 2 | grep "AdminPassword=" | sed 's/\AdminPassword=//g')
			if [ ! -n "${webadminpass}" ]; then
				webadminpass="NOT SET"
			fi
		else
			webadminpass="\e[0;31mUNAVAILABLE\e[0m"
		fi

	else

		# webadmin user
		if [ -f "${servercfgfullpath}" ]; then
			webadminuser=$(grep "AdminName=" "${servercfgfullpath}" | sed 's/\AdminName=//g')
			if [ ! -n "${webadminuser}" ]; then
				webadminuser="NOT SET"
			fi
		else
			webadminuser="\e[0;31mUNAVAILABLE\e[0m"
		fi

		# webadmin password
		if [ -f "${servercfgfullpath}" ]; then
			webadminpass=$(grep "AdminPassword=" "${servercfgfullpath}" | sed 's/\AdminPassword=//g')
			if [ ! -n "${webadminpass}" ]; then
				webadminpass="NOT SET"
			fi
		else
			webadminpass="\e[0;31mUNAVAILABLE\e[0m"
		fi

	fi

	fn_servercfgfullpath

elif [ "${gamename}" == "ARK: Survivial Evolved" ]; then

	# server name
	if [ -f "${servercfgfullpath}" ]; then
		servername=$(grep "SessionName=" "${servercfgfullpath}" | sed 's/SessionName=//g')
		if [ ! -n "${servername}" ]; then
			servername="NOT SET"
		fi
	else
		servername="\e[0;31mUNAVAILABLE\e[0m"
	fi	

	# server password
	if [ -f "${servercfgfullpath}" ]; then
		serverpassword=$(grep "ServerPassword=" "${servercfgfullpath}" | sed 's/ServerPassword=//g')
		if [ ! -n "${serverpassword}" ]; then
			serverpassword="NOT SET"
		fi
	else
		serverpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# admin password
	if [ -f "${servercfgfullpath}" ]; then
	adminpassword=$(grep "ServerAdminPassword=" "${servercfgfullpath}" | sed 's/ServerAdminPassword=//g')
		if [ ! -n "${adminpassword}" ]; then
			adminpassword="NOT SET"
		fi
	else
		adminpassword="\e[0;31mUNAVAILABLE\e[0m"
	fi	

	# slots
	if [ -f "${servercfgfullpath}" ]; then
		slots=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		if [ ! -n "${slots}" ]; then
			slots="NOT SET"
		fi
	else
		slots="\e[0;31mUNAVAILABLE\e[0m"
	fi

	# port
	if [ -f "${servercfgfullpath}" ]; then
		port=$(grep "Port=" "${servercfgfullpath}" | grep -v  "RCONPort=" | grep -v  "QueryPort=" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${port}" ]; then
		port="0"
	fi

	# rcon port
	if [ -f "${servercfgfullpath}" ]; then
		rconport=$(grep "RCONPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${rconport}" ]; then
		rconport="0"
	fi

	# query port
	if [ -f "${servercfgfullpath}" ]; then
			queryport=$(grep "QueryPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi
	if [ ! -n "${queryport}" ]; then
		queryport="0"
	fi

	fn_servercfgfullpath

fi
