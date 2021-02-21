#!/bin/bash
# LinuxGSM command_dev_query_raw.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Raw gamedig output of the server.

commandname="DEV-QUERY-RAW"
commandaction="Developer query raw"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
info_config.sh
info_parms.sh

echo -e ""
echo -e "${lightgreen}Query IP Addresses${default}"
echo -e "=================================================================="
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "${queryip}"
done
echo -e ""
echo -e "${lightgreen}Game Server Ports${default}"
echo -e "=================================================================="
{
echo -e "${lightblue}Port Name\tPort Number\tStatus\tTCP\tUDP${default}"
if [ -v port ]; then
	echo -e "Game:\t${port}\t$(ss -tupl|grep ${port}|wc -l)\t$(ss -tupl|grep ${port}|grep tcp|awk '{ print $2 }')\t$(ss -tupl|grep ${port}|grep udp|awk '{ print $2 }')"
else
	echo -e "Game:\tN/A"
fi

if [ -v queryport ]; then
	echo -e "Query:\t${queryport}\t$(ss -tupl|grep ${queryport}|wc -l)\t$(ss -tupl|grep ${queryport}|grep tcp|awk '{ print $2 }')\t$(ss -tupl|grep ${queryport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Query:\tN/A"
fi

if [ -v clientport ]; then
	echo -e "Client:\t${clientport}\t$(ss -tupl|grep ${clientport}|wc -l)\t$(ss -tupl|grep ${clientport}|grep tcp|awk '{ print $2 }')\t$(ss -tupl|grep ${clientport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Client:\tN/A"
fi

if [ -v rconport ]; then
	echo -e "RCON:\t${rconport}\t$(ss -tupl|grep ${rconport}|wc -l)\t$(ss -tupl|grep ${rconport}|grep tcp|awk '{ print $2 }')\t$(ss -tupl|grep ${rconport}|grep udp|awk '{ print $2 }')"
else
	echo -e "RCON:\tN/A"
fi

if [ -v httpport ]; then
	echo -e "HTTP:\t${httpport}\t$(ss -tupl|grep ${httpport}|wc -l)\t$(ss -tupl|grep ${httpport}|grep tcp|awk '{ print $2 }')\t$(ss -tupl|grep ${httpport}|grep udp|awk '{ print $2 }')"
else
	echo -e "HTTP:\tN/A"
fi

if [ -v steamport ]; then
	echo -e "Steam:\t${steamport}\t$(ss -tupl|grep ${steamport}|wc -l)\t$(ss -tupl|grep ${steamport}|grep tcp|awk '{ print $2 }')\t$(ss -tupl|grep ${steamport}|grep udp|awk '{ print $2 }')"
else
	echo -e "HTTP:\tN/A"
fi

} | column -s $'\t' -t
echo -e ""
echo -e "${lightgreen}Query Port - Raw Output${default}"
echo -e "=================================================================="

echo -e "================================="
echo -e "${lightgreen}Ports${default}"
echo -e "================================="
echo -e ""
echo -e "PORT: ${port}"
echo -e "QUERY PORT: ${queryport}"
echo -e ""
echo -e "${lightgreen}Gamedig Raw Output${default}"
echo -e "================================="
echo -e ""
if [ ! "$(command -v gamedig 2>/dev/null)" ]; then
	fn_print_failure_nl "gamedig not installed"
fi
if [ ! "$(command -v jq 2>/dev/null)" ]; then
	fn_print_failure_nl "jq not installed"
fi
for queryip in "${queryips[@]}"; do
	query_gamedig.sh
	echo -e "${gamedigcmd}"
	echo""
	echo "${gamedigraw}" | jq
done
echo -e ""
echo -e "${lightgreen}gsquery Raw Output${default}"
echo -e "================================="
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "./query_gsquery.py -a \"${queryip}\" -p \"${queryport}\" -e \"${querytype}\""
	echo -e ""
	if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
		fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nohash"
	fi
	"${functionsdir}"/query_gsquery.py -a "${queryip}" -p "${queryport}" -e "${querytype}"
done
echo -e ""
echo -e "${lightgreen}TCP Raw Output${default}"
echo -e "================================="
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "bash -c 'exec 3<> /dev/tcp/'${queryip}'/'${queryport}''"
	echo -e ""
	timeout 3 bash -c 'exec 3<> /dev/tcp/'${queryip}'/'${queryport}''
	querystatus="$?"
	echo -e ""
	if [ "${querystatus}" == "0" ]; then
		echo -e "TCP query PASS"
	else
		echo -e "TCP query FAIL"
	fi
done
echo -e ""
echo -e "${lightgreen}Game Port - Raw Output${default}"
echo -e "=================================================================="
echo -e ""
echo -e "${lightgreen}TCP Raw Output${default}"
echo -e "================================="
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "bash -c 'exec 3<> /dev/tcp/'${queryip}'/'${port}''"
	echo -e ""
	timeout 3 bash -c 'exec 3<> /dev/tcp/'${queryip}'/'${port}''
	querystatus="$?"
	echo -e ""
	if [ "${querystatus}" == "0" ]; then
		echo -e "TCP query PASS"
	else
		echo -e "TCP query FAIL"
	fi
done
echo -e ""
echo -e "${lightgreen}Steam Master Server Response${default}"
echo -e "=================================================================="
echo -e ""

echo -e ""
echo -e "${lightgreen}ss Details${default}"
echo -e "=================================================================="
echo -e ""

exitcode=0
core_exit.sh
