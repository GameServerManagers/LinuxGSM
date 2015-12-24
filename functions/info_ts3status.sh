#!/bin/bash
# LGSM fn_check_ts3status function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

# Checks the status of Teamspeak 3.

cd "${executabledir}"
ts3status=$(./ts3server_startscript.sh status servercfgfullpathfile=${servercfgfullpath})
