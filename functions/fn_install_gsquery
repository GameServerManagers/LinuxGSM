#!/bin/bash
# LGSM fn_install_gsquery function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

fn_dlgsquery(){
cd "${rootdir}"
echo -e "downloading gsquery.py...\c"
wget -N /dev/null "http://gameservermanagers.com/dl/gsquery.py" 2>&1 | grep -F "HTTP" | grep -v "Moved Permanently" | cut -c45- | uniq
chmod +x gsquery.py
}

if [ "${engine}" == "avalanche" ]||[ "${engine}" == "goldsource" ]||[ "${engine}" == "realvirtuality" ]||[ "${engine}" == "source" ]||[ "${engine}" == "spark" ]||[ "${engine}" == "unity3d" ]||[ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
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
