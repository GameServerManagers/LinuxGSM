#!/bin/bash
# command_dev_query_raw.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Raw gamedig output of the server.

local commandname="QUERY-RAW"
local commandaction="Query Raw"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
echo ""
echo "Query Port"
echo "=================================================================="
echo ""
echo "Gamedig Raw Output"
echo "================================="
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
echo "${gamedigcmd}"
echo""
echo "${gamedigraw}" | jq
echo""
echo "gsquery Raw Output"
echo "================================="
echo""
echo "./query_gsquery.py -a \"${ip}\" -p \"${queryport}\" -e \"${engine}\""
if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
	fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
fi
"${functionsdir}"/query_gsquery.py -a "${ip}" -p "${queryport}" -e "${engine}"

echo""
echo "TCP Raw Output"
echo "================================="
echo""
echo "bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}''"
bash -c 'exec 3<> /dev/tcp/'${ip}'/'${queryport}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo "TCP query PASS"
else
	echo "TCP query FAIL"
fi

echo""
echo "UDP Raw Output"
echo "================================="
echo""
echo "bash -c 'exec 3<> /dev/udp/'${ip}'/'${queryport}''"
bash -c 'exec 3<> /dev/udp/'${ip}'/'${queryport}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo "UPD query PASS"
else
	echo "UPD query FAIL"
fi
echo ""
echo "Game Port"
echo "=================================================================="
echo ""
echo""
echo "TCP Raw Output"
echo "================================="
echo""
echo "bash -c 'exec 3<> /dev/tcp/'${ip}'/'${port}''"
bash -c 'exec 3<> /dev/tcp/'${ip}'/'${port}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo "TCP query PASS"
else
	echo "TCP query FAIL"
fi

echo""
echo "UDP Raw Output"
echo "================================="
echo""
echo "bash -c 'exec 3<> /dev/udp/'${ip}'/'${port}''"
bash -c 'exec 3<> /dev/udp/'${ip}'/'${port}''
querystatus="$?"
if [ "${querystatus}" == "0" ]; then
	echo "UDP query PASS"
else
	echo "UDP query FAIL"
fi
