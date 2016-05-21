#!/bin/bash
# LGSM check_logs.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Checks that log files exist on server start

# Create dir's for the script and console logs
if [ ! -d "${scriptlogdir}" ]; then
	fn_print_dots "Checking for log files"
	sleep 1
	fn_print_info_nl "Checking for log files: Creating log files"
	checklogs=1
	install_logs.sh
fi
