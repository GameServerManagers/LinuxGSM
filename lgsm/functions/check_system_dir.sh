#!/bin/bash
# LGSM check_system_dir.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

if [ ! -d "${systemdir}" ]; then
	fn_print_fail_nl "Cannot access ${systemdir}: No such directory"
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "Cannot access ${systemdir}: No such directory."
	fi
	exit 1
fi
