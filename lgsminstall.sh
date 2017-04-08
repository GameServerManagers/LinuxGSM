#!/bin/bash
# Project: Game Server Managers - LinuxGSM
# Author: Daniel Gibbs
# License: MIT License, Copyright (c) 2017 Daniel Gibbs
# Purpose: Counter-Strike: Global Offensive | Server Management Script
# Contributors: https://github.com/GameServerManagers/LinuxGSM/graphs/contributors
# Documentation: https://github.com/GameServerManagers/LinuxGSM/wiki
# Website: https://gameservermanagers.com

# Debugging
if [ -f ".dev-debug" ]; then
	exec 5>dev-debug.log
	BASH_XTRACEFD="5"
	set -x
fi

version="170305"
sname="core"
rootdir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
servicename="${selfname}"

## Github Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="GameServerManagers"
githubrepo="LinuxGSM"
githubbranch="config"

source lgsm/config/_default.cfg
source lgsm/config/common.cfg
source lgsm/config/${servicename.cfg

# LinuxGSM installer
if [ "${sname}" == "core" ]; then
	userinput=$1
	if [ -z "${userinput}" ]; then
		userinput="empty"
	fi
	serverslist=$(grep "${userinput}" lgsm/data/serverlist.csv|awk -F "," '{print $2}')
	echo "USERINPUT: $userinput"
	echo "SERVERLIST: $serverslist"
	if [ "${userinput}" == "${serverslist}" ]; then
		echo "installing"
		sname=$(grep $userinput lgsm/data/serverlist.csv|awk -F "," '{print $1}')
		servername=$(grep $userinput lgsm/data/serverlist.csv|awk -F "," '{print $2}')
		if [ -e "${servername}" ]; then
			i=2
		while [ -e "$servername-$i" ] ; do
			let i++
		done
			servername="${servername}-$i"
		fi
		cp "${selfname}" "${servername}"
		sed -i -e "s/sname=\"core\"/sname=\"${sname}\"/g" "${servername}"
		exit
	elif [ "$userinput" == "list" ]; then
		{
			awk -F "," '{print $2 "\t" $3}' "lgsm/data/serverlist.csv"
		} | column -s $'\t' -t
		exit
	else
		echo "Usage: ./${selfname} list"
		echo "For a complete list of available servers"
		echo ""
		echo "Usage: ./${selfname} [servername]"
		echo "To install a server"
		exit
	fi
fi




########################
######## Script ########
###### Do not edit #####
########################

# Fetches core_dl for file downloads
fn_fetch_core_dl(){
github_file_url_dir="lgsm/functions"
github_file_url_name="${functionfile}"
filedir="${functionsdir}"
filename="${github_file_url_name}"
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
# If the file is missing, then download
if [ ! -f "${filedir}/${filename}" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir -p "${filedir}"
	fi
	echo -e "    fetching ${filename}...\c"
	# Check curl exists and use available path
	curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
	for curlcmd in ${curlpaths}
	do
		if [ -x "${curlcmd}" ]; then
			break
		fi
	done
	# If curl exists download file
	if [ "$(basename ${curlcmd})" == "curl" ]; then
		curlfetch=$(${curlcmd} -s --fail -o "${filedir}/${filename}" "${githuburl}" 2>&1)
		if [ $? -ne 0 ]; then
			echo -e "\e[0;31mFAIL\e[0m\n"
			echo "${curlfetch}"
			echo -e "${githuburl}\n"
			exit 1
		else
			echo -e "\e[0;32mOK\e[0m"
		fi
	else
		echo -e "\e[0;31mFAIL\e[0m\n"
		echo "Curl is not installed!"
		echo -e ""
		exit 1
	fi
	chmod +x "${filedir}/${filename}"
fi
source "${filedir}/${filename}"
}

core_dl.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_functions.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

# Prevent from running this script as root.
if [ "$(whoami)" = "root" ]; then
	if [ ! -f "${functionsdir}/core_functions.sh" ]||[ ! -f "${functionsdir}/check_root.sh" ]||[ ! -f "${functionsdir}/core_messages.sh" ]||[ ! -f "${functionsdir}/core_exit.sh" ]; then
		echo "[ FAIL ] Do NOT run this script as root!"
		exit 1
	else
		core_functions.sh
		check_root.sh
	fi
fi

core_dl.sh
core_functions.sh



getopt=$1
core_getopt.sh
