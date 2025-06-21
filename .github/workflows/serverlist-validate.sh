#!/bin/bash
echo "Checking that all the game servers are listed in all csv files"
echo "this check will ensure serverlist.csv has the same number of lines (-2 lines) as the other csv files"
# count the number of lines in the serverlist.csv
cd "${datadir}" || exit
serverlistcount="$(tail -n +2 serverlist.csv | wc -l)"
echo "serverlistcount: $serverlistcount"
# get list of all csv files starting with ubunutu debian centos
csvlist="$(ls -1 | grep -E '^(ubuntu|debian|centos|rhel|almalinux|rocky).*\.csv$')"
# loop though each csv file and make sure the number of lines is the same as the serverlistcount
for csv in $csvlist; do
	csvcount="$(wc -l < "${csv}")"
	csvcount=$((csvcount - 2))
	if [ "$csvcount" -ne "$serverlistcount" ]; then
		echo "ERROR: $csv ($csvcount) does not match serverlist.csv ($serverlistcount)"
		exitcode=1
	else
		echo "OK: $csv ($csvcount) and serverlist.csv ($serverlistcount) match"
	fi
done

# Compare all game servers listed in serverlist.csv to $shortname-icon.png files in ${datadir}/gameicons
# if the game server is listed in serverlist.csv then it will have a $shortname-icon.png file

# loop though shortname in serverlist.csv
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

exit ${exitcode}
