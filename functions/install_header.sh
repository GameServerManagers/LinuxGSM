#!/bin/bash
# LGSM install_header.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

clear
echo "================================="
echo "${gamename}"
echo "Linux Game Server Manager"
echo "by Daniel Gibbs"
if [ "${gamename}" == "ARMA 3" ]; then
	echo "contributions by Scarsz"
elif [ "${gamename}" == "Left 4 Dead" ]; then
	echo "contributions by Summit Singh Thakur"
elif [ "${gamename}" == "Teeworlds" ]; then
	echo "contributions by Bryce Van Dyk (SingingTree)"	
fi
echo "http://gameservermanagers.com"
echo "================================="