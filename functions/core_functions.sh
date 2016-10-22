#!/bin/bash
# LGSM core_functions.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: REDIRECT FUNCTION to new location for core_functions.sh

# fn_fetch_core_dl also placed here to allow legecy servers to still download core functions
if [ -z "${lgsmdir}" ]; then
	lgsmdir="${rootdir}/lgsm"
	functionsdir="${lgsmdir}/functions"
	libdir="${lgsmdir}/lib"
fi

fn_fetch_core_dl(){
if [ -z "${githubuser}" ]; then
	githubuser="GameServerManagers"
fi
if [ -z "${githubrepo}" ]; then
	githubrepo="LinuxGSM"
fi
if [ -z "${githubbranch}" ]; then
	githubbranch="master"
fi
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
			echo -e "${red}FAIL${default}\n"
			echo "${curlfetch}"
			echo -e "${githuburl}\n"
			exit 1
		else
			echo -e "${green}OK${default}"
		fi
	else
		echo -e "${red}FAIL${default}\n"
		echo "Curl is not installed!"
		echo -e ""
		exit 1
	fi
	chmod +x "${filedir}/${filename}"
fi
source "${filedir}/${filename}"
}

core_functions.sh(){
functionfile="${FUNCNAME}"
fn_fetch_core_dl
}

core_functions.sh
