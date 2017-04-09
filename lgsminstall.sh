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
rootdir="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
lgsmdir="${rootdir}/lgsm"
tmpdir="${lgsmdir}/tmp"
servicename="${selfname}"
shortname="core"
shortname="core"
shortname="core"
configdir="${lgsmdir}/config"
gameconfigdir="${configdir}/${servername}"

## Github Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="GameServerManagers"
githubrepo="LinuxGSM"
githubbranch="feature/config"

## Github Branch Select
# Allows for the use of different function files
# from a different repo and/or branch.
githubuser="GameServerManagers"
githubrepo="LinuxGSM"
githubbranch="feature/config"


# Prevent from running this script as root.
if [ "$(whoami)" = "root" ]; then
	if [ ! -f "${functionsdir}/core_functions.sh" ]||[ ! -f "${functionsdir}/check_root.sh" ]||[ ! -f "${functionsdir}/core_messages.sh" ]||[ ! -f "${functionsdir}/exit 1" ]; then
		echo "[ FAIL ] Do NOT run this script as root!"
		exit 1
	else
		core_functions.sh
		check_root.sh
	fi
fi

# LinuxGSM installer
if [ "${shortname}" == "core" ]; then
	userinput=$1
	if [ -z "${userinput}" ]; then
		userinput="empty"
	fi
	serverslist=$(grep "${userinput}" <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/serverlist.csv")|awk -F "," '{print $2}')
	echo "USERINPUT: $userinput"
	echo "SERVERLIST: $serverslist"
	if [ "${userinput}" == "${serverslist}" ]; then
		echo "installing"
		shortname=$(grep ${userinput} <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/serverlist.csv")|awk -F "," '{print $1}')
		servername=$(grep ${userinput} <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/serverlist.csv")|awk -F "," '{print $2}')
		gamename=$(grep ${userinput} <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/serverlist.csv")|awk -F "," '{print $3}')
		if [ -e "${servername}" ]; then
			i=2
		while [ -e "$servername-$i" ] ; do
			let i++
		done
			servername="${servername}-$i"
		fi
		cp "${selfname}" "${servername}"
		sed -i -e "s/shortname=\"core\"/shortname=\"${shortname}\"/g" "${servername}"
		sed -i -e "s/servername=\"core\"/servername=\"${servername}\"/g" "${servername}"
		sed -i -e "s/gamename=\"core\"/gamename=\"${gamename}\"/g" "${gamename}"
		exit
	elif [ "${userinput}" == "list" ]; then
		{
			awk -F "," '{print $2 "\t" $3}' <(curl -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/serverlist.csv")
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

# Bootstrap

# Fetches bootstrap files (configs and core functions)
fn_boostrap_fetch_file(){
	fileurl="${1}"
	filedir="${2}"
	filename="${3}"
	executecmd="${4:-0}"
	run="${5:-0}"
	force="${6:-0}"
	# If the file is missing, then download
	if [ ! -f "${filedir}/${filename}" ]; then
		if [ ! -d "${filedir}" ]; then
			mkdir -p "${filedir}"
		fi
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
			# trap to remove part downloaded files
			echo -ne "    fetching ${filename}...\c"
			curlcmd=$(${curlcmd} -s --fail -L -o "${filedir}/${filename}" "${fileurl}" 2>&1)
			local exitcode=$?
			if [ ${exitcode} -ne 0 ]; then
				echo -e "\e[0;31mFAIL\e[0m\n"
				echo -e "${fileurl}" | tee -a "${scriptlog}"
				echo "${curlcmd}" | tee -a "${scriptlog}"
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
		# make file executecmd if executecmd is set
		if [ "${executecmd}" == "executecmd" ]; then
			chmod +x "${filedir}/${filename}"
		fi
	fi

	if [ -f "${filedir}/${filename}" ]; then
		# run file if run is set
		if [ "${run}" == "run" ]; then
			source "${filedir}/${filename}"
		fi
	fi
}

fn_boostrap_fetch_function(){
	github_file_url_dir="lgsm/functions" # github dir containing the file
	github_file_url_name="${functionfile}" # name of the github file
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fileurl="${githuburl}"
	filedir="${functionsdir}"
	filename="${github_file_url_name}"
	executecmd="executecmd"
	run="run"
	force="noforce"
	md5="nomd5"
	fn_boostrap_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
}

fn_boostrap_fetch_config(){
	github_file_url_dir="${1}" # github dir containing the file
	github_file_url_name="${2}" # name of the github file
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fileurl="${githuburl}"
	filedir="${3}"
	filename="${4}"
	executecmd="noexecutecmd"
	run="norun"
	force="noforce"
	md5="nomd5"
	fn_boostrap_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
}

# Load the default config. If missing download it. If changed reload it.
if [ ! -f "${tmpdir}/config/${servername}/_default.cfg" ];then
	fn_boostrap_fetch_config "lgsm/config/${servername}" "_default.cfg" "${tmpdir}/config/${servername}" "_default.cfg" "noexecutecmd" "norun" "noforce" "nomd5"
fi
if [ ! -f "${gameconfigdir}/_default.cfg" ];then
	echo "hello"
	cp "${tmpdir}/config/${servername}/_default.cfg" "${gameconfigdir}/_default.cfg"
else
	function_file_diff=$(diff -q ${tmpdir}/config/${servername}/_default.cfg ${gameconfigdir}/_default.cfg)
	if [ "${function_file_diff}" != "" ]; then
		echo "config different onverwriting"
		cp "${tmpdir}/config/${servername}/_default.cfg" "${gameconfigdir}/_default.cfg"
	fi
	source lgsm/config/${servername}/_default.cfg
fi

if [ ! -f "${gameconfigdir}/common.cfg" ];then
	fn_boostrap_fetch_config "lgsm/config" "common-template.cfg" "${lgsmdir}/config/${servername}" "common.cfg" "${executecmd}" "noexecutecmd" "norun" "noforce" "nomd5"
	source lgsm/config/${servername}/common.cfg
else
	source lgsm/config/${servername}/common.cfg
fi

if [ ! -f "${gameconfigdir}/${servicename}.cfg" ];then
	fn_boostrap_fetch_config "lgsm/config" "instance-template.cfg" "${lgsmdir}/config/${servername}" "${servicename}.cfg" "noexecutecmd" "norun" "noforce" "nomd5"
	source lgsm/config/${servername}/${servicename}.cfg
else
	source lgsm/config/${servername}/${servicename}.cfg
fi

########################
######## Script ########
###### Do not edit #####
########################

core_dl.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_boostrap_fetch_function
}

core_functions.sh(){
# Functions are defined in core_functions.sh.
functionfile="${FUNCNAME}"
fn_boostrap_fetch_function
}


core_dl.sh
core_functions.sh

getopt=$1
core_getopt.sh
