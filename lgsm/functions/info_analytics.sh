#!/bin/bash
# LinuxGSM info_analytics.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Optional Analytics to send to LinuxGSM Developer
# Uses Google analytics
# Data collected: Game Server, Distro

info_distro.sh
# generate uuid
if [ ! -f "${datadir}/uuid.txt" ];then
	if [ $(command -v uuidgen 2>/dev/null) ]; then
		uuidgen > "${datadir}/uuid.txt"
	else
		cat /proc/sys/kernel/random/uuid > "${datadir}/uuid.txt"
  fi
fi

uuid=$(cat "${datadir}/uuid.txt")

# https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters
# Level 1 Analytics
## Distro
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=distro" -d "ea=${distroid}" -d "el=${distroname}" -d "v=1" > /dev/null 2>&1
## Game Server Name
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=game" -d "ea=${shortname}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1

# Level 2 Analytics
## CPU usage of a game server
if [ "${cpuusedmhz}" ]; then
  curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=cpuused" -d "ea=${shortname}" -d "el=${cpuusedmhz}MHz" -d "v=1" > /dev/null 2>&1
fi
## Ram usage of a game server
if [ "${memused}" ]; then
  curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=ramused" -d "ea=${shortname}" -d "el=${memused}" -d "v=1" > /dev/null 2>&1
fi
## Disk usage of a game server
if [ "${serverfilesdu}" ]; then
  curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=diskused" -d "ea=${shortname}" -d "el=${serverfilesdu}" -d "v=1" > /dev/null 2>&1
fi
