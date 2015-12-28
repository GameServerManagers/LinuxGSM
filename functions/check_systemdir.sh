#!/bin/bash
# LGSM check_systemdir.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

if [ ! -d "${systemdir}" ]; then
	fn_printfailnl "Cannot access ${systemdir}: No such directory"
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "Cannot access ${systemdir}: No such directory."
	fi		
	exit 1
fi
