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

# allow user to input server name and password
fn_user_input_config(){
	if [ -z "${autoinstall}" ]; then
		echo ""
		echo "Configuring ${gamename} Server"
		echo "================================="
		sleep 1
		read -p "Enter server name: " servername
		read -p "Enter rcon password: " rconpass
	else
		servername="LinuxGSM"
		rconpass="rcon$RANDOM"
	fi
	echo "changing hostname."
	fn_script_log_info "changing hostname."
	sed -i "s/\"<hostname>\"/\"${servername}\"/g" "${servercfgfullpath}"
	sleep 1
	echo "changing rconpassword."
	fn_script_log_info "changing RCON password."
	sed -i "s/\"<rconpassword>\"/\"${rconpass}\"/g" "${servercfgfullpath}"
	sleep 1
}

# Copys the default configs from Game-Server-Configs repo to the
# correct location
fn_default_config_remote(){
	for config in "${array_configs[@]}"
	do
		# every config is copied
		echo "copying ${servercfg} config file."
		fn_script_log_info "copying ${servercfg} config file."
		if [ "${config}" == "${servercfgdefault}" ]; then
			cp -v "${lgsmdir}/default-configs/${config}" "${servercfgfullpath}"
		else
			cp -v "${lgsmdir}/default-configs/${config}" "${servercfgdir}/${config}"
		fi
	done
	sleep 1
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
elif [ "${gamename}" == "ARK: Survivial Evolved" ]; then
	gamedirname="ARKSurvivalEvolved"
	array_configs+=( GameUserSettings.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "ARMA 3" ]; then
	gamedirname="Arma3"
	array_configs+=( server.cfg network.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Blade Symphony" ]; then
	gamedirname="BladeSymphony"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "BrainBread 2" ]; then
	gamedirname="BrainBread2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Black Mesa: Deathmatch" ]; then
	gamedirname="BlackMesa"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Codename CURE" ]; then
	gamedirname="CodenameCURE"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Counter-Strike 1.6" ]; then
	gamedirname="CounterStrike"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Counter-Strike: Condition Zero" ]; then
	gamedirname="CounterStrikeConditionZero"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Counter-Strike: Global Offensive" ]; then
	gamedirname="CounterStrikeGlobalOffensive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Counter-Strike: Source" ]; then
	gamedirname="CounterStrikeSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Day of Defeat" ]; then
	gamedirname="DayOfDefeat"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Day of Defeat: Source" ]; then
	gamedirname="DayOfDefeatSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Day of Infamy" ]; then
	gamedirname="DayOfInfamy"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Deathmatch Classic" ]; then
	gamedirname="DeathmatchClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Don't Starve Together" ]; then
	gamedirname="DontStarveTogether"
	array_configs+=( Settings.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	gamedirname="DoubleActionBoogaloo"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Fistful of Frags" ]; then
	gamedirname="FistfulofFrags"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Garry's Mod" ]; then
	gamedirname="GarrysMod"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "GoldenEye: Source" ]; then
	gamedirname="GoldenEyeSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Half Life: Deathmatch" ]; then
	gamedirname="HalfLifeDeathmatch"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Half-Life Deathmatch: Source" ]; then
	gamedirname="HalfLifeDeathmatchSource"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Half-Life: Opposing Force" ]; then
	gamedirname="OpposingForce"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Half Life 2: Deathmatch" ]; then
	gamedirname="HalfLife2Deathmatch"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Insurgency" ]; then
	gamedirname="Insurgency"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Just Cause 2" ]; then
	gamedirname="JustCause2"
	array_configs+=( config.lua )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Killing Floor" ]; then
	gamedirname="KillingFloor"
	array_configs+=( Default.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Left 4 Dead" ]; then
	gamedirname="Left4Dead"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Left 4 Dead" ]; then
	gamedirname="Left4Dead"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Left 4 Dead 2" ]; then
	gamedirname="Left4Dead2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Minecraft" ]; then
	gamedirname="Minecraft"
	array_configs+=( server.properties )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "No More Room in Hell" ]; then
	gamedirname="NoMoreRoominHell"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Mumble" ]; then
	:
elif [ "${gamename}" == "Natural Selection 2" ]; then
	:
elif [ "${gamename}" == "NS2: Combat" ]; then
	:
elif [ "${gamename}" == "Pirates, Vikings, and Knights II" ]; then
	gamedirname="PiratesVikingandKnightsII"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Project Zomboid" ]; then
	gamedirname="ProjectZomboid"
	array_configs+=( server.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Quake Live" ]; then
	gamedirname="QuakeLive"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Red Orchestra: Ostfront 41-45" ]; then
	:
elif [ "${gamename}" == "Ricochet" ]; then
	gamedirname="Ricochet"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
	fn_user_input_config
elif [ "${gamename}" == "Rust" ]; then
	gamedirname="Rust"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Serious Sam 3: BFE" ]; then
	gamedirname="SeriousSam3BFE"
	array_configs+=( server.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Starbound" ]; then
	gamedirname="Starbound"
	array_configs+=( starbound.config )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Sven Co-op" ]; then
	gamedirname="SvenCoop"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Team Fortress 2" ]; then
	gamedirname="TeamFortress2"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Team Fortress Classic" ]; then
	gamedirname="TeamFortressClassic"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	gamedirname="TeamSpeak3"
	array_configs+=( ts3server.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Teeworlds" ]; then
	gamedirname="TeeWorlds"
	array_configs+=( server.cfg ctf.cfg dm.cfg duel.cfg tdm.cfg )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Terraria" ]; then
	gamedirname="Terraria"
	array_configs+=( serverconfig.txt )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Unreal Tournament" ]; then
	:
elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
	:
elif [ "${gamename}" == "Unreal Tournament 3" ]; then
	:
elif [ "${gamename}" == "Unreal Tournament 99" ]; then
	gamedirname="UnrealTournament99"
	array_configs+=( Game.ini Engine.ini )
	fn_fetch_default_config
	fn_default_config_remote
elif [ "${gamename}" == "Enemy Territory" ]; then
	gamedirname="WolfensteinEnemyTerritory"
	array_configs+=( server.cfg )
	fn_fetch_default_config
	fn_default_config_remote
fi

