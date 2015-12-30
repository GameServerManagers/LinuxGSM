#!/bin/bash
# LGSM fix_ut2k4.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

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
command_start.sh
sleep 5
command_stop.sh
command_start.sh
sleep 5
command_stop.sh