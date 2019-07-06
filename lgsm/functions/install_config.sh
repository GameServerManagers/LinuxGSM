#!/bin/bash
# LinuxGSM install_config.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Creates default server configs.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Checks if server cfg dir exists, creates it if it doesn't.
fn_check_cfgdir(){
	if [ ! -d "${servercfgdir}" ]; then
		echo "creating ${servercfgdir} config directory."
		fn_script_log_info "creating ${servercfgdir} config directory."
		mkdir -pv "${servercfgdir}"
	fi
}

# Downloads default configs from Game-Server-Configs repo to lgsm/config-default.
fn_fetch_default_config(){
	echo ""
	echo "Downloading ${gamename} Configs"
	echo "================================="
	echo "default configs from https://github.com/GameServerManagers/Game-Server-Configs"
	fn_sleep_time
	mkdir -p "${lgsmdir}/config-default/config-game"
	githuburl="https://raw.githubusercontent.com/GameServerManagers/Game-Server-Configs/master"
	for config in "${array_configs[@]}"; do
		fn_fetch_file "${githuburl}/${gamedirname}/${config}" "${lgsmdir}/config-default/config-game" "${config}" "nochmodx" "norun" "forcedl" "nomd5"
	done
}

# Copys default configs from Game-Server-Configs repo to server config location.
fn_default_config_remote(){
	for config in "${array_configs[@]}"; do
		# every config is copied
		echo "copying ${config} config file."
		fn_script_log_info "copying ${servercfg} config file."
		if [ "${config}" == "${servercfgdefault}" ]; then
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${servercfgfullpath}"
		elif [ "${gamename}" == "ARMA 3" ]&&[ "${config}" == "${networkcfgdefault}" ]; then
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${networkcfgfullpath}"
		elif [ "${gamename}" == "Don't Starve Together" ]&&[ "${config}" == "${clustercfgdefault}" ]; then
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
	echo "copying ${servercfgdefault} config file."
	cp -nv "${servercfgfullpathdefault}" "${servercfgfullpath}"
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
		echo "changing hostname."
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
		echo "changing rcon/admin password."
		fn_script_log_info "changing rcon/admin password."
		if [ "${shortname}" == "squad" ]; then
			sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgdir}/Rcon.cfg"
		else
			sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgfullpath}"
		fi
		fn_sleep_time
	else
		fn_script_log_warn "Config file not found, cannot alter it."
		echo "Config file not found, cannot alter it."
		fn_sleep_time
	fi
}

# Changes some variables within the default Don't Starve Together configs.
fn_set_dst_config_vars(){
	## cluster.ini
	if grep -Fq "SERVERNAME" "${clustercfgfullpath}"; then
		echo "changing server name."
		fn_script_log_info "changing server name."
		sed -i "s/SERVERNAME/LinuxGSM/g" "${clustercfgfullpath}"
		fn_sleep_time
		echo "changing shard mode."
		fn_script_log_info "changing shard mode."
		sed -i "s/USESHARDING/${sharding}/g" "${clustercfgfullpath}"
		fn_sleep_time
		echo "randomizing cluster key."
		fn_script_log_info "randomizing cluster key."
		randomkey=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 8 | xargs)
		sed -i "s/CLUSTERKEY/${randomkey}/g" "${clustercfgfullpath}"
		fn_sleep_time
	else
		echo "${clustercfg} is already configured."
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

	echo "changing shard name."
	fn_script_log_info "changing shard name."
	sed -i "s/SHARDNAME/${shard}/g" "${servercfgfullpath}"
	fn_sleep_time
	echo "changing master setting."
	fn_script_log_info "changing master setting."
	sed -i "s/ISMASTER/${master}/g" "${servercfgfullpath}"
	fn_sleep_time

	## worldgenoverride.lua
	if [ "${cave}" == "true" ]; then
		echo "defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		fn_script_log_info "defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		echo 'return { override_enabled = true, preset = "DST_CAVE", }' > "${servercfgdir}/worldgenoverride.lua"
	fi
	fn_sleep_time
	echo ""
}

if [ "${gamename}" == "7 Days To Die" ]; then
	gamedirname="7DaysToDie"
	fn_default_config_local
elif [ "${gamename}" == "ARK: Survival Evolved" ]; then
	gamedirname="ARKSurvivalEvolved"
	fn_check_cfgdir
	array_configs+=( GameUserSettings.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "ARMA 3" ]; then
	gamedirname="Arma3"
	fn_check_cfgdir
	array_configs+=( server.cfg network.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Ballistic Overkill" ]; then
	gamedirname="BallisticOverkill"
	array_configs+=( config.txt )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Base Defense" ]; then
	gamedirname="BaseDefense"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Barotrauma" ]; then
	gamedirname="Barotrauma"
	fn_check_cfgdir
	array_configs+=( serversettings.xml )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Battalion 1944" ]; then
	gamedirname="Battalion1944"
	fn_check_cfgdir
	array_configs+=( DefaultGame.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Battlefield: 1942" ]; then
	gamedirname="Battlefield1942"
	array_configs+=( serversettings.con )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Blade Symphony" ]; then
	gamedirname="BladeSymphony"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "BrainBread" ]; then
	gamedirname="BrainBread"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "BrainBread 2" ]; then
	gamedirname="BrainBread2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Black Mesa: Deathmatch" ]; then
	gamedirname="BlackMesa"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Call of Duty" ]; then
	gamedirname="CallOfDuty"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Call of Duty: United Offensive" ]; then
	gamedirname="CallOfDutyUnitedOffensive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Call of Duty 2" ]; then
	gamedirname="CallOfDuty2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Call of Duty 4" ]; then
	gamedirname="CallOfDuty4"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Call of Duty: World at War" ]; then
	gamedirname="CallOfDutyWorldAtWar"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Codename CURE" ]; then
	gamedirname="CodenameCURE"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Counter-Strike 1.6" ]; then
	gamedirname="CounterStrike"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Counter-Strike: Condition Zero" ]; then
	gamedirname="CounterStrikeConditionZero"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Counter-Strike: Global Offensive" ]; then
	gamedirname="CounterStrikeGlobalOffensive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Classic Offensive" ]; then
	gamedirname="ClassicOffensive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Counter-Strike: Source" ]; then
	gamedirname="CounterStrikeSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Day of Defeat" ]; then
	gamedirname="DayOfDefeat"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Day of Defeat: Source" ]; then
	gamedirname="DayOfDefeatSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Day of Infamy" ]; then
	gamedirname="DayOfInfamy"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Deathmatch Classic" ]; then
	gamedirname="DeathmatchClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Don't Starve Together" ]; then
	gamedirname="DontStarveTogether"
	fn_check_cfgdir
	array_configs+=( cluster.ini server.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_dst_config_vars
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	gamedirname="DoubleActionBoogaloo"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Dystopia" ]; then
	gamedirname="Dystopia"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Eco" ]; then
	gamedirname="Eco"
	array_configs+=( Network.eco )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "ET: Legacy" ]; then
	gamedirname="ETLegacy"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Factorio" ]; then
	gamedirname="Factorio"
	array_configs+=( server-settings.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Fistful of Frags" ]; then
	gamedirname="FistfulofFrags"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Garry's Mod" ]; then
	gamedirname="GarrysMod"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "GoldenEye: Source" ]; then
	gamedirname="GoldenEyeSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Half Life: Deathmatch" ]; then
	gamedirname="HalfLifeDeathmatch"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Half-Life Deathmatch: Source" ]; then
	gamedirname="HalfLifeDeathmatchSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Half-Life: Opposing Force" ]; then
	gamedirname="OpposingForce"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Half Life 2: Deathmatch" ]; then
	gamedirname="HalfLife2Deathmatch"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Insurgency" ]; then
	gamedirname="Insurgency"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "IOSoccer" ]; then
	gamedirname="IOSoccer"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Just Cause 2" ]; then
	gamedirname="JustCause2"
	array_configs+=( config.lua )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Just Cause 3" ]; then
	gamedirname="JustCause3"
	array_configs+=( config.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Killing Floor" ]; then
	gamedirname="KillingFloor"
	array_configs+=( Default.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Left 4 Dead" ]; then
	gamedirname="Left4Dead"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Left 4 Dead" ]; then
	gamedirname="Left4Dead"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Left 4 Dead 2" ]; then
	gamedirname="Left4Dead2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Minecraft" ]; then
	gamedirname="Minecraft"
	array_configs+=( server.properties )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "MORDHAU" ]; then
	gamedirname="Mordhau"
	fn_check_cfgdir
	array_configs+=( Game.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Natural Selection" ]; then
	gamedirname="NaturalSelection"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "No More Room in Hell" ]; then
	gamedirname="NoMoreRoominHell"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Nuclear Dawn" ]; then
	gamedirname="NuclearDawn"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Multi Theft Auto" ]; then
	gamedirname="MultiTheftAuto"
	fn_check_cfgdir
	array_configs+=( acl.xml mtaserver.conf vehiclecolors.conf )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Mumble" ]; then
	gamedirname="Mumble"
	array_configs+=( murmur.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Pirates, Vikings, and Knights II" ]; then
	gamedirname="PiratesVikingandKnightsII"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Project Zomboid" ]; then
	gamedirname="ProjectZomboid"
	fn_check_cfgdir
	array_configs+=( server.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Project Cars" ]; then
	gamedirname="ProjectCars"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Quake 2" ]; then
	gamedirname="Quake2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Quake 3: Arena" ]; then
	gamedirname="Quake3Arena"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Quake Live" ]; then
	gamedirname="QuakeLive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "QuakeWorld" ]; then
	gamedirname="QuakeWorld"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Ricochet" ]; then
	gamedirname="Ricochet"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Return to Castle Wolfenstein" ]; then
	gamedirname="ReturnToCastleWolfenstein"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Rust" ]; then
	gamedirname="Rust"
	fn_check_cfgdir
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "San Andreas Multiplayer" ]; then
	gamedirname="SanAndreasMultiplayer"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Serious Sam 3: BFE" ]; then
	gamedirname="SeriousSam3BFE"
	array_configs+=( server.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Soldier Of Fortune 2: Gold Edition" ]; then
	gamedirname="SoldierOfFortune2Gold"
	array_configs+=( server.cfg mapcycle.txt)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "SourceForts Classic" ]; then
	gamedirname="SourceFortsClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Squad" ]; then
	gamedirname="Squad"
	array_configs+=( Admins.cfg Bans.cfg License.cfg Server.cfg Rcon.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Starbound" ]; then
	gamedirname="Starbound"
	array_configs+=( starbound_server.config )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Stationeers" ]; then
	gamedirname="Stationeers"
	array_configs+=( default.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Sven Co-op" ]; then
	gamedirname="SvenCoop"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Team Fortress 2" ]; then
	gamedirname="TeamFortress2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Team Fortress Classic" ]; then
	gamedirname="TeamFortressClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "The Specialists" ]; then
	gamedirname="TheSpecialists"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	gamedirname="TeamSpeak3"
	array_configs+=( ts3server.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Teeworlds" ]; then
	gamedirname="Teeworlds"
	array_configs+=( server.cfg ctf.cfg dm.cfg duel.cfg tdm.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Terraria" ]; then
	gamedirname="Terraria"
	array_configs+=( serverconfig.txt )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Tower Unite" ]; then
	gamedirname="TowerUnite"
	fn_check_cfgdir
	array_configs+=( TowerServer.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Unreal Tournament" ]; then
	gamedirname="UnrealTournament"
	array_configs+=( Game.ini Engine.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
	gamedirname="UnrealTournament2004"
	array_configs+=( UT2004.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Unreal Tournament 99" ]; then
	gamedirname="UnrealTournament99"
	array_configs+=( Default.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "unt" ]; then
	gamedirname="Unturned"
	array_configs+=( Config.json )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Vampire Slayer" ]; then
	gamedirname="VampireSlayer"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Wolfenstein: Enemy Territory" ]; then
	gamedirname="WolfensteinEnemyTerritory"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Wurm Unlimited" ]; then
	gamedirname="WurmUnlimited"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Zombie Panic! Source" ]; then
	gamedirname="ZombiePanicSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
fi
