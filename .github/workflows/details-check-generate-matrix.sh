#!/bin/bash

ref="${LGSM_REF:-${GITHUB_REF#refs/heads/}}"
curl "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/${ref}/lgsm/data/serverlist.csv" | grep -v '^[[:blank:]]*$' > serverlist.csv

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
	# Legacy servers that require older Ubuntu/Debian versions due to glibc compatibility
	case "${shortname}" in
		bfv|bf1942)
			# Requires Ubuntu <= 22.04 or Debian <= 12 (glibc 2.31 compatible)
			runner="ubuntu-22.04"
			;;
		btl|onset)
			# Requires Ubuntu <= 20.04 or Debian <= 11 (glibc 2.31 compatible)
			runner="ubuntu-20.04"
			;;
		*)
			runner="ubuntu-latest"
			;;
	esac
	{
		echo -n "{";
		echo -n "\"shortname\":";
		echo -n "\"${shortname}\"";
		echo -n ",\"runner\":";
		echo -n "\"${runner}\"";
		echo -n "},";
	} >> "shortnamearray.json"
done < <(tail -n +2 serverlist.csv)
sed -i '$ s/.$//' "shortnamearray.json"
echo -n "]" >> "shortnamearray.json"
echo -n "}" >> "shortnamearray.json"
rm serverlist.csv
