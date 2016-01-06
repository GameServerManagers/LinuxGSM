#!/bin/bash
# LGSM check_config.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="060116"

# Description: If server config missing warn user.

if [ ! -e "${servercfgfullpath}" ]; then
	if [ "${gamename}" != "Hurtworld" ]; then
		fn_printwarnnl "Configuration file missing"
		echo "${servercfgfullpath}"
	fi
fi