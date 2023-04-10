#!/bin/bash
# LinuxGSM command_dev_debug.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Dev only: Displays all parsed details.

echo -e ""
echo -e "${lightgreen}Details List${default}"
echo -e "=================================================================="
echo -e ""
echo -e "Game: ${gamename}"
echo -e "Short Name: ${shortname}"
echo -e "Directory: ${rootdir}"
echo -e "Binary: ${executable}"
echo -e "Config: ${servercfgfullpath}"
echo -e "Port: ${port}"
echo -e "Query Port: ${queryport}"

echo -e "Servername: ${servername}"
echo -e "Server Password: ${serverpassword}"
echo -e "RCON Password: ${rconpassword}"
echo -e "Admin Password: ${adminpassword}"
echo -e "Maxplayers: ${maxplayers}"
echo -e "Tickrate: ${tickrate}"
echo -e "Default Map: ${defaultmap}"
echo -e "Game Mode: ${gamemode}"
echo -e "RCON Enabled: ${rconenabled}"
echo -e "RCON Password: ${rconpassword}"
echo -e "Config IP: ${configip}"
