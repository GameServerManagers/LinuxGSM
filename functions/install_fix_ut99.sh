#!/bin/bash
# LGSM fn_install_ut99fix function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

echo "Applying ${gamename} Server Fixes"
echo "================================="
echo "enabling UdpServerUplink."
{
echo "[IpServer.UdpServerUplink]"
echo "DoUplink=True"
echo "UpdateMinutes=1"
echo "MasterServerAddress=unreal.epicgames.com"
echo "MasterServerPort=27900"
echo "Region=0"
}|tee -a "${servercfgfullpath}" > /dev/null 2>&1
sleep 1
echo "removing dead gamespy.com master server."
sed -i '/master0.gamespy.com/d' "${servercfgfullpath}"
sleep 1
echo "removing dead mplayer.com master server."
sed -i '/master.mplayer.com/d' "${servercfgfullpath}"
sleep 1
echo "inserting qtracker.com master server."
sed -i '66i\ServerActors=IpServer.UdpServerUplink MasterServerAddress=master.qtracker.com MasterServerPort=27900' "${servercfgfullpath}"
echo ""