#!/bin/bash

curl "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/serverlist.csv" | grep -v '^[[:blank:]]*$' > serverlist.csv

echo -n "{" > "shortnamearray.json"
echo -n "\"include\":[" >> "shortnamearray.json"

while read line; do
	export shortname=$(echo "$line" | awk -F, '{ print $1 }')
	export servername=$(echo "$line" | awk -F, '{ print $2 }')
	export gamename=$(echo "$line" | awk -F, '{ print $3 }')
	export distro=$(echo "$line" | awk -F, '{ print $4 }')
	echo -n "{" >> "shortnamearray.json"
	echo -n "\"shortname\":" >> "shortnamearray.json"
	echo -n "\"${shortname}\"" >> "shortnamearray.json"
	echo -n "}," >> "shortnamearray.json"
done < serverlist.csv
sed -i '$ s/.$//' "shortnamearray.json"
echo -n "]" >> "shortnamearray.json"
echo -n "}" >> "shortnamearray.json"
rm serverlist.csv
