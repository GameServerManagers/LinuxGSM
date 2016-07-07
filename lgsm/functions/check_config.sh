#!/bin/bash
# LGSM check_config.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: If server config missing warn user.

if [ ! -e "${servercfgfullpath}" ]; then
	if [ "${gamename}" != "Hurtworld" ]; then
		fn_print_warn_nl "Config file missing!"
		echo "${servercfgfullpath}"
		fn_script_log_warn "Configuration file missing!"
		fn_script_log_warn "${servercfgfullpath}"
		sleep 2
	fi
fi