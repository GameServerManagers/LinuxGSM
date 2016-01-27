#!/bin/bash
# LGSM install_gsquery.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

fn_dlgsquery(){
	gsquery_path="${lgsmdir}/gsquery.py"
	if [ ! -e "${gsquery_path}" ]; then
		echo -e "downloading gsquery.py...\c"
		curl -sL "http://gameservermanagers.com/dl/gsquery.py" -o "${gsquery_path}"
	fi
	if ! -x "${gsquery_path}" ]; then
		chmod +x "${gsquery_path}"
	fi
}

if [ "${engine}" == "avalanche" ]||[ "${engine}" == "goldsource" ]||[ "${engine}" == "realvirtuality" ]||[ "${engine}" == "source" ]||[ "${engine}" == "spark" ]||[ "${engine}" == "unity3d" ]||[ "${gamename}" == "Hurtworld" ]||[ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	echo ""
	echo "GameServerQuery"
	echo "============================"
	if [ -z ${autoinstall} ]; then
		while true; do
			read -e -i "y" -p "Do you want to install GameServerQuery? [Y/n]" yn
			case $yn in
			[Yy]* ) fn_dlgsquery;break;;
			[Nn]* ) echo ""; echo "Not installing GameServerQuery.";break;;
			* ) echo "Please answer yes or no.";;
		esac
		done
	else
		fn_dlgsquery
	fi
fi
