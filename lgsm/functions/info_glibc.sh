#!/bin/bash
# LinuxGSM info_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Stores details on servers Glibc requirements.

function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${gamename}" == "ARK: Survival Evolved" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${gamename}" == "Ballistic Overkill" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Battalion 1944" ]; then
	glibcrequired="2.17"
	glibcfix="no"
elif [ "${gamename}" == "Base Defense" ]; then
	glibcrequired="2.14"
	glibcfix="no"
elif [ "${gamename}" == "Black Mesa: Deathmatch" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Blade Symphony" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "BrainBread 2" ]; then
	glibcrequired="2.17"
	glibcfix="no"
elif [ "${gamename}" == "Call of Duty" ]; then
	glibcrequired="2.1"
	glibcfix="no"
elif [ "${gamename}" == "Call of Duty 2" ]; then
	glibcrequired="2.1.3"
	glibcfix="no"
elif [ "${gamename}" == "Call of Duty: United Offensive" ]; then
	glibcrequired="2.1"
	glibcfix="no"
elif [ "${gamename}" == "Call of Duty 4" ]; then
	glibcrequired="2.3"
	glibcfix="no"
elif [ "${gamename}" == "Call of Duty: World at War" ]; then
	glibcrequired="2.3.2"
	glibcfix="no"
elif [ "${gamename}" == "Codename CURE" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Counter-Strike: Global Offensive" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Day of Infamy" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Eco" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${gamename}" == "Empires Mod" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Factorio" ]; then
	glibcrequired="2.18"
	glibcfix="yes"
elif [ "${gamename}" == "Fistful of Frags" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Garry's Mod" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "GoldenEye: Source" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Insurgency" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${shortname}" == "kf2" ]; then
	glibcrequired="2.17"
	glibcfix="no"
elif [ "${gamename}" == "Mumble" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${gamename}" == "No More Room in Hell" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Project Cars" ]; then
	glibcrequired="2.4"
	glibcfix="no"
elif [ "${gamename}" == "Pirates, Vikings, and Knights II" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Quake 2" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${gamename}" == "Quake 3: Arena" ]; then
	glibcrequired="2.1"
	glibcfix="no"
elif [ "${gamename}" == "Quake Live" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${shortname}" == "rw" ]; then
	glibcrequired="2.14"
	glibcfix="no"
elif [ "${gamename}" == "San Andreas Multiplayer" ]; then
	glibcrequired="2.3"
	glibcfix="no"
elif [ "${gamename}" == "Squad" ]; then
	glibcrequired="2.17"
	glibcfix="no"
elif [ "${gamename}" == "Sven Co-op" ]; then
	glibcrequired="2.18"
	glibcfix="no"
elif [ "${gamename}" == "Team Fortress 2" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${gamename}" == "Teeworlds" ]; then
	glibcrequired="2.14"
	glibcfix="no"
elif [ "${gamename}" == "Just Cause 2" ]; then
	glibcrequired="2.13"
	glibcfix="yes"
elif [ "${gamename}" == "Just Cause 3" ]; then
	glibcrequired="2.17"
	glibcfix="no"
elif [ "${engine}" == "dontstarve" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${engine}" == "lwjgl2" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${engine}" == "projectzomboid" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${engine}" == "realvirtuality" ]; then
	glibcrequired="2.13"
	glibcfix="yes"
elif [ "${engine}" == "seriousengine35" ]; then
	glibcrequired="2.13"
	glibcfix="yes"
elif [ "${engine}" == "source" ]; then
	glibcrequired="2.3.6"
	glibcfix="no"
elif [ "${engine}" == "goldsource" ]; then
	glibcrequired="2.3.4"
	glibcfix="no"
elif [ "${gamename}" == "Natural Selection 2" ]; then
	glibcrequired="2.17"
	glibcfix="no"
elif [ "${gamename}" == "NS2: Combat" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${engine}" == "starbound" ]; then
	glibcrequired="2.17"
	glibcfix="no"
elif [ "${engine}" == "quake" ]; then
	glibcrequired="2.0"
	glibcfix="no"
elif [ "${engine}" == "terraria" ]; then
	glibcrequired="2.7"
	glibcfix="no"
elif [ "${engine}" == "unreal" ]; then
	glibcrequired="2.1"
	glibcfix="no"
elif [ "${engine}" == "unreal2" ]; then
	glibcrequired="2.4"
	glibcfix="no"
elif [ "${engine}" == "unreal3" ]; then
	glibcrequired="2.3.2"
	glibcfix="no"
elif [ "${engine}" == "unreal4" ]; then
	glibcrequired="2.14"
	glibcfix="no"
elif [ "${engine}" == "unity3d" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${gamename}" == "Mumble" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${engine}" == "refractor" ]; then
	glibcrequired="2.0"
	glibcfix="no"
elif [ "${gamename}" == "Wolfenstein: Enemy Territory" ]; then
	glibcrequired="2.2.4"
	glibcfix="no"
elif [ "${gamename}" == "ET: Legacy" ]; then
	glibcrequired="2.7"
	glibcfix="no"
elif [ "${gamename}" == "Multi Theft Auto" ]; then
	glibcrequired="2.7"
	glibcfix="no"
elif [ "${gamename}" == "Zombie Panic! Source" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
else
	glibcrequired="UNKNOWN"
	glibcfix="no"
fi

# Sets the SteamCMD GLIBC requirement if the game server requirement is less or not required.
if [ -n "${appid}" ]; then
	if [ "${glibcrequired}" = "NOT REQUIRED" ]||[ -z "${glibcrequired}" ]||[ "$(printf '%s\n'${glibcrequired}'\n' "${glibcversion}" | sort -V | head -n 1)" != "2.14" ]; then
		glibcrequired="2.14"
		glibcfix="no"
	fi
fi
