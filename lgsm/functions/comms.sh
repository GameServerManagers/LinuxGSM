#!/bin/bash
# LGSM comms.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Overall function for managing notifications.

if [ "${emailnotification}" == "on" ]||[ -n "${email}" ]; then
	comms_email.sh
fi

if [ "${pushbulletnotification}" == "on" ]||[ -n "${pushbullettoken}" ]; then
	comms_pushbullet.sh
fi