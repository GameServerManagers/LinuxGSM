#!/bin/bash

cd "lgsm/data" || exit

echo ""
echo "Checking that all the game servers listed in serverlist.csv have a shortname-icon.png file"
for shortname in $(tail -n +2 serverlist.csv | cut -d ',' -f1); do
	# check if $shortname-icon.png exists
	if [ ! -f "gameicons/${shortname}-icon.png" ]; then
		echo "ERROR: gameicons/${shortname}-icon.png does not exist"
		exitcode=1
	else
		echo "OK: gameicons/${shortname}-icon.png exists"
	fi
done

# check that the number of gameicons matches the number of servers in serverlist.csv
echo ""
echo "Checking that the number of gameicons matches the number of servers in serverlist.csv"
gameiconcount="$(ls -1 gameicons | wc -l)"
serverlistcount="$(tail -n +2 serverlist.csv | wc -l)"
if [ "${gameiconcount}" -ne "${serverlistcount}" ]; then
	echo "ERROR: game icons (${gameiconcount}) does not match serverlistcount ($serverlistcount)"
	exitcode=1
else
	echo "OK: gameiconcount ($gameiconcount) matches serverlistcount ($serverlistcount)"
fi

exit ${exitcode}
