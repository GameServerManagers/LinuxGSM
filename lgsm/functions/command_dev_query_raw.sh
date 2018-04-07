#!/bin/bash
# command_dev_query_raw.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Raw gamedig output of the server.

echo "================================="
echo "Gamedig Raw Output"
echo "================================="
echo""
if [ ! "$(command -v gamedig 2>/dev/null)" ]; then
	fn_print_failure_nl "gamedig not installed"
fi
if [ ! "$(command -v jq >/dev/null 2>&1)" ]; then
	fn_print_failure_nl "jq not installed"
fi


info_config.sh
info_parms.sh
if [ "${engine}" == "idtech3_ql" ]; then
	local engine="quakelive"
elif [ "${gamename}" == "Killing Floor 2" ]; then
	local engine="unreal4"
fi

query_gamedig.sh
echo "gamedig --type \"${gamedigengine}\" --host \"${ip}\" --port \"${port}\"|jq"
echo""
echo "${gamedigraw}" | jq
echo""
echo "================================="
echo "gsquery Raw Output"
echo "================================="
echo""
echo "./query_gsquery.py -a \"${ip}\" -p \"${port}\" -e \"${engine}\""
if [ ! -f "${functionsdir}/query_gsquery.py" ]; then
	fn_fetch_file_github "lgsm/functions" "query_gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
fi
"${functionsdir}"/query_gsquery.py -a "${ip}" -p "${port}" -e "${engine}"