#!/bin/bash
# LGSM info_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: stores details on servers Glibc requirements.

if [ "${gamename}" == "Blade Symphony" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "BrainBread 2" ]; then
	glibcrequired="2.17"
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Fistful of Frags" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Garry's Mod" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Insurgency" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "No More Room in Hell" ]; then
	glibcrequired="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Quake Live" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${engine}" == "avalanche" ]; then
	glibcrequired="2.13"
	glibcfix="yes"
elif [ "${engine}" == "dontstarve" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${engine}" == "projectzomboid" ]; then
	glibcrequired="2.15"
	glibcfix="yesno"
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
elif [ "${engine}" == "unreal4" ]; then
	glibcrequired="2.14"
	glibcfix="no"
elif [ "${engine}" == "unity3d" ]; then
	glibcrequired="2.15"
	glibcfix="no"
elif [ "${gamename}" == "Teamspeak 3" ]; then
	glibcrequired="NOT REQUIRED"
	glibcfix="no"	
else
	glibcrequired="UNKNOWN"
	glibcfix="no"
fi
