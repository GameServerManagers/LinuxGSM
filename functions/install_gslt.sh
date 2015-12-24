#!/bin/bash
# LGSM fn_install_gslt function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="091215"

# Description: Configures GSLT.

if [ -z "${autoinstall}" ]; then
	echo ""
	echo "Game Server Login Token"
	echo "============================"
	sleep 1
	if [ "${gamename}" == "Counter Strike: Global Offensive" ]; then
		echo "GSLT is required to run a public ${gamename} server"
	else
		echo "GSLT is an optional feature for ${gamename} server"
	fi

	echo "Get more info and a token here:"
	echo "http://gameservermanagers.com/gslt"
	echo ""
	echo "Enter token below (Can be blank)."
	echo -n "GSLT TOKEN: "
	read token
	sed -i -e "s/gslt=\"\"/gslt=\"${token}\"/g" "${rootdir}/${selfname}"
	sleep 1
	echo "The GSLT can be changed by editing ${selfname}."
	echo ""
else
	if [ "${gamename}" == "Counter Strike: Global Offensive" ]; then
		fn_printinfomationnl "GSLT is required to run a public ${gamename} server"
	else
		fn_printinfomationnl "GSLT is an optional feature for ${gamename} server"
	fi
	echo "Get more info and a token here:"
	echo "http://gameservermanagers.com/gslt"
	echo ""	
	sleep 1
	echo "The GSLT can be changed by editing ${selfname}."	
	sleep 1
fi