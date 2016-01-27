#!/bin/bash
# LGSM check_root.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# If you want to run as root (i.e. in Docker, or just because you hate security)
# set the following variable in your environment or config scripts.
#I_KNOW_THIS_IS_A_BAD_IDEA=YES
if [ $(whoami) = "root" ] && [ "${I_KNOW_THIS_IS_A_BAD_IDEA}" != "YES" ]; then
	fn_printfailnl "Do NOT run this script as root!"
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "${selfname} attempted to run as root."
	fi	
	exit 1
fi
