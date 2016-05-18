#!/bin/bash
# LGSM alert.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Overall function for managing alerts.

if [ "${emailnotification}" == "on" ]||[ "${emailalert}" == "on" ]&&[ -n "${email}" ]; then
	alert_email.sh
fi

if [ "${pushbulletalert}" == "on" ]||[ -n "${pushbullettoken}" ]; then
	alert_pushbullet.sh
fi