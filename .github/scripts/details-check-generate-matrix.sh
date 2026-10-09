#!/bin/bash
# Splits the servers to check into shards (one job each) and a list of legacy servers.
# Legacy servers need an older glibc than the hosted runners have, so they run in an ubuntu:20.04 container.
# Writes shards.json (matrix) and legacy.txt (space-separated shortnames).

ref="${LGSM_REF:-${GITHUB_REF#refs/heads/}}"
maxshards="${DETAILS_CHECK_SHARDS:-12}"
legacyservers="bfv bf1942 btl onset"

if [ -f lgsm/data/serverlist.csv ]; then
	serverlist="lgsm/data/serverlist.csv"
else
	curl -fsS "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/${ref}/lgsm/data/serverlist.csv" -o serverlist.csv
	serverlist="serverlist.csv"
fi

shortnames=()
legacy=()
while IFS=, read -r shortname _; do
	[ -z "${shortname}" ] && continue
	if [ -n "${TARGETED_SHORTNAMES:-}" ] && ! echo "${TARGETED_SHORTNAMES}" | grep -qw "${shortname}"; then
		continue
	fi
	if echo "${legacyservers}" | grep -qw "${shortname}"; then
		legacy+=("${shortname}")
	else
		shortnames+=("${shortname}")
	fi
done < <(tail -n +2 "${serverlist}" | grep -v '^[[:blank:]]*$')

count="${#shortnames[@]}"
shards=$((count < maxshards ? count : maxshards))
declare -a shard
for i in "${!shortnames[@]}"; do
	shard[i % shards]+="${shortnames[i]} "
done

{
	echo -n '{"include":['
	for ((i = 0; i < shards; i++)); do
		[ "${i}" -gt 0 ] && echo -n ','
		echo -n "{\"shard\":\"$((i + 1))/${shards}\",\"shortnames\":\"${shard[i]% }\"}"
	done
	echo -n ']}'
} > shards.json

echo -n "${legacy[*]}" > legacy.txt
[ "${serverlist}" == "serverlist.csv" ] && rm serverlist.csv

echo "Servers: ${count} in ${shards} shard(s), legacy: ${legacy[*]:-none}"
