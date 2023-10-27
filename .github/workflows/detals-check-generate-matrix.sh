#!/bin/bash

curl "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/${GITHUB_REF#refs/heads/}/lgsm/data/serverlist.csv" | grep -v '^[[:blank:]]*$' > serverlist.csv

echo -n "{" > "shortnamearray.json"
echo -n "\"include\":[" >> "shortnamearray.json"

while read -r line; do
	shortname=$(echo "$line" | awk -F, '{ print $1 }')
	export shortname
	servername=$(echo "$line" | awk -F, '{ print $2 }')
	export servername
	gamename=$(echo "$line" | awk -F, '{ print $3 }')
	export gamename
	distro=$(echo "$line" | awk -F, '{ print $4 }')
	export distro
	echo -n "{" >> "shortnamearray.json"
	echo -n "\"shortname\":" >> "shortnamearray.json"
	echo -n "\"${shortname}\"" >> "shortnamearray.json"
	echo -n "}," >> "shortnamearray.json"
done < <(tail -n +2 serverlist.csv)
sed -i '$ s/.$//' "shortnamearray.json"
echo -n "]" >> "shortnamearray.json"
echo -n "}" >> "shortnamearray.json"
rm serverlist.csv
