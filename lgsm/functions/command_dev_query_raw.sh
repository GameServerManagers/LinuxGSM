#!/bin/bash
# command_dev_query_raw.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Raw gamedig output of the server.

local modulename="QUERY-RAW"
local commandaction="Query Raw"
local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

echo -e ""
echo -e "Query Port - Raw Output"
echo -e "=================================================================="
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

check.sh
info_config.sh
info_parms.sh

query_gamedig.sh
echo -e "${gamedigcmd}"
echo""
echo -e "${gamedigraw}" | jq

echo -e ""
echo -e "gsquery Raw Output"
echo -e "================================="
echo -e ""
echo -e "./query_gsquery.py -a \"${ip}\" -p \"${queryport}\" -e \"${querytype}\""
echo -e ""
if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
	fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
fi
"${functionsdir}"/query_gsquery.py -a "${ip}" -p "${queryport}" -e "${querytype}"

echo -e ""
echo -e "TCP Raw Output"
echo -e "================================="
echo -e ""
echo -e "bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}''"
echo -e ""
bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}''
querystatus="$?"
echo -e ""
if [ "${querystatus}" == "0" ]; then
	echo -e "TCP query PASS"
else
	echo -e "TCP query FAIL"
fi

echo -e ""
echo -e "Game Port - Raw Output"
echo -e "=================================================================="
echo -e ""
echo -e "TCP Raw Output"
echo -e "================================="
echo -e ""
echo -e "bash -c 'exec 3<> /dev/tcp/'${ip}'/'${port}''"
echo -e ""
bash -c 'exec 3<> /dev/tcp/'${ip}'/'${port}''
querystatus="$?"
echo -e ""
if [ "${querystatus}" == "0" ]; then
	echo -e "TCP query PASS"
else
	echo -e "TCP query FAIL"
fi

core_exit.sh
