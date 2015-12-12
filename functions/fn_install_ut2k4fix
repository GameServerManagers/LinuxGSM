#!/bin/bash
# LGSM fn_install_ut2k4fix function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

echo "Applying ${gamename} Server Fixes"
echo "================================="
echo "applying WebAdmin ut2003.css fix."
echo "http://forums.tripwireinteractive.com/showpost.php?p=585435&postcount=13"
sed -i 's/none}/none;/g' "${filesdir}/Web/ServerAdmin/ut2003.css"
sed -i 's/underline}/underline;/g' "${filesdir}/Web/ServerAdmin/ut2003.css"
sleep 1
echo "applying WebAdmin CharSet fix."
echo "http://forums.tripwireinteractive.com/showpost.php?p=442340&postcount=1"
sed -i 's/CharSet="iso-8859-1"/CharSet="utf-8"/g' "${systemdir}/UWeb.int"
sleep 1
echo ""
echo -en "forcing server restart.\r"
sleep 0.5
echo -en "forcing server restart..\r"
sleep 0.5
echo -en "forcing server restart...\r"
sleep 0.5
echo -en "\n"
sleep 0.5
fn_start
sleep 5
fn_stop
fn_start
sleep 5
fn_stop