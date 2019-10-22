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
	if [ "$(command -v uuidgen 2>/dev/null)" ]; then
		uuidgen > "${datadir}/uuid.txt"
	else
		cat /proc/sys/kernel/random/uuid > "${datadir}/uuid.txt"
  fi
fi

uuid=$(cat "${datadir}/uuid.txt")
# results are rounded up to reduce number of different results in analytics
# nearest 100Mhz
cpuusedmhzroundup=$(((${cpuusedmhz} + 99) / 100 * 100))
# nearest 100MB
memusedroundup=$(((${memused} + 99) / 100 * 100))
# nearest GB
serverfilesduroundup=$(((${serverfilesdu} + 9) / 10 * 10))

# https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters
# Level 1 Analytics
## Distro
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=distro" -d "ea=${distroid}" -d "el=${distroname}" -d "v=1" > /dev/null 2>&1
## Game Server Name
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=game" -d "ea=${shortname}" -d "el=${gamename}" -d "v=1" > /dev/null 2>&1

# Level 2 Analytics
## CPU usage of a game server
if [ "${cpuusedmhzroundup}" ]; then
  curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=cpuused" -d "ea=${shortname}" -d "el=${cpuusedmhzroundup}MHz" -d "v=1" > /dev/null 2>&1
fi
## Ram usage of a game server
if [ "${memusedroundup}" ]; then
  curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=ramused" -d "ea=${shortname}" -d "el=${memusedroundup}" -d "v=1" > /dev/null 2>&1
fi
## Disk usage of a game server
if [ "${serverfilesdu}" ]; then
  curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "aip=1" -d "cid=${uuid}" -d "t=event" -d "ec=diskused" -d "ea=${shortname}" -d "el=${serverfilesdu}" -d "v=1" > /dev/null 2>&1
fi
