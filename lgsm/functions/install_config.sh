#!/bin/bash
# LGSM install_config.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates default server configs.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_fetch_default_config(){
	mkdir -pv "${lgsmdir}/default-configs"
	githuburl="https://github.com/GameServerManagers/Game-Server-Configs/master"

	for config in "${array_configs[@]}"
	do
		fileurl="https://raw.githubusercontent.com/GameServerManagers/Game-Server-Configs/master/${gamedirname}/${config}"; filedir="${lgsmdir}/default-configs"; filename="${config}";  executecmd="noexecute" run="norun"; force="noforce"
		fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
	done
}

# Changes some variables within the default configs
# SERVERNAME to LinuxGSM
# PASSWORD to random password
fn_set_config_vars(){
	random=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 8 | tr -d '\n'; echo)
	servername="LinuxGSM"
	rconpass="admin$random"
	echo "changing hostname."
	fn_script_log_info "changing hostname."
	sleep 1
	sed -i "s/SERVERNAME/${servername}/g" "${servercfgfullpath}"
	echo "changing rcon/admin password."
	fn_script_log_info "changing rcon/admin password."
	sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgfullpath}"
	sleep 1
}

# Checks if cfg dir exists, creates it if it doesn't
fn_check_cfgdir(){
	if [ ! -d "${servercfgdir}" ]; then
		echo "creating ${servercfgdir} config directory."
		fn_script_log_info "creating ${servercfgdir} config directory."
		mkdir -pv "${servercfgdir}"
	fi
}

# Copys the default configs from Game-Server-Configs repo to the
# correct location
fn_default_config_remote(){
	for config in "${array_configs[@]}"
	do
		# every config is copied
		echo "copying ${config} config file."
		fn_script_log_info "copying ${servercfg} config file."
		if [ "${config}" == "${servercfgdefault}" ]; then
			cp -v "${lgsmdir}/default-configs/${config}" "${servercfgfullpath}"
		elif [ "${gamename}" == "ARMA 3" ]&&[ "${config}" == "${networkcfgdefault}" ]; then
			cp -v "${lgsmdir}/default-configs/${config}" "${networkcfgfullpath}"
		elif [ "${gamename}" == "Don't Starve Together" ]&&[ "${config}" == "${clustercfgdefault}" ]; then
			cp -nv "${lgsmdir}/default-configs/${clustercfgdefault}" "${clustercfgfullpath}"
		else
			cp -v "${lgsmdir}/default-configs/${config}" "${servercfgdir}/${config}"
		fi
	done
	sleep 1
}

# Changes some variables within the default Don't Starve Together configs
fn_set_dst_config_vars(){
	## cluster.ini
	if grep -Fq "SERVERNAME" "${clustercfgfullpath}"; then
		echo "changing server name."
		fn_script_log_info "changing server name."
		sed -i "s/SERVERNAME/LinuxGSM/g" "${clustercfgfullpath}"
		sleep 1
		echo "changing shard mode."
		fn_script_log_info "changing shard mode."
		sed -i "s/USESHARDING/${sharding}/g" "${clustercfgfullpath}"
		sleep 1
		echo "randomizing cluster key."
		fn_script_log_info "randomizing cluster key."
		randomkey=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
		sed -i "s/CLUSTERKEY/${randomkey}/g" "${clustercfgfullpath}"
		sleep 1
	else	
		echo "${clustercfg} is already configured."
		fn_script_log_info "${clustercfg} is already configured."
	fi
	
	## server.ini
	# removing unnecessary options (dependent on sharding & shard type)
	if [ "${sharding}" == "false" ]; then 
		sed -i "s/ISMASTER//g" "${servercfgfullpath}"
		sed -i "/SHARDNAME/d" "${servercfgfullpath}"
	elif [ "${master}" == "true" ]; then
		sed -i "/SHARDNAME/d" "${servercfgfullpath}"
	fi
	
	echo "changing shard name."
	fn_script_log_info "changing shard name."
	sed -i "s/SHARDNAME/${shard}/g" "${servercfgfullpath}"
	sleep 1
	echo "changing master setting."
	fn_script_log_info "changing master setting."
	sed -i "s/ISMASTER/${master}/g" "${servercfgfullpath}"
	sleep 1
	
	## worldgenoverride.lua
	if [ "${cave}" == "true" ]; then
		echo "defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		fn_script_log_info "defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		echo 'return { override_enabled = true, preset = "DST_CAVE", }' > "${servercfgdir}/worldgenoverride.lua"
	fi
	sleep 1
	echo ""
}

echo ""
echo "Downloading ${gamename} Config"
echo "================================="
echo "default configs from https://github.com/GameServerManagers/Game-Server-Configs"
sleep 2
if [ "${gamename}" == "7 Days To Die" ]; then
	gamedirname="7DaysToDie"
	array_configs+=( serverconfig.xml )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "ARK: Survivial Evolved" ]; then
	gamedirname="ARKSurvivalEvolved"
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
	gamedirname="CallofDuty2"
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
elif [ "${gamename}" == "Just Cause 2" ]; then
	gamedirname="JustCause2"
	array_configs+=( config.lua )
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
elif [ "${gamename}" == "No More Room in Hell" ]; then
	gamedirname="NoMoreRoominHell"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Mumble" ]; then
	gamedirname="Mumble"
	array_configs+=( murmur.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Natural Selection 2" ]; then
	:
elif [ "${gamename}" == "NS2: Combat" ]; then
	:
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
elif [ "${gamename}" == "Red Orchestra: Ostfront 41-45" ]; then
	:
elif [ "${gamename}" == "Ricochet" ]; then
	gamedirname="Ricochet"
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
elif [ "${gamename}" == "Serious Sam 3: BFE" ]; then
	gamedirname="SeriousSam3BFE"
	array_configs+=( server.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Starbound" ]; then
	gamedirname="Starbound"
	array_configs+=( starbound_server.config )
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
elif [ "${gamename}" == "Unreal Tournament 3" ]; then
	gamedirname="UnrealTournament3"
	array_configs+=( UTGame.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Unreal Tournament 99" ]; then
	gamedirname="UnrealTournament99"
	array_configs+=( Default.ini )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${gamename}" == "Wolfenstein: Enemy Territory" ]; then
	gamedirname="WolfensteinEnemyTerritory"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
fi