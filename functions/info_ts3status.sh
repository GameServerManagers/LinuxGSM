#!/bin/bash
# LGSM info_ts3status.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Checks the status of Teamspeak 3.

cd "${executabledir}"
ts3status=$(./ts3server_startscript.sh status servercfgfullpathfile=${servercfgfullpath})
