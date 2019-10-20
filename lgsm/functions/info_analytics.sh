#!/bin/bash
# LinuxGSM info_analytics.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Optional Analytics to send to LinuxGSM Developer
# Uses Google analytics
# Data collected: Game Server, Distro

info_distro.sh
if [ ! -f "${datadir}/uuid.txt" ];then
	if [ $(command -v uuidgen 2>/dev/null) ]; then
		uuidgen > "${datadir}/uuid.txt"
	else
		cat /proc/sys/kernel/random/uuid > "${datadir}/uuid.txt"
  fi
fi
# https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=distro" -d "ea=${distroid}" -d "el=${distroname}" -d "v=1" > /dev/null 2>&1
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=game" -d "ea=${shortname}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1
