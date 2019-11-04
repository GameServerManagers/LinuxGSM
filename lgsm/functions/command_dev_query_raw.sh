#!/bin/bash
# command_dev_query_raw.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Raw gamedig output of the server.

local commandname="QUERY-RAW"
local commandaction="Query Raw"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
echo -e ""
echo -e "Query Port"
echo -e "=================================================================="
echo -e ""
echo -e "Gamedig Raw Output"
echo -e "================================="
echo""
if [ ! "$(command -v gamedig 2>/dev/null)" ]; then
	fn_print_failure_nl "gamedig not installed"
fi
if [ ! "$(command -v jq 2>/dev/null)" ]; then
	fn_print_failure_nl "jq not installed"
fi

check.sh
info_config.sh
info_parms.sh
if [ "${engine}" == "idtech3_ql" ]; then
	local engine="quakelive"
elif [ "${shortname}" == "kf2" ]; then
	local engine="unreal4"
fi

query_gamedig.sh
echo -e "${gamedigcmd}"
echo""
echo -e "${gamedigraw}" | jq
echo""
echo -e "gsquery Raw Output"
echo -e "================================="
echo""
echo -e "./query_gsquery.py -a \"${ip}\" -p \"${queryport}\" -e \"${engine}\""
if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
	fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
fi
"${functionsdir}"/query_gsquery.py -a "${ip}" -p "${queryport}" -e "${engine}"

echo""
echo -e "TCP Raw Output"
echo -e "================================="
echo""
echo -e "bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}''"
bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo -e "TCP query PASS"
else
	echo -e "TCP query FAIL"
fi

echo""
echo -e "UDP Raw Output"
echo -e "================================="
echo""
echo -e "bash -c 'exec 3<> /dev/udp/'${ip}'/'${queryport}''"
bash -c 'exec 3<> /dev/udp/'${ip}'/'${queryport}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo -e "UPD query PASS"
else
	echo -e "UPD query FAIL"
fi
echo -e ""
echo -e "Game Port"
echo -e "=================================================================="
echo -e ""
echo""
echo -e "TCP Raw Output"
echo -e "================================="
echo""
echo -e "bash -c 'exec 3<> /dev/tcp/'${ip}'/'${port}''"
bash -c 'exec 3<> /dev/tcp/'${ip}'/'${port}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo -e "TCP query PASS"
else
	echo -e "TCP query FAIL"
fi

echo""
echo -e "UDP Raw Output"
echo -e "================================="
echo""
echo -e "bash -c 'exec 3<> /dev/udp/'${ip}'/'${port}''"
bash -c 'exec 3<> /dev/udp/'${ip}'/'${port}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo -e "UDP query PASS"
else
	echo -e "UDP query FAIL"
fi
