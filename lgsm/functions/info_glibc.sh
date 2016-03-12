#!/bin/bash
# LGSM info_glibc.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="260216"

# Description: stores details on servers Glibc requirements.

if [ "${gamename}" == "Blade Symphony" ]; then
	glibc_required="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "BrainBread 2" ]; then
	glibc_required="2.17"
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	glibc_required="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Fistful of Frags" ]; then
	glibc_required="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Garry's Mod" ]; then
	glibc_required="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Insurgency" ]; then
	glibc_required="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "No More Room in Hell" ]; then
	glibc_required="2.15"
	glibcfix="yes"
elif [ "${gamename}" == "Quake Live" ]; then
	glibc_required="2.15"
	glibcfix="no"
elif [ "${engine}" == "avalanche" ]; then
	glibc_required="2.13"
	glibcfix="yes"
elif [ "${engine}" == "dontstarve" ]; then
	glibc_required="2.15"
	glibcfix="no"
elif [ "${engine}" == "projectzomboid" ]; then
	glibc_required="2.15"
	glibcfix="yesno"
elif [ "${engine}" == "realvirtuality" ]; then
	glibc_required="2.13"
	glibcfix="yes"
elif [ "${engine}" == "seriousengine35" ]; then
	glibc_required="2.13"
	glibcfix="yes"
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	glibc_required="2.3.6"
	glibcfix="no"
elif [ "${engine}" == "spark" ]; then
	glibc_required="2.15"
	glibcfix="yes"
elif [ "${engine}" == "starbound" ]; then
	glibc_required="2.12"
	glibcfix="no"
elif [ "${engine}" == "unreal" ]; then
	glibc_required="2.1"
	glibcfix="no"	
elif [ "${engine}" == "unreal2" ]; then
	glibc_required="2.4"
	glibcfix="no"
elif [ "${engine}" == "unreal4" ]; then
	glibc_required="2.14"
	glibcfix="no"
elif [ "${engine}" == "unity3d" ]; then
	glibc_required="2.15"
	glibcfix="no"
else
	glibc_required="UNKNOWN"
	glibcfix="no"
fi
