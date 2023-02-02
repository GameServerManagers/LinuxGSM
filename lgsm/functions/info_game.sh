#!/bin/bash
# LinuxGSM info_game.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Gathers various game server information.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

## Examples of filtering to get info from config files.
# sed 's/foo//g' - remove foo
# tr -cd '[:digit:]' leave only digits
# tr -d '=\"; ' remove selected characters =\";
# grep -v "foo" filter out lines that contain foo
# cut -f1 -d "/" remove everything after /

fn_info_game_ac() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		adminpassword="${unavailable}"
		httpport="${zero}"
		port="${zero}"
		queryport="${zero}"
		servername="${unavailable}"
	else
		adminpassword=$(grep "ADMIN_PASSWORD" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/ADMIN_PASSWORD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		httpport=$(grep "HTTP_PORT" "${servercfgfullpath}" | tr -cd '[:digit:]')
		port=$(grep "TCP_PORT" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport="${httpport}"
		servername=$(grep "NAME" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/NAME//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | head -n 1)

		# Not set
		adminpassword=${adminpassword:-"NOT SET"}
		httpport=${httpport:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		servername=${servername:-"NOT SET"}

	fi
}

fn_info_game_ark() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		adminpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
	else
		adminpassword=$(sed -nr 's/^ServerAdminPassword=(.*)/\1/p' "${servercfgfullpath}")
		servername=$(sed -nr 's/^SessionName=(.*)/\1/p' "${servercfgfullpath}")
		serverpassword=$(sed -nr 's/^ServerPassword=(.*)/\1/p' "${servercfgfullpath}")

		# Not set
		adminpassword=${adminpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
	fi

	# Parameters
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	rawport=$((port + 1))
	rconport=${rconport:-"0"}
}

fn_info_game_arma3() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		adminpassword="${unavailable}"
		maxplayers="${zero}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
	else
		adminpassword=$(sed -nr 's/^passwordAdmin\s*=\s*"(.*)"\s*;/\1/p' "${servercfgfullpath}")
		maxplayers=$(sed -nr 's/^maxPlayers\s*=\s*([0-9]+)\s*;/\1/p' "${servercfgfullpath}")
		servername=$(sed -nr 's/^hostname\s*=\s*"(.*)"\s*;/\1/p' "${servercfgfullpath}")
		serverpassword=$(sed -nr 's/^password\s*=\s*"(.*)"\s*;/\1/p' "${servercfgfullpath}")

		# Not set
		adminpassword=${adminpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
	fi

	# Parameters
	battleeyeport=$((port + 4))
	port=${port:-"2302"}
	queryport=$((port + 1))
	steammasterport=$((port + 2))
	voiceport=${port:-"2302"}
	voiceunusedport=$((port + 3))
}

fn_info_game_armar() {
	if [ ! -f "${servercfgfullpath}" ]; then
		adminpassword="${unavailable}"
		maxplayers="${zero}"
		port=${port:-"0"}
		queryport=
		servername="${unavailable}"
		serverpassword="${unavailable}"
	else
		adminpassword=$(jq -r '.adminPassword' "${servercfgfullpath}")
		battleeyeport=1376
		configip=$(jq -r '.gameHostBindAddress' "${servercfgfullpath}")
		maxplayers=$(jq -r '.game.playerCountLimit' "${servercfgfullpath}")
		port=$(jq -r '.gameHostBindPort' "${servercfgfullpath}")
		queryport=$(jq -r '.steamQueryPort' "${servercfgfullpath}")
		servername=$(jq -r '.game.name' "${servercfgfullpath}")
		serverpassword=$(jq -r '.game.password' "${servercfgfullpath}")

		# Not set
		adminpassword=${adminpassword:-"NOT SET"}
		configip=${configip:-"0.0.0.0"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
	fi
}

fn_info_game_av() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		maxplayers="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		port=${zero}
		queryport=${zero}
		steamqueryport=${zero}
		steammasterport=${zero}
		rconport=${zero}
		rconenabled="${unavailable}"
		rconpassword="${unavailable}"
	else
		maxplayers=$(grep "maxPlayers=" "${servercfgfullpath}" | sed 's/maxPlayers=//')
		servername=$(grep "name=" "${servercfgfullpath}" | sed 's/name=//')
		serverpassword=$(grep "password=" "${servercfgfullpath}" | sed 's/password=//')
		port=$(grep "port=" "${servercfgfullpath}" | sed 's/port=//')
		queryport=$((port + 3))
		steamqueryport=$((port + 20))
		steammasterport=$((port + 21))
		rconport=$(grep "rconPort=" "${servercfgfullpath}" | sed 's/rconPort=//')

		rconpassword=$(grep "rconPassword=" "${servercfgfullpath}" | sed 's/rconPassword=//')
		if [ -n "${rconpassword}" ]; then
			rconenabled="true"
		fi

		# Not set
		maxplayers=${maxplayers:-"0"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		steamqueryport=${steamqueryport:-"0"}
		steammasterport=${steammasterport:-"0"}
		rconport=${rconport:-"0"}
		rconenabled=${rconenabled:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
	fi
}

fn_info_game_bf1942() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
	else
		servername=$(grep -E "^game.serverName " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverName //g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "game.serverPassword" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/game.serverPassword//g' | tr -d '=\";,:' | xargs)
		maxplayers=$(grep "game.serverMaxPlayers" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		port=$(grep "game.serverPort" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		queryport="22000"
		configip=$(grep "game.serverIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverIP//g' | tr -d '=\";,:' | xargs)

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_bfv() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
	else
		servername=$(grep "game.serverName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverName//g' | tr -d '=\";,:' | xargs)
		serverpassword=$(grep "game.serverPassword" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/game.serverPassword//g' | tr -d '=\";,:' | xargs)
		maxplayers=$(grep "game.serverMaxPlayers" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		port=$(grep "game.serverPort" "${servercfgfullpath}" | grep -v "\--" | tr -cd '[:digit:]')
		queryport="23000"
		configip=$(grep "game.serverIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/game.serverIP//g' | tr -d '=\";,:' | xargs)

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_bo() {
	# Config
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

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_game_bt() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		maxplayers="${unavailable}"
	else
		servername=$(grep -Po 'name="\K.*(?=")' "${servercfgfullpath}")         # Assuming GNU grep is used
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

fn_info_game_bt1944() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		gamemode="${unavailable}"
	else
		servername=$(grep -m2 "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | grep -v "RCONPassword" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		gamemode=$(grep -m2 "PlayMode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/PlayMode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	rconport=$((port + 2))
}

fn_info_game_cd() {
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		port="${zero}"
		rconenabled="false"
		rconport="${zero}"
		rconpassword="${unavailable}"
		steamport="${zero}"
		maxplayers="${zero}"
	else
		servername=$(jq -r '.game_title' "${servercfgfullpath}")
		port=$(jq -r '.game_port' "${servercfgfullpath}")
		steamport=$(jq -r '.steam_port_messages' "${servercfgfullpath}")
		rconenabled=$(jq -r '.rcon' "${servercfgfullpath}")
		rconport=$(jq -r '.rcon_port' "${servercfgfullpath}")
		rconpassword=$(jq -r '.rcon_password' "${servercfgfullpath}")
		maxplayers=$(jq -r '.player_count' "${servercfgfullpath}")
	fi
}

fn_info_game_cmw() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		adminpassword="${unavailable}"
		rconport=${zero}
		servername="${unavailable}"
		serverpassword="${unavailable}"

	else
		adminpassword=$(grep -E "^adminpassword=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		rconport=$(grep -E "^RConPort=" "${servercfgdir}/DefaultGame.ini" | tr -cd '[:digit:]')
		servername=$(grep -E "^ServerName" "${servercfgfullpath}" | sed 's/^ServerName=//')
		serverpassword=$(grep -E "^GamePassword" "${servercfgfullpath}" | sed 's/^ServerName=//')

		# Not set
		adminpassword=${adminpassword:-"NOT SET"}
		rconport=${rconport:-"0"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
}

fn_info_game_cod() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
}

fn_info_game_coduo() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port:-"28960"}
}

fn_info_game_cod2() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port:-"28960"}
}

fn_info_game_cod4() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(sed -nr 's/^set\s*sv_hostname\s*"(.*)".*/\1/p' "${servercfgfullpath}")
		rconpassword=$(sed -nr 's/^set\s*rcon_password\s*"(.*)"\s*\/.*/\1/p' "${servercfgfullpath}")
		queryport=${port:-"28960"}

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
		queryport=${queryport:-"28960"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port:-"28960"}
}

fn_info_game_codwaw() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "sv_hostname " "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname //g' | tr -d '=\";,:' | xargs)
		rconpassword=$(grep "rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rconpassword //g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword=:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port:-"28960"}
}

fn_info_game_col() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		steamport="${zero}"
		rconpassword="${unavailable}"
	else
		servername=$(jq -r '.ServerSettings.ServerName' "${servercfgfullpath}")
		serverpassword=$(jq -r '.ServerSettings.ServerPassword' "${servercfgfullpath}")
		maxplayers=$(jq -r '.ServerSettings.MaxPlayerCount' "${servercfgfullpath}")
		port=$(jq -r '.ServerSettings.ServerGamePort' "${servercfgfullpath}")
		queryport=${port:-"0"}
		steamport=$(jq -r '.ServerSettings.ServerSteamPort' "${servercfgfullpath}")
		rconpassword=$(jq -r '.ServerSettings.RCONPassword' "${servercfgfullpath}")
		configip=$(jq -r '.ServerSettings.ServerIP' "${servercfgfullpath}")

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"27004"}
		queryport=${queryport:-"0"}
		steamport=${steamport:-"27005"}
		rconpassword=${rconpassword:-"NOT SET"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_dodr() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		maxplayers="${zero}"
	else
		maxplayers=$(sed -nr 's/^iServerMaxPlayers=(.*)$/\1/p' "${servercfgfullpath}")

		# Not set
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	servername=${servername:-"NOT SET"}
	port=${port:-"7777"}
	queryport=${queryport:-"27015"}
}

fn_info_game_dayz() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		adminpassword="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		servername=$(sed -nr 's/^hostname\s*=\s*"(.*)"\s*;/\1/p' "${servercfgfullpath}")
		adminpassword=$(sed -nr 's/^passwordAdmin\s*=\s*"(.*)"\s*;/\1/p' "${servercfgfullpath}")
		serverpassword=$(sed -nr 's/^password\s*=\s*"(.*)"\s*;/\1/p' "${servercfgfullpath}")
		maxplayers=$(sed -nr 's/^maxPlayers\s*=\s*([0-9]+)\s*;/\1/p' "${servercfgfullpath}")
		queryport=$(sed -nr 's/^steamQueryPort\s*=\s*([0-9]+)\s*;/\1/p' "${servercfgfullpath}")

		# Not Set
		servername=${servername:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		queryport=${queryport:-"27016"}
	fi

	# Parameters
	port=${port:-"2302"}
	steammasterport=$((port + 2))
	battleeyeport=$((port + 4))
}

fn_info_game_dst() {
	# Config
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
		configip=$(grep "bind_ip" "${clustercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bind_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		gamemode=${gamemode:-"NOT SET"}
		tickrate=${tickrate:-"0"}
		masterport=${masterport:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi

	if [ ! -f "${servercfgfullpath}" ]; then
		port="${zero}"
		steamauthport="${zero}"
		steammasterport="${zero}"
	else
		port=$(grep "server_port" "${servercfgfullpath}" | grep "^server_port" | grep -v "#" | tr -cd '[:digit:]')
		steamauthport=$(grep "authentication_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		steammasterport=$(grep "master_server_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not set
		port=${port:-"0"}
		steamauthport=${steamauthport:-"0"}
		steammasterport=${steammasterport:-"0"}
	fi

	# Parameters
	sharding=${sharding:-"NOT SET"}
	master=${master:-"NOT SET"}
	shard=${shard:-"NOT SET"}
	cluster=${cluster:-"NOT SET"}
	cave=${cave:-"NOT SET"}
}

fn_info_game_eco() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		tickrate="${zero}"
		port="${zero}"
		webadminport="${zero}"
	else
		configip=$(jq -r '.IPAddress' "${servercfgfullpath}")
		servername=$(jq -r '.Description' "${servercfgfullpath}")
		serverpassword=$(jq -r '.Password' "${servercfgfullpath}")
		maxplayers=$(jq -r '.MaxConnections' "${servercfgfullpath}")
		tickrate=$(jq -r '.Rate' "${servercfgfullpath}")
		port=$(jq -r '.GameServerPort' "${servercfgfullpath}")
		webadminport=$(jq -r '.WebServerPort' "${servercfgfullpath}")

		# Not set
		configip=${configip:-"0.0.0.0"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers=:-"0"}
		tickrate=${tickrate=:-"0"}
		port=${port=:-"0"}
		webadminport=${webadminport=:-"0"}
	fi
}

fn_info_game_etl() {
	# Config
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
		configip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"27960"}
		queryport=${queryport:-"27960"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_fctr() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="Factorio Server"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		authtoken="${unavailable}"
		savegameinterval="${unavailable}"
		versioncount="${unavailable}"
	else
		servername=$(jq -r '.name' "${servercfgfullpath}")
		serverpassword=$(jq -r '.game_password' "${servercfgfullpath}")
		maxplayers=$(jq -r '.max_players' "${servercfgfullpath}")
		authtoken=$(jq -r '.token' "${servercfgfullpath}")
		savegameinterval=$(jq -r '.autosave_interval' "${servercfgfullpath}")
		versioncount=$(jq -r '.autosave_slots' "${servercfgfullpath}")

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		authtoken=${authtoken:-"NOT SET"}
		savegameinterval=${savegameinterval:-"0"}
		versioncount=${versioncount:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	rconport=${rconport:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}

	# get server version if installed
	local factoriobin="${executabledir}${executable:1}"
	if [ -f "${factoriobin}" ]; then
		serverversion=$(${factoriobin} --version | grep "Version:" | awk '{print $2}')
	fi
}

fn_info_game_jc2() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverdescription="${unavailable}"
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
		configip=$(grep "BindIP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/BindIP//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		serverdescription=${serverdescription:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_hw() {
	# Parameters
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	maxplayers=${maxplayers:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
	creativemode=${creativemode:-"NOT SET"}
}

fn_info_game_inss() {
	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	rconport=${rconport:-"0"}
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	defaultmap=${defaultmap:-"NOT SET"}
	defaultscenario=${defaultscenario:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_game_jc3() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverdescription="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryPort="${zero}"
		steamport="${zero}"
		httpport="${zero}"
		tickrate="${zero}"
	else
		servername=$(grep "name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverdescription=$(grep "description" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/description//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "\"maxPlayers\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		port=$(grep "\"port\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "\"queryPort\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		steamport=$(grep "\"steamPort\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		httpport=$(grep "\"httpPort\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		tickrate=$(grep "\"maxTickRate\"" "${servercfgfullpath}" | tr -cd '[:digit:]')
		configip=$(grep "host" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/host//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverdescription=${serverdescription:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers=:-"0"}
		port=${port=:-"0"}
		queryport=${queryport=:-"0"}
		steamport=${steamport=:-"0"}
		httpport=${httpport=:-"0"}
		tickrate=${tickrate=:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_jk2() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		serverversion="${unavailable}"
	else
		rconpassword=$(grep "seta rconpassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/seta rconpassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "seta sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/seta sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "seta g_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/seta g_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "seta sv_maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		serverversion=$(grep "seta mv_serverversion" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/seta mv_serverversion//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		serverversion=${serverversion:-"NOT SET"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_kf() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		queryportgs="${zero}"
		steamport="${zero}"
		steammasterport="${zero}"
		lanport="${zero}"
		httpport="${zero}"
		webadminenabled="${unavailable}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(sed -nr 's/^ServerName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		serverpassword=$(sed -nr 's/^GamePassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		adminpassword=$(sed -nr 's/^AdminPassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		port=$(sed -nr 's/^Port=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		queryportgs=$(sed -nr 's/^OldQueryPortNumber=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		steamport="20560"
		steammasterport="28852"
		lanport=$(grep "LANServerPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		httpport=$(sed -nr 's/^ListenPort=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminenabled=$(sed -nr 's/^bEnabled=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		webadminuser=$(sed -nr 's/^AdminName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		webadminpass="${adminpassword}"

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		queryportgs=${queryportgs:-"0"}
		steamport=${steamport:-"0"}
		steammasterport=${steammasterport:-"0"}
		lanport=${lanport:-"0"}
		httpport=${httpport:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_kf2() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port=${zero}
		queryport=${zero}
		webadminenabled="${unavailable}"
		httpport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "Port" "${servercfgdir}/LinuxServer-KFEngine.ini" | sed -e 's/^[ \t]*//g' | grep "^Port" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgdir}/KFWeb.ini" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		httpport=$(grep "ListenPort" "${servercfgdir}/KFWeb.ini" | grep -v "#" | tr -cd '[:digit:]')
		webadminuser="Admin"
		webadminpass=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		httpport=${webadminport:-"0"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi

	# Parameters
	queryport=${queryport:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_lo() {
	# Parameters
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	maxplayers=${slots:-"0"}
}

fn_info_game_mc() {
	# Config
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
		servername=$(grep "motd" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/motd//g' | tr -d '=\";,:' | sed 's/\\u00A70//g;s/\\u00A71//g;s/\\u00A72//g;s/\\u00A73//g;s/\\u00A74//g;s/\\u00A75//g;s/\\u00A76//g;s/\\u00A77//g;s/\\u00A78//g;s/\\u00A79//g;s/\\u00A7a//g;s/\\u00A7b//g;s/\\u00A7c//g;s/\\u00A7d//g;s/\\u00A7e//g;s/\\u00A7f//g;s/\\u00A7l//g;s/\\u00A7o//g;s/\\u00A7n//g;s/\\u00A7m//g;s/\\u00A7k//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
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
		configip=$(grep "server-ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/server-ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
		queryenabled="${queryenabled:-"NOT SET"}"
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_mcb() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		portipv6="${zero}"
		queryport="${zero}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "server-name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server-name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "max-players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server-port\b" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		portipv6=$(grep "server-portv6\b" "${servercfgfullpath}" | sed 's/v6//g' | grep -v "#" | tr -cd '[:digit:]')
		queryport=${port}
		gamemode=$(grep "gamemode" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/gamemode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		gameworld=$(grep "level-name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/level-name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"NOT SET"}
		portipv6=${portipv6:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_game_mh() {
	# Config
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

	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	beaconport=${beaconport:-"0"}
}

fn_info_game_mohaa() {
	# Config
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

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_mom() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		defaultmap="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "ServerPassword" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/ServerPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/MaxPlayers//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		defaultmap=$(grep "MapName" "${servercfgfullpath}" | sed -e 's/^ *//g' -e '/^--/d' -e 's/MapName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		defaultmap=${defaultmap:-"NOT SET"}
	fi

	# Parameters
	port=${port:-"7777"}
	beaconport=${queryport:-"15000"}
}

fn_info_game_mta() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		port=${zero}
		queryport=${zero}
		httpport=${zero}
		ase="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
	else
		port=$(grep -m 1 "serverport" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/<serverport>//g' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "<" | tr -cd '[:digit:]')
		queryport=$((port + 123))
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

		# Not set
		port=${port:-"22003"}
		queryport=${queryport:-"2326"}
		httpport=${httpport:-"22005"}
		ase=${ase:-"Disabled"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

}

fn_info_game_mumble() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		port="64738"
		queryport="${port}"
		servername="Mumble"
	else
		port=$(grep "port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^;/d' -e 's/port//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		queryport="${port}"
		configip=$(grep "host=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^;/d' -e 's/host=//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		port=${port:-"64738"}
		queryport=${queryport:-"64738"}
		servername="Mumble Port ${port}"
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_nec() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		servername="Necesse"
		serverpassword="${unavailable}"
	else
		maxplayers=$(grep "slots" "${servercfgfullpath}" | cut -f1 -d "/" | tr -cd '[:digit:]')
		port=$(grep "port" "${servercfgfullpath}" | cut -f1 -d "/" | tr -cd '[:digit:]')
		serverpassword=$(grep "password" "${servercfgfullpath}" | cut -f1 -d "/" | tr -cd '[:digit:]')

		# Not set
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		servername="Necesse Port ${port}"
		serverpassword=${serverpassword:-"NOT SET"}
	fi
}

fn_info_game_onset() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		httpport="${zero}"
		queryport="${zero}"
	else
		servername=$(grep -v "servername_short" "${servercfgfullpath}" | grep "servername" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/servername//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		httpport=$((port - 2))
		queryport=$((port - 1))

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"NOT SET"}
		httpport=${httpport:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
	fi
}

fn_info_game_pc() {
	# Config
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

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
		steamport=${steamport:-"NOT SET"}
	fi
}

fn_info_game_pc2() {
	# Config
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

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"NOT SET"}
		queryport=${queryport:-"NOT SET"}
		steamport=${steamport:-"NOT SET"}
	fi
}

fn_info_game_pstbs() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
		reservedslots="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=";,:' | sed -e 's/^[ \t]//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		reservedslots=$(grep "NumReservedSlots=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		reservedslots=${reservedslots:-"0"}
	fi

	if [ ! -f "${servercfgdir}/Rcon.cfg" ]; then
		rconport=${unavailable}
		rconpassword=${unavailable}
	else
		rconport=$(grep "Port=" "${servercfgdir}/Rcon.cfg" | tr -cd '[:digit:]')
		rconpassword=$(grep "Password=" "${servercfgdir}/Rcon.cfg" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		rconport=${rconport:-"0"}
		if [ -z "${rconpassword}" ] || [ ${#rconpassword} == 1 ]; then
			rconpassword="NOT SET"
		fi
	fi

	# Parameters
	port=${port:-"0"}
	if [ -z "${queryport}" ]; then
		queryport=${port:-"0"}
	fi
	rconport=${rconport:-"0"}
	randommap=${randommap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	reservedslots=${reservedslots:-"0"}
}

fn_info_game_pvr() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | awk -F '=' '{print $2}')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | awk -F '=' '{print $2}')

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	port401=$((port + 400))
	queryport=${port:-"0"}
}

fn_info_game_pz() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
		gameworld="${unavailable}"
	else
		servername=$(grep "PublicName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/PublicName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "Password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Password" | sed -e '/^#/d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "RCONPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/RCONPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "DefaultPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=${port}
		gameworld=$(grep "Map" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Map" | sed -e '/^#/d' -e 's/Map//g' | tr -d '=\";' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		gameworld=${gameworld:-"NOT SET"}
	fi

	# Parameters
	adminpassword=${adminpassword:-"NOT SET"}

}

fn_info_game_q2() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_q3() {
	# Config
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

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_ql() {
	# Config
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
		queryport=${port}
		rconport=$(grep "zmq_rcon_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		statsport=$(grep "zmq_stats_port" "${servercfgfullpath}" | grep -v "//" | tr -cd '[:digit:]')
		configip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		rconport=${rconport:-"0"}
		statsport=${statsport:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_qw() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
	else
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "/")
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | cut -f1 -d "/")
		maxplayers=$(grep "maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port}
}

fn_info_game_ro() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		steamport="${zero}"
		steammasterport="${zero}"
		lanport="${zero}"
		httpport="${zero}"
		webadminenabled="${unavailable}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(sed -nr 's/^ServerName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		serverpassword=$(sed -nr 's/^GamePassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		adminpassword=$(sed -nr 's/^AdminPassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		port=$(sed -nr 's/^Port=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		steamport="20610"
		steammasterport="28902"
		lanport=$(grep "LANServerPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		httpport=$(sed -nr 's/^ListenPort=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminenabled=$(sed -nr 's/^bEnabled=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		webadminuser=$(sed -nr 's/^AdminName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		webadminpass="${adminpassword}"

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		steamport=${steamport:-"0"}
		steammasterport=${steammasterport:-"0"}
		lanport=${lanport:-"0"}
		httpport=${httpport:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_rtcw() {
	# Config
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

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_rust() {
	# Parameters
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	appport=${appport:-"0"}
	rconport=${rconport:-"0"}
	gamemode=${gamemode:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
	rconweb=${rconweb:-"NOT SET"}
	tickrate=${tickrate:-"0"}
	saveinterval=${saveinterval:-"0"}
	serverlevel=${serverlevel:-"NOT SET"}
	customlevelurl=${customlevelurl:-"NOT SET"}
	worldsize=${worldsize:-"0"}
	seed=${seed:-"0"}
	salt=${salt:-"0"}
}

fn_info_game_rw() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		rconport="${zero}"
		maxplayers="${zero}"
		port="${zero}"
		port2="${zero}"
		port3="${zero}"
		port4="${zero}"
		queryport="${zero}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "server_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "server_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconport=$(grep "rcon_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		maxplayers=$(grep "settings_max_players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server_port" "${servercfgfullpath}" | grep -v "database_mysql_server_port" | grep -v "#" | tr -cd '[:digit:]')
		port2=$((port + 1))
		port3=$((port + 2))
		port4=$((port + 3))
		queryport="${port}"
		httpqueryport=$((port - 1))
		gamemode=$(grep "settings_default_gamemode=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/settings_default_gamemode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		gameworld=$(grep "server_world_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_world_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		configip=$(grep "server_ip" "${servercfgfullpath}" | grep -v "database_mysql_server_ip" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/server_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		port2=${port2:-"0"}
		port3=${port3:-"0"}
		port4=${port4:-"0"}
		queryport=${queryport:-"0"}
		httpqueryport=${httpport:-"0"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_samp() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="unnamed server"
		rconpassword="${unavailable}"
		port="7777"
		rconport="${port}"
		maxplayers="50"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryport=${port}
		rconport=${port}
		maxplayers=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"7777"}
		queryport=${port:-"7777"}
		rconport=${rconport:-"7777"}
		maxplayers=${maxplayers:-"12"}
	fi
}

fn_info_game_sb() {
	# Config
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

		# Not set
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

fn_info_game_sbots() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=";,:' | sed -e 's/^[ \t]//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

fn_info_game_scpsl() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		configip=${configip:-"0.0.0.0"}
		tickrate=${tickrate:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
	else
		servername=$(sed -nr 's/^server_name: (.*)$/\1/p' "${servercfgfullpath}")
		maxplayers=$(sed -nr 's/^max_players: (.*)$/\1/p' "${servercfgfullpath}")
		configip=$(sed -nr 's/^ipv4_bind_ip: (.*)$/\1/p' "${servercfgfullpath}")
		tickrate=$(sed -nr 's/^server_tickrate: (.*)$/\1/p' "${servercfgfullpath}")
		adminpassword=$(sed -nr 's/^administrator_query_password: (.*)$/\1/p' "${servercfgfullpath}")
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port}
}

fn_info_game_sdtd() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		port="${zero}"
		port3="${zero}"
		queryport="${zero}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminpass="${unavailable}"
		telnetenabled="${unavailable}"
		telnetport="${zero}"
		telnetpass="${unavailable}"
		telnetip="${unavailable}"
		maxplayers="${unavailable}"
		gamemode="${unavailable}"
		gameworld="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		serverpassword=$(grep "ServerPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		port=$(grep "ServerPort" "${servercfgfullpath}" | grep -Eo 'value="[0-9]+"' | tr -cd '[:digit:]')
		port3=$((port + 2))
		queryport=${port:-"0"}
		webadminenabled=$(grep "ControlPanelEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		webadminport=$(grep "ControlPanelPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminpass=$(grep "ControlPanelPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		telnetenabled=$(grep "TelnetEnabled" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		telnetport=$(grep "TelnetPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		telnetpass=$(grep "TelnetPassword" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		# Telnet IP will be localhost if no password is set
		# check_ip will set the IP first. This will overwrite it.
		if [ -z "${telnetpass}" ]; then
			telnetip="127.0.0.1"
		fi
		maxplayers=$(grep "ServerMaxPlayerCount" "${servercfgfullpath}" | tr -cd '[:digit:]')
		gamemode=$(grep "GameMode" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")
		gameworld=$(grep "GameWorld" "${servercfgfullpath}" | sed 's/^.*value="//' | cut -f1 -d"\"")

		# Not set
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
		maxplayers=${maxplayers:-"0"}
		gamemode=${gamemode:-"NOT SET"}
		gameworld=${gameworld:-"NOT SET"}
	fi
}

fn_info_game_sf() {
	# Parameters
	servername=${selfname:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	beaconport=${beaconport:-"0"}
}

fn_info_game_sof2() {
	# Config
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

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_sol() {
	# Config
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
		filesport=$((port + 10))
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

fn_info_game_source() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "sv_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/sv_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	rconport=${port:-"0"}
	queryport=${port:-"0"}
	clientport=${clientport:-"0"}
	# Steamport can be between 26901-26910 and is normaly automatically set.
	# Some servers might support -steamport parameter to set
	if [ "${steamport}" == "0" ] || [ -v "${steamport}" ]; then
		steamport="$(echo "${ssinfo}" | grep "${srcdslinuxpid}" | awk '{print $5}' | grep ":269" | cut -d ":" -f2)"
	fi
}

fn_info_game_spark() {
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=$((port + 1))
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	webadminuser=${webadminuser:-"NOT SET"}
	webadminpass=${webadminpass:-"NOT SET"}
	webadminport=${webadminport:-"0"}
	# Commented out as displaying not set in details parameters
	#mods=${mods:-"NOT SET"}
}

fn_info_game_squad() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	if [ ! -f "${servercfgdir}/Rcon.cfg" ]; then
		rconport=${unavailable}
		rconpassword=${unavailable}
	else
		rconport=$(grep "Port=" "${servercfgdir}/Rcon.cfg" | tr -cd '[:digit:]')
		rconpassword=$(grep "Password=" "${servercfgdir}/Rcon.cfg" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/Password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		rconport=${rconport:-"0"}
		if [ -z "${rconpassword}" ] || [ ${#rconpassword} == 1 ]; then
			rconpassword="NOT SET"
		fi

	fi

	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
}

fn_info_game_st() {
	# Config
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

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	httpport=${port:-"0"}
	worldtype=${worldtype:-"NOT SET"}
	autosaveinterval=${autosaveinterval:-"0"}
	clearinterval=${clearinterval:-"0"}
	worldname=${worldname:-"NOT SET"}
}

fn_info_game_terraria() {
	# Config
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

		# Not set
		servername=${servername:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		gameworld=${gameworld:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

fn_info_game_stn() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		configip=${configip:-"0.0.0.0"}
		port="${zero}"
		queryport="${zero}"
		serverpassword=${serverpassword:-"NOT SET"}
	else
		servername=$(sed -nr 's/^ServerName="(.*)"/\1/p' "${servercfgfullpath}")
		configip=$(sed -nr 's/^ServerIP=([0-9]+)/\1/p' "${servercfgfullpath}")
		port=$(sed -nr 's/^ServerPort=([0-9]+)/\1/p' "${servercfgfullpath}")
		serverpassword=$(sed -nr 's/^ServerPassword=(.*)$/\1/p' "${servercfgfullpath}")
		queryport=$((port + 1))

		# Not set
		serverpassword=${serverpassword:-"NOT SET"}
		port=${port:-"0"}
		serverpassword=${serverpassword:-"NOT SET"}
		queryport=${queryport:-"0"}
	fi
}

fn_info_game_ti() {
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
	else
		servername=$(sed -nr 's/^ServerName="(.*)"/\1/p' "${servercfgfullpath}")
		maxplayers=$(sed -nr 's/^MaxPlayerCount=([0-9]+)/\1/' "${servercfgfullpath}")

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

}

fn_info_game_ts3() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		dbplugin="${unavailable}"
		port="9987"
		queryport="10011"
		querysshport="10022"
		queryhttpport="10080"
		queryhttpsport="10443"
		fileport="30033"
		telnetport="10011"
	else
		dbplugin=$(grep "dbplugin=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/dbplugin=//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "default_voice_port" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "query_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		querysshport=$(grep "query_ssh_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryhttpport=$(grep "query_http_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryhttpsport=$(grep "query_https_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		fileport=$(grep "filetransfer_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		telnetport="${queryport}"
		configip=$(grep "voice_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/voice_ip//g' | sed 's/,.*//' | tr -d '=\";,' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		dbplugin=${dbplugin:-"NOT SET"}
		port=${port:-"9987"}
		queryport=${queryport:-"10011"}
		querysshport=${querysshport:-"10022"}
		queryhttpport=${queryhttpport:-"10080"}
		queryhttpsport=${queryhttpsport:-"10443"}
		fileport=${fileport:-"30033"}
		telnetport=${telnetport:-"10011"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_tu() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
	else
		servername=$(grep "ServerTitle" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/ServerTitle//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	steamport=$((port + 1))
	queryport=${queryport:-"0"}
}

fn_info_game_tw() {
	# Config
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

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"8303"}
		queryport=${port:-"8303"}
		maxplayers=${maxplayers:-"12"}
	fi
}

fn_info_game_ut99() {
	# Config
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
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | sed 's/\r$//')
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | sed 's/\r$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | sed 's/\r$//')
		port=$(grep "Port" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' | grep "^Port" | grep -v "#" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		queryportgs=$(grep "OldQueryPortNumber" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		beaconport=$(grep "ServerBeaconPort" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | sed 's/\r$//')
		httpport=$(grep "ListenPort" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminuser=$(grep "AdminUsername" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminUsername//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | sed 's/\r$//')
		webadminpass=$(grep "UTServerAdmin.UTServerAdmin" "${servercfgfullpath}" -A 4 | grep "AdminPassword" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' | sed 's/\r$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		beaconport=${beaconport:-"8777"}
		queryportgs=${queryportgs:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"0"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_unreal2() {
	# Config
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
		servername=$(sed -nr 's/^ServerName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		serverpassword=$(sed -nr 's/^GamePassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		adminpassword=$(sed -nr 's/^AdminPassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		port=$(sed -nr 's/^Port=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		queryportgs=$(sed -nr 's/^OldQueryPortNumber=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminenabled=$(sed -nr 's/^bEnabled=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		webadminport=$(sed -nr 's/^ListenPort=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminuser=$(sed -nr 's/^AdminName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		webadminpass="${adminpassword}"

		# Not set
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

	# Parameters
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_unt() {
	# Parameters
	servername=${selfname:-"NOT SET"}
	port=${port:-"0"}
	queryport=${port}
	steamport=$((port + 1))
}

fn_info_game_ut() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | awk -F '=' '{print $2}')

		# Not set
		servername=${servername:-"NOT SET"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=$((port + 1))
}

fn_info_game_unreal2k4() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		queryportgs="${zero}"
		lanport="${zero}"
		webadminenabled="${unavailable}"
		httpport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(sed -nr 's/^ServerName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		serverpassword=$(sed -nr 's/^GamePassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		adminpassword=$(sed -nr 's/^AdminPassword=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		port=$(sed -nr 's/^Port=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$((port + 1))
		queryportgs=$(sed -nr 's/^OldQueryPortNumber=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		lanport=$(grep "LANServerPort=" "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminenabled=$(sed -nr 's/^bEnabled=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		httpport=$(sed -nr 's/^ListenPort=(.*)$/\1/p' "${servercfgfullpath}" | tr -cd '[:digit:]')
		webadminuser=$(sed -nr 's/^AdminName=(.*)$/\1/p' "${servercfgfullpath}" | tr -d '=\";,:' | sed 's/\r$//')
		webadminpass="${adminpassword}"

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		port=${port:-"0"}
		queryport=${queryport:-"0"}
		queryportgs=${queryportgs:-"0"}
		lanport=${lanport:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		httpport=${httpport:-"0"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi
}

fn_info_game_ut3() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		maxplayers="${unavailable}"
		webadminenabled="${unavailable}"
		webadminport="${zero}"
		webadminuser="${unavailable}"
		webadminpass="${unavailable}"
	else
		servername=$(grep "ServerName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "GamePassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/GamePassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		webadminenabled=$(grep "bEnabled" "${servercfgdir}/UTWeb.ini" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/bEnabled//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		webadminport=$(grep "ListenPort" "${servercfgdir}/UTWeb.ini" | grep -v "#" | tr -cd '[:digit:]')
		webadminuser="Admin"
		webadminpass=$(grep "AdminPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/AdminPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		webadminenabled=${webadminenabled:-"NOT SET"}
		webadminport=${webadminport:-"0"}
		webadminuser=${webadminuser:-"NOT SET"}
		webadminpass=${webadminpass:-"NOT SET"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

fn_info_game_vh() {
	# Parameters
	port=${port:-"0"}
	# Query port only enabled if public server
	if [ "${public}" != "0" ]; then
		queryport=$((port + 1))
	else
		querymode="1"
	fi
	gameworld=${gameworld:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	servername=${servername:-"NOT SET"}
}

fn_info_game_vints() {
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
		serverpassword="${unavailable}"
		port="${port:-"0"}"
	else
		servername=$(jq -r '.ServerName' "${servercfgfullpath}")
		maxplayers=$(jq -r '.MaxClients' "${servercfgfullpath}")
		serverpassword=$(jq -r 'select(.Password != null) | .Password' "${servercfgfullpath}")
		port=$(jq -r '.Port' "${servercfgfullpath}")
		configip=$(jq -r 'select(.Ip != null) | .Ip' "${servercfgfullpath}")
	fi
	queryport=${port:-"0"}
	serverpassword=${serverpassword:-"NOT SET"}
	configip=${configip:-"0.0.0.0"}
}

fn_info_game_vpmc() {
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		configip="0.0.0.0"
		port="25577"
	else
		servername=$(sed -nr 's/^motd\s*=\s*"(.*)"/\1/p' "${servercfgfullpath}")
		bindaddress=$(sed -nr 's/^bind\s*=\s*"([0-9.:]+)"/\1/p' "${servercfgfullpath}")
		configip=$(echo "${bindaddress}" | cut -d ':' -f 1)
		port=$(echo "${bindaddress}" | cut -d ':' -f 2)

		servername=${servername:-"NOT SET"}
	fi
	queryport=${port:-"25577"}
}

fn_info_game_wet() {
	# Config
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
		configip=$(grep "set net_ip" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set net_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"27960"}
		queryport=${queryport:-"27960"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_wf() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		rconpassword="${unavailable}"
		servername="${unavailable}"
		maxplayers="${zero}"
	else
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		servername=$(grep "sv_hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/set sv_hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "sv_maxclients" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not set
		rconpassword=${rconpassword:-"NOT SET"}
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport="${port:-"0"}"
	webadminport=${webadminport:-"0"}
}

fn_info_game_wmc() {
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
		queryenabled="${unavailable}"
	else
		servername=$(sed -e '/^listeners:/,/^[a-z]/!d' "${servercfgfullpath}" | sed -nr 's/^[ ]+motd: (.*)$/\1/p' | tr -d "'" | sed 's/&1//')
		queryport=$(sed -nr 's/^[ -]+query_port: ([0-9]+)/\1/p' "${servercfgfullpath}")
		queryenabled=$(sed -nr 's/^[ ]+query_enabled: (.*)$/\1/p' "${servercfgfullpath}")
		port=$(sed -nr 's/^[ ]+host: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:([0-9]+)/\1/p' "${servercfgfullpath}")
		# the normal max_players does only show in on the client side and has no effect how many players can connect.
		maxplayers=$(sed -nr 's/^player_limit: ([-]*[0-9])/\1/p' "${servercfgfullpath}")
		configip=$(sed -nr 's/^[ ]+host: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):[0-9]+/\1/p' "${servercfgfullpath}")

		if [ "${maxplayers}" == "-1" ] || [ "${maxplayers}" == "0" ]; then
			maxplayers="UNLIMITED"
		fi

		# Not set
		servername=${servername:-"NOT SET"}
		queryport=${queryport:-"25577"}
		maxplayers=${maxplayers:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi
}

fn_info_game_wurm() {
	# Config
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
		configip=$(grep "IP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/IP//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		port=${port:-"3724"}
		queryport=${queryport:-"27017"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

unavailable="${red}UNAVAILABLE${default}"
zero="${red}0${default}"

if [ "${shortname}" == "ac" ]; then
	fn_info_game_ac
elif [ "${shortname}" == "ark" ]; then
	fn_info_game_ark
elif [ "${shortname}" == "arma3" ]; then
	fn_info_game_arma3
elif [ "${shortname}" == "armar" ]; then
	fn_info_game_armar
elif [ "${shortname}" == "av" ]; then
	fn_info_game_av
elif [ "${shortname}" == "bf1942" ]; then
	fn_info_game_bf1942
elif [ "${shortname}" == "bfv" ]; then
	fn_info_game_bfv
elif [ "${shortname}" == "bo" ]; then
	fn_info_game_bo
elif [ "${shortname}" == "bt" ]; then
	fn_info_game_bt
elif [ "${shortname}" == "bt1944" ]; then
	fn_info_game_bt1944
elif [ "${shortname}" == "cd" ]; then
	fn_info_game_cd
elif [ "${shortname}" == "cmw" ]; then
	fn_info_game_cmw
elif [ "${shortname}" == "cod" ]; then
	fn_info_game_cod
elif [ "${shortname}" == "coduo" ]; then
	fn_info_game_cod
elif [ "${shortname}" == "cod2" ]; then
	fn_info_game_cod2
elif [ "${shortname}" == "cod4" ]; then
	fn_info_game_cod4
elif [ "${shortname}" == "codwaw" ]; then
	fn_info_game_codwaw
elif [ "${shortname}" == "col" ]; then
	fn_info_game_col
elif [ "${shortname}" == "dayz" ]; then
	fn_info_game_dayz
elif [ "${shortname}" == "dodr" ]; then
	fn_info_game_dodr
elif [ "${shortname}" == "dst" ]; then
	fn_info_game_dst
elif [ "${shortname}" == "eco" ]; then
	fn_info_game_eco
elif [ "${shortname}" == "etl" ]; then
	fn_info_game_etl
elif [ "${shortname}" == "fctr" ]; then
	fn_info_game_fctr
elif [ "${shortname}" == "hw" ]; then
	fn_info_game_hw
elif [ "${shortname}" == "inss" ]; then
	fn_info_game_inss
elif [ "${shortname}" == "jc2" ]; then
	fn_info_game_jc2
elif [ "${shortname}" == "jc3" ]; then
	fn_info_game_jc3
elif [ "${shortname}" == "jk2" ]; then
	fn_info_game_jk2
elif [ "${shortname}" == "kf" ]; then
	fn_info_game_kf
elif [ "${shortname}" == "kf2" ]; then
	fn_info_game_kf2
elif [ "${shortname}" == "lo" ]; then
	fn_info_game_lo
elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ]; then
	fn_info_game_mc
elif [ "${shortname}" == "mcb" ]; then
	fn_info_game_mcb
elif [ "${shortname}" == "mh" ]; then
	fn_info_game_mh
elif [ "${shortname}" == "mohaa" ]; then
	fn_info_game_mohaa
elif [ "${shortname}" == "mom" ]; then
	fn_info_game_mom
elif [ "${shortname}" == "mta" ]; then
	fn_info_game_mta
elif [ "${shortname}" == "mumble" ]; then
	fn_info_game_mumble
elif [ "${shortname}" == "nec" ]; then
	fn_info_game_nec
elif [ "${shortname}" == "onset" ]; then
	fn_info_game_onset
elif [ "${shortname}" == "pc" ]; then
	fn_info_game_pc
elif [ "${shortname}" == "pc2" ]; then
	fn_info_game_pc2
elif [ "${shortname}" == "pstbs" ]; then
	fn_info_game_pstbs
elif [ "${shortname}" == "pvr" ]; then
	fn_info_game_pvr
elif [ "${shortname}" == "pz" ]; then
	fn_info_game_pz
elif [ "${shortname}" == "q2" ]; then
	fn_info_game_q2
elif [ "${shortname}" == "q3" ]; then
	fn_info_game_q3
elif [ "${shortname}" == "ql" ]; then
	fn_info_game_ql
elif [ "${shortname}" == "qw" ]; then
	fn_info_game_qw
elif [ "${shortname}" == "ro" ]; then
	fn_info_game_ro
elif [ "${shortname}" == "rtcw" ]; then
	fn_info_game_rtcw
elif [ "${shortname}" == "rust" ]; then
	fn_info_game_rust
elif [ "${shortname}" == "rw" ]; then
	fn_info_game_rw
elif [ "${shortname}" == "samp" ]; then
	fn_info_game_samp
elif [ "${shortname}" == "sb" ]; then
	fn_info_game_sb
elif [ "${shortname}" == "sbots" ]; then
	fn_info_game_sbots
elif [ "${shortname}" == "scpsl" ] || [ "${shortname}" == "scpslsm" ]; then
	fn_info_game_scpsl
elif [ "${shortname}" == "sdtd" ]; then
	fn_info_game_sdtd
elif [ "${shortname}" == "sf" ]; then
	fn_info_game_sf
elif [ "${shortname}" == "sof2" ]; then
	fn_info_game_sof2
elif [ "${shortname}" == "sol" ]; then
	fn_info_game_sol
elif [ "${engine}" == "spark" ]; then
	fn_info_game_spark
elif [ "${shortname}" == "squad" ]; then
	fn_info_game_squad
elif [ "${shortname}" == "st" ]; then
	fn_info_game_st
elif [ "${shortname}" == "stn" ]; then
	fn_info_game_stn
elif [ "${shortname}" == "terraria" ]; then
	fn_info_game_terraria
elif [ "${shortname}" == "ti" ]; then
	fn_info_game_ti
elif [ "${shortname}" == "ts3" ]; then
	fn_info_game_ts3
elif [ "${shortname}" == "tu" ]; then
	fn_info_game_tu
elif [ "${shortname}" == "tw" ]; then
	fn_info_game_tw
elif [ "${shortname}" == "unt" ]; then
	fn_info_game_unt
elif [ "${shortname}" == "ut" ]; then
	fn_info_game_ut
elif [ "${shortname}" == "ut2k4" ]; then
	fn_info_game_unreal2k4
elif [ "${shortname}" == "ut3" ]; then
	fn_info_game_ut3
elif [ "${shortname}" == "ut99" ]; then
	fn_info_game_ut99
elif [ "${shortname}" == "vh" ]; then
	fn_info_game_vh
elif [ "${shortname}" == "vints" ]; then
	fn_info_game_vints
elif [ "${shortname}" == "vpmc" ]; then
	fn_info_game_vpmc
elif [ "${shortname}" == "wet" ]; then
	fn_info_game_wet
elif [ "${shortname}" == "wf" ]; then
	fn_info_game_wf
elif [ "${shortname}" == "wmc" ]; then
	fn_info_game_wmc
elif [ "${shortname}" == "wurm" ]; then
	fn_info_game_wurm
elif [ "${engine}" == "source" ] || [ "${engine}" == "goldsrc" ]; then
	fn_info_game_source
elif [ "${engine}" == "unreal2" ]; then
	fn_info_game_unreal2
fi

# External IP address
if [ -z "${extip}" ]; then
	extip="$(curl --connect-timeout 10 -s https://api.ipify.org 2> /dev/null)"
	exitcode=$?
	# Should ifconfig.co return an error will use last known IP.
	if [ ${exitcode} -eq 0 ]; then
		if [[ "${extip}" != *"DOCTYPE"* ]]; then
			echo -e "${extip}" > "${tmpdir}/extip.txt"
		else
			if [ -f "${tmpdir}/extip.txt" ]; then
				extip="$(cat "${tmpdir}/extip.txt")"
			else
				fn_print_error_nl "Unable to get external IP"
			fi
		fi
	else
		if [ -f "${tmpdir}/extip.txt" ]; then
			extip="$(cat "${tmpdir}/extip.txt")"
		else
			fn_print_error_nl "Unable to get external IP"
		fi
	fi
fi

# Alert IP address
if [ "${displayip}" ]; then
	alertip="${displayip}"
elif [ "${extip}" ]; then
	alertip="${extip}"
else
	alertip="${ip}"
fi

# Steam Master Server - checks if detected by master server.
# Checked after config init, as the queryport is needed
if [ -z "${displaymasterserver}" ]; then
	if [ "$(command -v jq 2> /dev/null)" ]; then
		if [ "${ip}" ] && [ "${port}" ]; then
			if [ "${steammaster}" == "true" ] || [ "${commandname}" == "DEV-QUERY-RAW" ]; then
				# Will query server IP addresses first.
				for queryip in "${queryips[@]}"; do
					masterserver="$(curl --connect-timeout 10 -m 3 -s "https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=${queryip}&format=json" | jq --arg port "${port}" --arg queryport "${queryport}" '.response.servers[] | select((.gameport == ($port|tonumber) or (.gameport == ($queryport|tonumber)))) | .addr' | wc -l 2> /dev/null)"
				done
				# Should that not work it will try the external IP.
				if [ "${masterserver}" == "0" ]; then
					masterserver="$(curl --connect-timeout 10 -m 3 -s "https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=${extip}&format=json" | jq --arg port "${port}" --arg queryport "${queryport}" '.response.servers[] | select((.gameport == ($port|tonumber) or (.gameport == ($queryport|tonumber)))) | .addr' | wc -l 2> /dev/null)"
				fi
				if [ "${masterserver}" == "0" ]; then
					displaymasterserver="false"
				else
					displaymasterserver="true"
				fi
			fi
		fi
	fi
fi
