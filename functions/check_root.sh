#!/bin/bash
# LGSM check_root.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="060316"

if [ $(whoami) = "root" ]; then
	fn_printfailnl "Do NOT run this script as root!"
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "${selfname} attempted to run as root."
	fi	
	exit 1
fi
