#!/bin/bash
# LinuxGSM info_analytics.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Optional Analytics to send to LinuxGSM Developer
# Uses Google analytics
# Data collected: Game Server, Distro

info_distro.sh
curl https://www.google-analytics.com/collect -d "tid=UA-655379-31" -d "t=event" -d "ec=Distro" -d "ea=${distroid}" -d "el=${prettyname}" -d "v=1" -d "cid=12345678"
