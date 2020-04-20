#!/bin/bash
# LinuxGSM info_config.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Gets specific details from config files.

local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

## Examples of filtering to get info from config files.
# sed 's/foo//g' - remove foo
# tr -cd '[:digit:]' leave only digits
# tr -d '=\"; ' remove selected characters =\";
# grep -v "foo" filter out lines that contain foo
# cut -f1 -d "/" remove everything after /


fn_info_config_assettocorsa(){
	if [ ! -f "${servercfgfullpath}" ]; then
		httpport="${zero}"
		port="${zero}"
		queryport="${zero}"
		servername="${unavailable}"
		adminpassword="${unavailable}"
	else
		httpport=$(grep "HTTP_PORT" "${servercfgfullpath}" | tr -cd '[:digit:]')
		port=$(grep "TCP_PORT" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport="${port}"
		servername=$(grep "NAME" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/NAME//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| head -n 1)
		adminpassword=$(grep "ADMIN_PASSWORD" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/ADMIN_PASSWORD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		httpport=${httpport:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		servername=${servername:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}

	fi
}

fn_info_config_justcause2(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
	else
		servername=$(grep "Name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/Name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverdescription=$(grep "Description" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/Description//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		port=$(grep "BindPort" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		queryport="${port}"
		ip=$(grep "BindIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/BindIP//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="BindIP"

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
	fi
}

fn_info_config_justcause3(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverdescription="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryPort="${zero}"
		steamport="${zero}"
		tickrate="${zero}"
	else
		servername=$(grep "name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverdescription=$(grep "description" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/description//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "\"maxPlayers\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		port=$(grep "\"port\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "\"queryPort\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		steamport=$(grep "\"steamPort\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		tickrate=$(grep "\"maxTickRate\"" "${servercfgfullpath}" | tr -cd '[:digit:]')

		ip=$(grep "host" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/host//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="host"

		# Not Set
		servername=${servername:-"NOT SET"}
		serverdescription=${serverdescription:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers=:-"0"}
		port=${port=:-"0"}
		queryport=${queryport=:-"0"}
		steamport=${steamport=:-"0"}
		tickrate=${tickrate=:-"0"}
	fi
}

fn_info_config_ark(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
	else
		servername=$(grep "SessionName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/SessionName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		# Not Set
		servername=${servername:-"NOT SET"}
	fi
}

fn_info_config_ballistic_overkill(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "ServerPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		maxplayers=${maxplayers:-"NOT SET"}
	fi
}

fn_info_config_barotrauma(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		maxplayers="${unavailable}"
	else
		servername=$(grep -Po 'name="\K.*(?=")' "${servercfgfullpath}") # Assuming GNU grep is used
		serverpassword=$(grep -Po 'password="\K.*(?=")' "${servercfgfullpath}") # Assuming GNU grep is used
		port=$(grep " port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "queryport=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		maxplayers=$(grep "maxplayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_battalion1944(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
	fi
}

fn_info_config_bf1942(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
	else

		servername=$(grep "game.serverName " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverName //g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "game.serverPassword" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/game.serverPassword//g' | tr -d '=\";,:' | xargs)
		maxplayers=$(grep "game.serverMaxPlayers" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		port=$(grep "game.serverPort" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		queryport="22000"

		ip=$(grep "game.serverIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverIP//g' | tr -d '=\";,:' | xargs)
		ipsetinconfig=1
		ipinconfigvar="game.serverIP"

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
	fi
}

fn_info_config_cod(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi
}

fn_info_config_cod2(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi
}

fn_info_config_cod4(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi
}

fn_info_config_codwaw(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi
}

fn_info_config_dontstarve(){
	if [ ! -f "${clustercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		gamemode="${unavailable}"
		tickrate="${zero}"
		masterport="${zero}"
	else
		servername=$(grep "cluster_name" "${clustercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/cluster_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "cluster_password" "${clustercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/cluster_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "max_players" "${clustercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gamemode=$(grep "game_mode" "${clustercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/game_mode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		tickrate=$(grep "tick_rate" "${clustercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		masterport=$(grep "master_port" "${clustercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		ip=$(grep "bind_ip" "${clustercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bind_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="bind_ip"

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		gamemode=${gamemode:-"NOT SET"}
		tickrate=${tickrate:-"0"}
		masterport=${masterport:-"0"}
	fi

	if [ ! -f "${servercfgfullpath}" ]; then
		port="${zero}"
		steamauthenticationport="${zero}"
		steammasterserverport="${zero}"
	else
		port=$(grep "server_port" "${servercfgfullpath}" | grep "^server_port" | grep -v "#" | tr -cd '[:digit:]')
		steamauthenticationport=$(grep "authentication_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		steammasterserverport=$(grep "master_server_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		port=${port:-"0"}
		steamauthenticationport=${steamauthenticationport:-"0"}
		steammasterserverport=${steammasterserverport:-"0"}
	fi
}

fn_info_config_eco(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		gamemode="${unavailable}"
		tickrate="${zero}"
		port="${zero}"
		webadminport="${zero}"
		public=""
	else
		servername=$(grep "Description" "${servercfgdir}/Network.eco" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/Description//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgdir}/Network.eco" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxConnections" "${servercfgdir}/Network.eco" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/MaxConnections//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "\"GameServerPort\"" "${servercfgdir}/Network.eco" | tr -cd '[:digit:]')
		webadminport=$(grep "\"WebServerPort\"" "${servercfgdir}/Network.eco" | tr -cd '[:digit:]')
		public=$(grep "PublicServer" "${servercfgdir}/Network.eco" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/PublicServer//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers=:-"0"}
		port=${port=:-"0"}
		webadminport=${webadminport=:-"0"}
		public=${public=:-"NOT SET"}
	fi
}

fn_info_config_factorio(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="Factorio Server"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		servername="Factorio Server"
		serverpassword=$(grep "game_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/game_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "\"max_players\"" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers=:-"0"}
	fi
}

fn_info_config_inss(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconenabled="${unavailable}"
		rconpassword="${unavailable}"
		rconport="${zero}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
		queryenabled="${unavailable}"
		rconport="${zero}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		rconenabled=$(grep "bEnabled" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconport=$(grep "ListenPort" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		rconenabled=${rconenabled:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"0"}
	fi
}

fn_info_config_minecraft(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
		rconport="${zero}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
		queryenabled="${unavailable}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "motd" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/motd//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon.password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/rcon.password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconport=$(grep "rcon.port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		maxplayers=$(grep "max-players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server-port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryport=$(grep "query.port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		if [ -z "${queryport}" ]; then
			queryport=${port}
		fi
		queryenabled=$(grep "enable-query" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/enable-query//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		gamemode=$(grep "gamemode" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gameworld=$(grep "level-name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/level-name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		ip=$(grep "server-ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/server-ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="server-ip"

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"NOT SET"}
		maxplayers=${maxplayers:-"NOT SET"}
		port=${port:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
		queryenabled="${queryenabled:-"NOT SET"}"
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_config_minecraft_bedrock(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		port6="${zero}"
		queryport="${zero}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "server-name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server-name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "max-players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server-port\b" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port6=$(grep "server-portv6\b" "${servercfgfullpath}" | sed 's/v6//g' | grep -v "#" | tr -cd '[:digit:]')
		queryport=${port}
		gamemode=$(grep "gamemode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/gamemode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		gameworld=$(grep "level-name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/level-name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"NOT SET"}
		port=${port:-"NOT SET"}
		port6=${port6:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_config_onset(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		httpport="${zero}"
		queryport="${zero}"
	else
		servername=$(grep -v "servername_short" "${servercfgfullpath}" | grep "servername" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/servername//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' )
		maxplayers=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		httpport=$((port-2))
		queryport=$((port-1))

		# Not Set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"NOT SET"}
		port=${port:-"NOT SET"}
		httpport=${httpport:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
	fi
}

fn_info_config_mohaa(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/seta rconpassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/seta sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/seta g_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "sv_maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

#Post Scriptum: The bloody Seventh
fn_info_config_pstbs(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
		reservedslots="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=";,:' | sed -e 's/^[ \t]//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		reservedslots=$(grep "NumReservedSlots=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi

	if [ ! -f "${servercfgdir}/Rcon.cfg" ]; then
		rconport=${unavailable}
		rconpassword=${unavailable}
	else
		rconport=$(grep "Port=" "${servercfgdir}/Rcon.cfg" | tr -cd '[:digit:]')
		rconpassword=$(grep "Password=" "${servercfgdir}/Rcon.cfg" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
	fi

	rconport=${rconport:-"0"}
	if [ -z "${rconpassword}" ]||[ ${#rconpassword} == 1 ]; then
		rconpassword="NOT SET"
	fi
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	numreservedslots=${numreservedslots:-"0"}
}

fn_info_config_projectcars(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
		steamport="${zero}"
	else
		servername=$(grep "name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "password " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		port=$(grep "hostPort" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		queryport=$(grep "queryPort" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		steamport=$(grep "steamPort" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"NOT SET"}
		port=${port:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
		steamport=${steamport:-"NOT SET"}
	fi
}

fn_info_config_projectzomboid(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		gameworld="${unavailable}"
	else
		servername=$(grep "PublicName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/PublicName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Password" | sed  -e '/^#/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "RCONPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/RCONPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "DefaultPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gameworld=$(grep "Map" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Map" | sed -e '/^#/d' -e 's/Map//g' | tr -d '=\";' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"NOT SET"}
		port=${port:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_config_quakeworld(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
	else
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_quake2(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_quake3(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "zmq_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set zmq_rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "sv_maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_quakelive(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
		rconport="${zero}"
		statsport="${zero}"
	else
		rconpassword=$(grep "zmq_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set zmq_rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "sv_maxClients" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		port=$(grep "net_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		queryport="${port}"
		rconport=$(grep "zmq_rcon_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		statsport=$(grep "zmq_stats_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

		ip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="set net_ip"

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		rconport=${rconport:-"0"}
		statsport=${statsport:-"0"}
	fi
}

fn_info_config_realvirtuality(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		adminpassword="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "passwordAdmin" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/passwordAdmin//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "maxPlayers" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_risingworld(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
		rconport="${zero}"
		maxplayers="${zero}"
		port="${zero}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "server_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "server_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconport=$(grep "rcon_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		maxplayers=$(grep "settings_max_players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server_port" "${servercfgfullpath}" | grep -v "database_mysql_server_port" | grep -v "#" | tr -cd '[:digit:]')
		gamemode=$(grep "gamemode" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		gameworld=$(grep "server_world_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_world_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		javaram=$(grep "server_memory" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_memory//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ip=$(grep "server_ip" "${servercfgfullpath}" | grep -v "database_mysql_server_ip" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/server_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="server-ip"

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"NOT SET"}
		maxplayers=${maxplayers:-"NOT SET"}
		port=${port:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_config_rtcw(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "sv_maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_seriousengine35(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
		gamemode="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
	else
		servername=$(grep "prj_strMultiplayerSessionName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/prj_strMultiplayerSessionName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcts_strAdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/rcts_strAdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		gamemode=$(grep "gam_idGameMode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/gam_idGameMode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "gam_ctMaxPlayers" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		port=$(grep "prj_uwPort" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
	fi
}

#StickyBots
fn_info_config_sbots(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=";,:' | sed -e 's/^[ \t]//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi

	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_config_sof2(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "sv_maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
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
		queryenabled="${unavailable}"
		rconenabled="${unavailable}"
		rconpassword="${unavailable}"
		port="21025"
		queryport="21025"
		rconport="21026"
		maxplayers="8"
	else
		servername=$(grep "serverName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/serverName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		queryenabled=$(grep "runQueryServer" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/runQueryServer//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconenabled=$(grep "runRconServer" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/runRconServer//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rconServerPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/rconServerPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "gameServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "queryServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		rconport=$(grep "rconServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		maxplayers=$(grep "maxPlayers" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		queryenabled=${queryenabled:-"NOT SET"}
		rconenabled=${rconenabled:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"21025"}
		queryport=${queryport:-"21025"}
		rconport=${rconport:-"21026"}
		maxplayers=${maxplayers:-"8"}
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

		ip=$(grep "voice_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/voice_ip//g' | sed 's/,.*//' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="voice_ip"

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
		servername="Mumble"
	else
		port=$(grep "port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^;/d' -e 's/port//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		queryport="${port}"

		ip=$(grep "host=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^;/d' -e 's/host=//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="voice_ip"

		# Not Set
		port=${port:-"64738"}
		queryport=${queryport:-"64738"}
		servername="Mumble Port ${port}"
	fi
}

fn_info_config_samp(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="unnamed server"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		port="7777"
		maxplayers="50"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		maxplayers=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"8303"}
		maxplayers=${maxplayers:-"12"}
	fi
}

fn_info_config_teeworlds(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="unnamed server"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		port="8303"
		queryport="8303"
		maxplayers="12"
	else
		servername=$(grep "sv_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^sv_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^password" | sed -e '/^#/d' -e 's/^password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "sv_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^sv_rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "sv_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryport="${port}"
		maxplayers=$(grep "sv_max_clients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"8303"}
		queryport=${port:-"8303"}
		maxplayers=${maxplayers:-"12"}
	fi
}

fn_info_config_terraria(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		port="${zero}"
		gameworld="${unavailable}"
		maxplayers="${zero}"
		queryport="${zero}"
	else
		servername=$(grep "worldname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/worldname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "port" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=${port:-"0"}
		gameworld=$(grep "world=" "${servercfgfullpath}" | grep -v "//" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/world=//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		gameworld=${gameworld:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_towerunite(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
	else
		servername=$(grep "ServerTitle" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/ServerTitle//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_unreal(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		queryportgs="${zero}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		port=$(grep "Port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Port" | grep -v "#" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		queryportgs=$(grep "OldQueryPortNumber" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		webadminport=$(grep "ListenPort" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminuser=$(grep "AdminUsername" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminUsername//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		webadminpass=$(grep "UTServerAdmin.UTServerAdmin" "${servercfgfullpath}" -A 4 | grep "AdminPassword" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		queryportgs=${queryportgs:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"0"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi
}

fn_info_config_unreal2(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		queryportgs="${zero}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		port=$(grep "Port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Port" | grep -v "#" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		queryportgs=$(grep "OldQueryPortNumber" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		webadminport=$(grep "ListenPort" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminuser=$(grep "AdminName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'| sed 's/\r$//')
		webadminpass="${adminpassword}"

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		queryportgs=${queryportgs:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"0"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi
}

fn_info_config_unreal3(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		webadminenabled=$(grep "bEnabled" "${servercfgdir}/UTWeb.ini" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		webadminport=$(grep "ListenPort" "${servercfgdir}/UTWeb.ini" | grep -v "#" | tr -cd '[:digit:]')
		webadminuser="Admin"
		webadminpass=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"0"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi
}

fn_info_config_ut(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | awk -F '=' '{print $2}')

		# Not set
		servername=${servername:-"NOT SET"}
	fi
}

fn_info_config_warfork(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "sv_maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_kf2(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port="${unavailable}"
		queryport="${unavailable}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "Port" "${servercfgdir}/LinuxServer-KFEngine.ini" | sed -e 's/^[ \t]*//g' | grep "^Port" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgdir}/KFWeb.ini" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		webadminport=$(grep "ListenPort" "${servercfgdir}/KFWeb.ini" | grep -v "#" | tr -cd '[:digit:]')
		webadminuser="Admin"
		webadminpass=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
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
		maxplayers="${unavailable}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		serverpassword=$(grep "ServerPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		port=$(grep "ServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=${port:-"0"}

		webadminenabled=$(grep "ControlPanelEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		webadminport=$(grep "ControlPanelPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminpass=$(grep "ControlPanelPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		telnetenabled=$(grep "TelnetEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		telnetport=$(grep "TelnetPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		telnetpass=$(grep "TelnetPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")

		maxplayers=$(grep "ServerMaxPlayerCount" "${servercfgfullpath}" | tr -cd '[:digit:]')
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
		maxplayers=${maxplayers:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_config_mta(){
	if [ ! -f "${servercfgfullpath}" ]; then
		ip="${zero}"
		port="${unavailable}"
		httpport="${unavailable}"
		ase="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		port=$(grep -m 1 "serverport" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<serverport>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<" | tr -cd '[:digit:]')
		httpport=$(grep -m 1 "httpport" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<httpport>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<" | tr -cd '[:digit:]')
		servername=$(grep -m 1 "servername" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<servername>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<")
		serverpassword=$(grep -m 1 "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<password>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<")
		maxplayers=$(grep -m 1 "maxplayers" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<maxplayers>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<" | tr -cd '[:digit:]')
		ase=$(grep -m 1 "ase" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<ase>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<" | tr -cd '[:digit:]')
		if [ "${ase}" == "1" ]; then
			ase="Enabled"
		else
			ase="Disabled"
		fi
		# ip=$(grep -m 1 "serverip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<serverip>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<")
		# ipsetinconfig=1
		# ipinconfigvar="serverip"

		# Not Set
		port=${port:-"22003"}
		httpport=${httpport:-"22005"}
		ase=${ase:-"Disabled"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_wolfensteinenemyterritory(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
	else
		port=$(grep "set net_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		queryport="${port}"
		rconpassword=$(grep "set zmq_rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set zmq_rcon_password //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//g' -e '/^\//d' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "set sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "set g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "set sv_maxclients" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

		ip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="set net_ip"

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"27960"}
		queryport=${queryport:-"27960"}
	fi
}

fn_info_config_etlegacy(){
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
	else
		port=$(grep "set net_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		queryport="${port}"
		rconpassword=$(grep "set rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//g' -e '/^\//d' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "set sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "set g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set g_password //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "set sv_maxclients" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')

		ip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="set net_ip"

		# Not Set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"27960"}
		queryport=${queryport:-"27960"}
	fi
}

fn_info_config_wurmunlimited(){
	if [ ! -f "${servercfgfullpath}" ]; then
		port="${zero}"
		queryport="${zero}"
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		maxplayers="${zero}"
	else

		port=$(grep "EXTERNALPORT=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryport=$(grep "QUERYPORT=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		servername=$(grep "SERVERNAME=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/SERVERNAME//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "SERVERPASSWORD=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/SERVERPASSWORD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "ADMINPWD=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/ADMINPWD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MAXPLAYERS=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		ip=$(grep "IP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/IP//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		ipsetinconfig=1
		ipinconfigvar="IP"

		# Not Set
		port=${port:-"3724"}
		queryport=${queryport:-"27017"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_squad(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')
	fi

	if [ ! -f "${servercfgdir}/Rcon.cfg" ]; then
		rconport=${unavailable}
		rconpassword=${unavailable}
	else
		rconport=$(grep "Port=" "${servercfgdir}/Rcon.cfg" | tr -cd '[:digit:]')
		rconpassword=$(grep "Password=" "${servercfgdir}/Rcon.cfg" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
	fi

	rconport=${rconport:-"0"}
	if [ -z "${rconpassword}" ]||[ ${#rconpassword} == 1 ]; then
		rconpassword="NOT SET"
	fi
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_config_stationeers(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "SERVERNAME" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/SERVERNAME//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "PASSWORD" "${servercfgfullpath}" | grep "^PASSWORD" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/PASSWORD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "RCONPASSWORD" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/RCONPASSWORD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MAXPLAYER" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/MAXPLAYER//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not Set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_config_mordhau(){
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | awk -F '=' '{print $2}')
		serverpassword=$(grep "ServerPassword" "${servercfgfullpath}" | awk -F '=' '{print $2}')
		rconpassword=$(grep "AdminPassword" "${servercfgfullpath}" | awk -F '=' '{print $2}')
		maxplayers=$(grep "MaxSlots" "${servercfgfullpath}" | awk -F '=' '{print $2}')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}


fn_info_config_avorion() {
	if [ ! -f "${servercfgfullpath}" ]; then
		maxplayers="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		rconport="${unavailable}"
		rconenabled="${unavailable}"
		queryport="${unavailable}"
	else
		maxplayers=$(grep "maxPlayers=" "${servercfgfullpath}" | sed 's/maxPlayers=//')
		servername=$(grep "name=" "${servercfgfullpath}" | sed 's/name=//')
		serverpassword=$(grep "password=" "${servercfgfullpath}" | sed 's/password=//')
		rconpassword=$(grep "rconPassword=" "${servercfgfullpath}" | sed 's/rconPassword=//')
		rconport=$(grep "rconPort=" "${servercfgfullpath}" | sed 's/rconPort=//')
		if [ -n "${rconpassword}" ]; then
			rconenabled="true"
			queryport="${rconport}"
		fi

		# Not set
		maxplayers=${maxplayers:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"0"}
		rconenabled=${rconenabled:-"false"}
		queryport=${queryport:-"0"}
	fi
}

fn_info_config_soldat(){
	if [ ! -f "${servercfgfullpath}" ]; then
		adminpassword="${unavailable}"
		maxplayers="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
	else
		adminpassword=$(grep "Admin_Password=" "${servercfgfullpath}" | awk -F '=' '{print $2}')
		maxplayers=$(grep "Max_Players=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		port=$(grep "Port=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport="${port}"
		servername=$(grep "Server_Name=" "${servercfgfullpath}" | awk -F '=' '{print $2}')
		serverpassword=$(grep "Game_Password=" "${servercfgfullpath}" | awk -F '=' '{print $2}')

		# Not set
		adminpassword=${adminpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"23073"}
		queryport=${queryport:-"23083"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
	fi
}

# Assetto Corsa
if [ "${shortname}" == "ac" ]; then
	fn_info_config_assettocorsa
# ARK: Survival Evolved
elif [ "${shortname}" == "ark" ]; then
	fn_info_config_ark
# Avorion
elif [ "${shortname}" == "av" ]; then
	fn_info_config_avorion
# Ballistic Overkill
elif [ "${shortname}" == "bo" ]; then
	fn_info_config_ballistic_overkill
# Barotrauma
elif [ "${shortname}" == "bt" ]; then
	fn_info_config_barotrauma
# Battalion 1944
elif [ "${shortname}" == "bt1944" ]; then
	fn_info_config_battalion1944
# Battlefield: 1942
elif [ "${shortname}" == "bf1942" ]; then
	fn_info_config_bf1942
# Call of Duty
elif [ "${shortname}" == "cod" ]||[ "${shortname}" == "coduo" ]; then
	fn_info_config_cod
# Call of Duty 2
elif [ "${shortname}" == "cod2" ]; then
	fn_info_config_cod2
# Call of Duty 4
elif [ "${shortname}" == "cod4" ]; then
	fn_info_config_cod4
# Call of Duty: World at War
elif [ "${shortname}" == "codwaw" ]; then
	fn_info_config_codwaw
# Dont Starve Together
elif [ "${shortname}" == "dst" ]; then
	fn_info_config_dontstarve
# Eco
elif [ "${shortname}" == "eco" ]; then
	fn_info_config_eco
# Factorio
elif [ "${shortname}" == "fctr" ]; then
	fn_info_config_factorio
# Insurgency: Sandstorm
elif [ "${shortname}" == "inss" ]; then
	fn_info_config_inss
# Just Cause 2
elif [ "${shortname}" == "jc2" ]; then
	fn_info_config_justcause2
# Just Cause 3
elif [ "${shortname}" == "jc3" ]; then
	fn_info_config_justcause3
# Killing Floor 2
elif [ "${shortname}" == "kf2" ]; then
	fn_info_config_kf2
# Medal of Honor: Allied Assault
elif [ "${shortname}" == "mohaa" ]; then
	fn_info_config_mohaa
# QuakeWorld
elif [ "${shortname}" == "qw" ]; then
	fn_info_config_quakeworld
# Quake 2
elif [ "${shortname}" == "q2" ]; then
	fn_info_config_quake2
# Quake 3
elif [ "${shortname}" == "q3" ]; then
	fn_info_config_quake3
# Quake Live
elif [ "${shortname}" == "ql" ]; then
	fn_info_config_quakelive
# Minecraft
elif [ "${shortname}" == "mc" ]; then
	fn_info_config_minecraft
# Minecraft Bedrock
elif [ "${shortname}" == "mcb" ]; then
	fn_info_config_minecraft_bedrock
# Onset
elif [ "${shortname}" == "onset" ]; then
	fn_info_config_onset
# Post Scriptum: The Bloody Seventh
elif [ "${shortname}" == "pstbs" ]; then
	fn_info_config_pstbs
# Project Cars
elif [ "${shortname}" == "pc" ]; then
	fn_info_config_projectcars
# Project Zomboid
elif [ "${shortname}" == "pz" ]; then
	fn_info_config_projectzomboid
# ARMA 3
elif [ "${shortname}" == "arma3" ]; then
	fn_info_config_realvirtuality
# Return to Castle Wolfenstein
elif [ "${shortname}" == "rtcw" ]; then
	fn_info_config_rtcw
# Rising World
elif [ "${shortname}" == "rw" ]; then
	fn_info_config_risingworld
# Serious Sam
elif [ "${shortname}" == "ss3" ]; then
	fn_info_config_seriousengine35
# Soldat
elif [ "${shortname}" == "sol" ]; then
	fn_info_config_soldat
# Soldier Of Fortune 2: Gold Edition
elif [ "${shortname}" == "sof2" ]; then
	fn_info_config_sof2
# Source Engine Games
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsrc" ]; then
	fn_info_config_source
# Starbound
elif [ "${shortname}" == "sb" ]; then
	fn_info_config_starbound
# Teamspeak 3
elif [ "${shortname}" == "ts3" ]; then
	fn_info_config_teamspeak3
# Mumble
elif [ "${shortname}" == "mumble" ]; then
	fn_info_config_mumble
# San Andreas Multiplayer
elif [ "${shortname}" == "samp" ]; then
	fn_info_config_samp
# StickyBots
elif [ "${shortname}" == "pstbs" ]; then
	fn_info_config_sbots
# Teeworlds
elif [ "${shortname}" == "tw" ]; then
	fn_info_config_teeworlds
# Terraria
elif [ "${shortname}" == "terraria" ]; then
	fn_info_config_terraria
# Tower Unite
elif [ "${shortname}" == "tu" ]; then
	fn_info_config_towerunite
# Unreal engine
elif [ "${engine}" == "unreal" ]; then
	fn_info_config_unreal
# Unreal 2 engine
elif [ "${engine}" == "unreal2" ]; then
	fn_info_config_unreal2
# Unreal 3 engine
elif [ "${engine}" == "unreal3" ]; then
	fn_info_config_unreal3
elif [ "${shortname}" == "ut" ]; then
	fn_info_config_ut
# 7 Day To Die (unity3d)
elif [ "${shortname}" == "sdtd" ]; then
	fn_info_config_sdtd
elif [ "${shortname}" == "wet" ]; then
	fn_info_config_wolfensteinenemyterritory
elif [ "${shortname}" == "wf" ]; then
	fn_info_config_warfork
elif [ "${shortname}" == "etl" ]; then
	fn_info_config_etlegacy
elif [ "${shortname}" == "wurm" ]; then
	fn_info_config_wurmunlimited
elif [ "${shortname}" == "mta" ]; then
	fn_info_config_mta
elif [ "${shortname}" == "squad" ]; then
	fn_info_config_squad
# Stationeers
elif [ "${shortname}" == "st" ]; then
	fn_info_config_stationeers
elif [ "${shortname}" == "mh" ]; then
	fn_info_config_mordhau
fi
