#!/bin/bash
# LGSM check_steamuser.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

if [ "${steamuser}" == "username" ]; then
	fn_printfailnl "Steam login not set. Update steamuser."	
	echo "	* Change steamuser=\"username\" to a valid steam login."
	if [ -d ${scriptlogdir} ]; then
		fn_scriptlog "edit ${selfname}. change steamuser=\"username\" to a valid steam login."
		exit 1
	fi
fi
if [ -z "${steamuser}" ]; then
	fn_printwarnnl "Steam login not set. Using anonymous login."
	if [ -d "${scriptlogdir}" ]; then
		fn_scriptlog "Steam login not set. Using anonymous login."
	fi
	steamuser="anonymous"
	steampass=""
	sleep 2
fi
