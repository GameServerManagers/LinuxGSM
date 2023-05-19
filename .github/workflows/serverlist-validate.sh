#!/bin/bash
echo "Checking that all the game servers are listed in all csv files"
echo "this check will ensure serverlist.csv has the same number of lines (-2 lines) as the other csv files"
# count the number of lines in the serverlist.csv
cd "lgsm/data" || exit
serverlistcount="$(wc -l < serverlist.csv)"
echo "serverlistcount: $serverlistcount"
# get list of all csv files starting with ubunutu debian centos
csvlist="$(ls -1 | grep -E '^(ubuntu|debian|centos|rhel|almalinux|rocky).*\.csv$')"
# loop though each csv file and make sure the number of lines is the same as the serverlistcount
for csv in $csvlist; do
	csvcount="$(wc -l < "${csv}")"
	csvcount=$((csvcount-2))
	if [ "$csvcount" -ne "$serverlistcount" ]; then
		echo "ERROR: $csv ($csvcount) does not match serverlist.csv ($serverlistcount)"
		exitcode=1
	else
		echo "OK: $csv ($csvcount) and serverlist.csv ($serverlistcount) match"
	fi
done

exit "${exitcode}"
