#!/bin/bash
# LGSM check_systemdir.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="161215"

if [ ! -d "${systemdir}" ]; then
	fn_printfailnl "Cannot access ${systemdir}: No such directory"
	exit 1
fi
