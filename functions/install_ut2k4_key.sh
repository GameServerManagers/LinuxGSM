#!/bin/bash
# LGSM install_ut2k4_key.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

echo ""
echo "Enter ${gamename} CD Key"
echo "================================="
sleep 1
echo "To get your server listed on the Master Server list"
echo "you must get a free CD key. Get a key here:"
echo "https://forums.unrealtournament.com/utserver/cdkey.php?2004"
echo ""
echo "Once you have the key enter it below"
echo -n "KEY: "
read CODE
echo ""\""CDKey"\""="\""${CODE}"\""" > "${systemdir}/cdkey"
echo ""
