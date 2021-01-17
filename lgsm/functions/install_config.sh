#!/bin/bash
# LinuxGSM install_config.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates default server configs.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Checks if server cfg dir exists, creates it if it doesn't.
fn_check_cfgdir(){
	if [ ! -d "${servercfgdir}" ]; then
		echo -e "creating ${servercfgdir} config directory."
		fn_script_log_info "creating ${servercfgdir} config directory."
		mkdir -pv "${servercfgdir}"
	fi
}

# Downloads default configs from Game-Server-Configs repo to lgsm/config-default.
fn_fetch_default_config(){
	echo -e ""
	echo -e "${lightyellow}Downloading ${gamename} Configs${default}"
	echo -e "================================="
	echo -e "default configs from https://github.com/GameServerManagers/Game-Server-Configs"
	fn_sleep_time
	mkdir -p "${lgsmdir}/config-default/config-game"
	githuburl="https://raw.githubusercontent.com/GameServerManagers/Game-Server-Configs/master"
	for config in "${array_configs[@]}"; do
		fn_fetch_file "${githuburl}/${gamedirname}/${config}" "${remote_fileurl_backup}" "GitHub" "Bitbucket" "${lgsmdir}/config-default/config-game" "${config}" "nochmodx" "norun" "forcedl" "nomd5"
	done
}

# Copys default configs from Game-Server-Configs repo to server config location.
fn_default_config_remote(){
	for config in "${array_configs[@]}"; do
		# every config is copied
		echo -e "copying ${config} config file."
		fn_script_log_info "copying ${servercfg} config file."
		if [ "${config}" == "${servercfgdefault}" ]; then
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${servercfgfullpath}"
		elif [ "${shortname}" == "arma3" ]&&[ "${config}" == "${networkcfgdefault}" ]; then
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${networkcfgfullpath}"
		elif [ "${shortname}" == "dst" ]&&[ "${config}" == "${clustercfgdefault}" ]; then
			cp -nv "${lgsmdir}/config-default/config-game/${clustercfgdefault}" "${clustercfgfullpath}"
		else
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${servercfgdir}/${config}"
		fi
	done
	fn_sleep_time
}

# Copys local default config to server config location.
fn_default_config_local(){
	echo -e "copying ${servercfgdefault} config file."
	cp -nv "${servercfgdir}/${servercfgdefault}" "${servercfgfullpath}"
	fn_sleep_time
}

# Changes some variables within the default configs.
# SERVERNAME to LinuxGSM
# PASSWORD to random password
fn_set_config_vars(){
	if [ -f "${servercfgfullpath}" ]; then
		random=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 8 | xargs)
		servername="LinuxGSM"
		rconpass="admin${random}"
		echo -e "changing hostname."
		fn_script_log_info "changing hostname."
		fn_sleep_time
		# prevents var from being overwritten with the servername.
		if grep -q "SERVERNAME=SERVERNAME" "${lgsmdir}/config-default/config-game/${config}" 2>/dev/null; then
			sed -i "s/SERVERNAME=SERVERNAME/SERVERNAME=${servername}/g" "${servercfgfullpath}"
		elif grep -q "SERVERNAME=\"SERVERNAME\"" "${lgsmdir}/config-default/config-game/${config}" 2>/dev/null; then
			sed -i "s/SERVERNAME=\"SERVERNAME\"/SERVERNAME=\"${servername}\"/g" "${servercfgfullpath}"
		else
			sed -i "s/SERVERNAME/${servername}/g" "${servercfgfullpath}"
		fi
		echo -e "changing rcon/admin password."
		fn_script_log_info "changing rcon/admin password."
		if [ "${shortname}" == "squad" ]; then
			sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgdir}/Rcon.cfg"
		else
			sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgfullpath}"
		fi
		fn_sleep_time
	else
		fn_script_log_warn "Config file not found, cannot alter it."
		echo -e "Config file not found, cannot alter it."
		fn_sleep_time
	fi
}

# Changes some variables within the default Don't Starve Together configs.
fn_set_dst_config_vars(){
	## cluster.ini
	if grep -Fq "SERVERNAME" "${clustercfgfullpath}"; then
		echo -e "changing server name."
		fn_script_log_info "changing server name."
		sed -i "s/SERVERNAME/LinuxGSM/g" "${clustercfgfullpath}"
		fn_sleep_time
		echo -e "changing shard mode."
		fn_script_log_info "changing shard mode."
		sed -i "s/USESHARDING/${sharding}/g" "${clustercfgfullpath}"
		fn_sleep_time
		echo -e "randomizing cluster key."
		fn_script_log_info "randomizing cluster key."
		randomkey=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 8 | xargs)
		sed -i "s/CLUSTERKEY/${randomkey}/g" "${clustercfgfullpath}"
		fn_sleep_time
	else
		echo -e "${clustercfg} is already configured."
		fn_script_log_info "${clustercfg} is already configured."
	fi

	## server.ini
	# removing unnecessary options (dependent on sharding & shard type).
	if [ "${sharding}" == "false" ]; then
		sed -i "s/ISMASTER//g" "${servercfgfullpath}"
		sed -i "/SHARDNAME/d" "${servercfgfullpath}"
	elif [ "${master}" == "true" ]; then
		sed -i "/SHARDNAME/d" "${servercfgfullpath}"
	fi

	echo -e "changing shard name."
	fn_script_log_info "changing shard name."
	sed -i "s/SHARDNAME/${shard}/g" "${servercfgfullpath}"
	fn_sleep_time
	echo -e "changing master setting."
	fn_script_log_info "changing master setting."
	sed -i "s/ISMASTER/${master}/g" "${servercfgfullpath}"
	fn_sleep_time

	## worldgenoverride.lua
	if [ "${cave}" == "true" ]; then
		echo -e "defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		fn_script_log_info "defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		echo 'return { override_enabled = true, preset = "DST_CAVE", }' > "${servercfgdir}/worldgenoverride.lua"
	fi
	fn_sleep_time
	echo -e ""
}

# Lists local config file locations
fn_list_config_locations(){
	echo -e ""
	echo -e "${lightyellow}Config File Locations${default}"
	echo -e "================================="
	if [ -n "${servercfgfullpath}" ]; then
		if [ -f "${servercfgfullpath}" ]; then
			echo -e "Game Server Config File: ${servercfgfullpath}"
		elif [ -d "${servercfgfullpath}" ]; then
			echo -e "Game Server Config Dir: ${servercfgfullpath}"
		else
			echo -e "Config file: ${red}${servercfgfullpath} (${red}FILE MISSING${default})"
		fi
	fi
	echo -e "LinuxGSM Config: ${lgsmdir}/config-lgsm/${gameservername}"
	echo -e "Documentation: https://docs.linuxgsm.com/configuration/game-server-config"
	echo -e ""
}

if [ "${shortname}" == "sdtd" ]; then
	gamedirname="7DaysToDie"
	fn_default_config_local
	fn_list_config_locations
elif [ "${shortname}" == "ac" ]; then
	gamedirname="AssettoCorsa"
	array_configs+=( server_cfg.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ahl" ]; then
	gamedirname="ActionHalfLife"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ahl2" ]; then
	gamedirname="ActionSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ark" ]; then
	gamedirname="ARKSurvivalEvolved"
	fn_check_cfgdir
	array_configs+=( GameUserSettings.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "arma3" ]; then
	gamedirname="Arma3"
	fn_check_cfgdir
	array_configs+=( server.cfg network.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bo" ]; then
	gamedirname="BallisticOverkill"
	array_configs+=( config.txt )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bo" ]; then
	gamedirname="BaseDefense"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bt" ]; then
	gamedirname="Barotrauma"
	fn_check_cfgdir
	array_configs+=( serversettings.xml )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bt1944" ]; then
	gamedirname="Battalion1944"
	fn_check_cfgdir
	array_configs+=( DefaultGame.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bf1942" ]; then
	gamedirname="Battlefield1942"
	array_configs+=( serversettings.con )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bfv" ]; then
	gamedirname="BattlefieldVietnam"
	array_configs+=( serversettings.con )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bs" ]; then
	gamedirname="BladeSymphony"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bb" ]; then
	gamedirname="BrainBread"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bb2" ]; then
	gamedirname="BrainBread2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bmdm" ]; then
	gamedirname="BlackMesa"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod" ]; then
	gamedirname="CallOfDuty"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "coduo" ]; then
	gamedirname="CallOfDutyUnitedOffensive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod2" ]; then
	gamedirname="CallOfDuty2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod4" ]; then
	gamedirname="CallOfDuty4"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "codwaw" ]; then
	gamedirname="CallOfDutyWorldAtWar"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cc" ]; then
	gamedirname="CodenameCURE"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "col" ]; then
	gamedirname="ColonySurvival"
	array_configs+=( colserver.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cs" ]; then
	gamedirname="CounterStrike"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cscz" ]; then
	gamedirname="CounterStrikeConditionZero"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "csgo" ]; then
	gamedirname="CounterStrikeGlobalOffensive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "css" ]; then
	gamedirname="CounterStrikeSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dod" ]; then
	gamedirname="DayOfDefeat"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dods" ]; then
	gamedirname="DayOfDefeatSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "doi" ]; then
	gamedirname="DayOfInfamy"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dmc" ]; then
	gamedirname="DeathmatchClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dst" ]; then
	gamedirname="DontStarveTogether"
	fn_check_cfgdir
	array_configs+=( cluster.ini server.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_dst_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dab" ]; then
	gamedirname="DoubleActionBoogaloo"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dys" ]; then
	gamedirname="Dystopia"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "eco" ]; then
	gamedirname="Eco"
	array_configs+=( Network.eco )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "etl" ]; then
	gamedirname="ETLegacy"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "fctr" ]; then
	gamedirname="Factorio"
	array_configs+=( server-settings.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "fof" ]; then
	gamedirname="FistfulofFrags"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "gmod" ]; then
	gamedirname="GarrysMod"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hldm" ]; then
	gamedirname="HalfLifeDeathmatch"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hldms" ]; then
	gamedirname="HalfLifeDeathmatchSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "opfor" ]; then
	gamedirname="OpposingForce"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hl2dm" ]; then
	gamedirname="HalfLife2Deathmatch"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ins" ]; then
	gamedirname="Insurgency"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ios" ]; then
	gamedirname="IOSoccer"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jc2" ]; then
	gamedirname="JustCause2"
	array_configs+=( config.lua )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jc3" ]; then
	gamedirname="JustCause3"
	array_configs+=( config.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "kf" ]; then
	gamedirname="KillingFloor"
	array_configs+=( Default.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "l4d" ]; then
	gamedirname="Left4Dead"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "l4d2" ]; then
	gamedirname="Left4Dead2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mc" ]; then
	gamedirname="Minecraft"
	array_configs+=( server.properties )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mcb" ]; then
	gamedirname="MinecraftBedrock"
	array_configs+=( server.properties )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mohaa" ]; then
	gamedirname="MedalOfHonorAlliedAssault"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mh" ]; then
	gamedirname="Mordhau"
	fn_check_cfgdir
	array_configs+=( Game.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ns" ]; then
	gamedirname="NaturalSelection"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nmrih" ]; then
	gamedirname="NoMoreRoominHell"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nd" ]; then
	gamedirname="NuclearDawn"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mta" ]; then
	gamedirname="MultiTheftAuto"
	fn_check_cfgdir
	array_configs+=( acl.xml mtaserver.conf vehiclecolors.conf )
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shotname}" == "mom" ];then
	gamedirname="MemoriesofMars"
	array_configs+=( DedicatedServerConfig.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mumble" ]; then
	gamedirname="Mumble"
	array_configs+=( murmur.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "pvr" ]; then
	gamedirname="PavlovVR"
	fn_check_cfgdir
	array_configs+=( Game.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "pvkii" ]; then
	gamedirname="PiratesVikingandKnightsII"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pz" ]; then
	gamedirname="ProjectZomboid"
	fn_check_cfgdir
	array_configs+=( server.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pc" ]; then
	gamedirname="ProjectCars"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "q2" ]; then
	gamedirname="Quake2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "q3" ]; then
	gamedirname="Quake3Arena"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ql" ]; then
	gamedirname="QuakeLive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jk2" ]; then
	gamedirname="JediKnightIIJediOutcast"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "qw" ]; then
	gamedirname="QuakeWorld"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ricochet" ]; then
	gamedirname="Ricochet"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "rtcw" ]; then
	gamedirname="ReturnToCastleWolfenstein"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "rust" ]; then
	gamedirname="Rust"
	fn_check_cfgdir
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "scpsl" ]||[ "${shortname}" == "scpslsm" ]; then
	gamedirname="SCPSecretLaboratory"
	array_configs+=( config_gameplay.txt config_localadmin.txt )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sol" ]; then
	gamedirname="Soldat"
	array_configs+=( soldat.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sof2" ]; then
	gamedirname="SoldierOfFortune2Gold"
	array_configs+=( server.cfg mapcycle.txt)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sfc" ]; then
	gamedirname="SourceFortsClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "squad" ]; then
	gamedirname="Squad"
	array_configs+=( Admins.cfg Bans.cfg License.cfg Server.cfg Rcon.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sb" ]; then
	gamedirname="Starbound"
	array_configs+=( starbound_server.config )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "st" ]; then
	gamedirname="Stationeers"
	array_configs+=( default.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sven" ]; then
	gamedirname="SvenCoop"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tf2" ]; then
	gamedirname="TeamFortress2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tfc" ]; then
	gamedirname="TeamFortressClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ts" ]; then
	gamedirname="TheSpecialists"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ts3" ]; then
	gamedirname="TeamSpeak3"
	array_configs+=( ts3server.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "tw" ]; then
	gamedirname="Teeworlds"
	array_configs+=( server.cfg ctf.cfg dm.cfg duel.cfg tdm.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "terraria" ]; then
	gamedirname="Terraria"
	array_configs+=( serverconfig.txt )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tu" ]; then
	gamedirname="TowerUnite"
	fn_check_cfgdir
	array_configs+=( TowerServer.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut" ]; then
	gamedirname="UnrealTournament"
	array_configs+=( Game.ini Engine.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut2k4" ]; then
	gamedirname="UnrealTournament2004"
	array_configs+=( UT2004.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut99" ]; then
	gamedirname="UnrealTournament99"
	array_configs+=( Default.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "unt" ]; then
	gamedirname="Unturned"
	array_configs+=( Config.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "vints" ]; then
	gamedirname="VintageStory"
	array_configs+=( serverconfig.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "vs" ]; then
	gamedirname="VampireSlayer"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wet" ]; then
	gamedirname="WolfensteinEnemyTerritory"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wf" ]; then
	gamedirname="Warfork"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wurm" ]; then
	gamedirname="WurmUnlimited"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "zmr" ]; then
	gamedirname="ZombieMasterReborn"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "zps" ]; then
	gamedirname="ZombiePanicSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
fi
