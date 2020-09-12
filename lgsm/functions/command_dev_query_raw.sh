#!/bin/bash
# command_dev_query_raw.sh function
# Author: Daniel Gibbs
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
echo -e "Query Port - Raw Output"
echo -e "=================================================================="
echo -e ""
echo -e "QUERY IP"
for queryip in "${queryips[@]}"; do
	echo -e "${queryip}"
done
echo -e "================================="
echo -e "Ports"
echo -e "================================="
echo -e ""
echo -e "PORT: ${port}"
echo -e "QUERY PORT: ${queryport}"
echo -e ""
echo -e "Gamedig Raw Output"
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
echo -e "gsquery Raw Output"
echo -e "================================="
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "./query_gsquery.py -a \"${queryip}\" -p \"${queryport}\" -e \"${querytype}\""
	echo -e ""
	if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
		fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
	fi
	"${functionsdir}"/query_gsquery.py -a "${queryip}" -p "${queryport}" -e "${querytype}"
done
echo -e ""
echo -e "TCP Raw Output"
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
echo -e "Game Port - Raw Output"
echo -e "=================================================================="
echo -e ""
echo -e "TCP Raw Output"
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
exitcode=0
core_exit.sh
