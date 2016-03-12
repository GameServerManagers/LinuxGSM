#!/bin/bash
# LGSM check_system_dir.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

if [ ! -d "${systemdir}" ]; then
	fn_print_fail_nl "Cannot access ${systemdir}: No such directory"
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "Cannot access ${systemdir}: No such directory."
	fi		
	exit 1
fi
