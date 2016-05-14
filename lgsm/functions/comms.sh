#!/bin/bash
# LGSM comms.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="140516"

# Description: Overall function for managing notifications.

if [ "${emailnotification}" == "on" ]; then
	comms_email.sh
fi

if [ "${pushbulletnotification}" == "on" ]; then
	comms_pushbullet.sh
fi