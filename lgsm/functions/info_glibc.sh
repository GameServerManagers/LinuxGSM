#!/bin/bash
# LGSM info_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Stores details on servers Glibc requirements.

local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ "${gamename}" == "Black Mesa: Deathmatch" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Blade Symphony" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "BrainBread 2" ]; then
	glibcrequired="2.17"
elif [ "${gamename}" == "Day of Infamy" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Empires Mod" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Fistful of Frags" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Garry's Mod" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "GoldenEye: Source" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${gamename}" == "Insurgency" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Mumble" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${gamename}" == "No More Room in Hell" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Quake Live" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"
elif [ "${gamename}" == "Teeworlds" ]; then
	glibcrequired="2.3"
	glibcfix="no"
elif [ "${engine}" == "avalanche" ]; then
	glibcrequired="2.13"
	glibcfix="yes"
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
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	glibcrequired="2.3.6"
	glibcfix="no"
elif [ "${engine}" == "spark" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${engine}" == "starbound" ]; then
	glibcrequired="2.12"
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
elif [ "${engine}" == "idtech3" ]; then
	glibcrequired="2.0"
	glibcfix="no"
elif [ "${engine}" == "refractor" ]; then
	glibcrequired="2.0"
	glibcfix="no"
else
	glibcrequired="UNKNOWN"
	glibcfix="no"
fi
