#!/bin/bash
# LGSM fn_check_logs function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

# Description: Checks that log files exist on server start

# Create dir's for the script and console logs
if [ ! -d "${scriptlogdir}" ]; then
	fn_printdots "Checking for log files"
	sleep 1
	fn_printinfo "Checking for log files: Creating log files"
	echo -en "\n"
	checklogs=1
	fn_install_logs
fi
