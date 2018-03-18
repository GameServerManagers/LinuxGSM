#!/bin/bash
# LinuxGSM monitor_gsquery.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Uses gsquery.py to query the server port.
# Detects if the server has frozen with the process still running.

local commandname="MONITOR"
local commandaction="Monitor"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Downloads gsquery.py if missing
if [ ! -f "${functionsdir}/gsquery.py" ]; then
	fn_fetch_file_github "lgsm/functions" "gsquery.py" "${functionsdir}" "chmodx" "norun" "noforce" "nomd5"
fi

info_config.sh

if [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	port=$((port + 1))
elif [ "${engine}" == "realvirtuality" ]; then
	port=$((port + 1))
elif [ "${engine}" == "spark" ]; then
	port=$((port + 1))
elif [ "${engine}" == "idtech3_ql" ]; then
	engine="quakelive"
fi

if [ -n "${queryport}" ]; then
	port="${queryport}"
fi

fn_print_info "Querying port: gsquery.py enabled"
fn_script_log_info "Querying port: gsquery.py enabled"
sleep 1

# Will query up to 4 times every 15 seconds.
# Servers changing map can return a failure.
# Will Wait up to 60 seconds to confirm server is down giving server time to change map.
totalseconds=0
for queryattempt in {1..5}; do
	fn_print_dots "Querying port: ${ip}:${port} : ${totalseconds}/${queryattempt} : "
	fn_print_querying_eol
	fn_script_log_info "Querying port: ${ip}:${port} : ${queryattempt} : QUERYING"

	gsquerycmd=$("${functionsdir}"/gsquery.py -a "${ip}" -p "${port}" -e "${engine}" 2>&1)
	exitcode=$?

	sleep 1
	if [ "${exitcode}" == "0" ]; then
		# Server OK
		fn_print_ok "Querying port: ${ip}:${port} : ${queryattempt} : "
		fn_print_ok_eol_nl
		fn_script_log_pass "Querying port: ${ip}:${port} : ${queryattempt} : OK"
		exitcode=0
		break
	else
		# Server failed query
		fn_script_log_info "Querying port: ${ip}:${port} : ${queryattempt} : ${gsquerycmd}"

		if [ "${queryattempt}" == "5" ]; then
			# Server failed query 4 times confirmed failure
			fn_print_fail "Querying port: ${ip}:${port} : ${totalseconds}/${queryattempt} : "
			fn_print_fail_eol_nl
			fn_script_log_error "Querying port: ${ip}:${port} : ${queryattempt} : FAIL"
			sleep 1

			# Send alert if enabled
			alert="restartquery"
			alert.sh
			command_restart.sh
			break
		fi

		# Seconds counter
		for seconds in {1..15}; do
			fn_print_fail "Querying port: ${ip}:${port} : ${totalseconds}/${queryattempt} : ${red}${gsquerycmd}${default}"
			totalseconds=$((totalseconds + 1))
			sleep 1
			if [ "${seconds}" == "15" ]; then
				break
			fi
		done
	fi
done
core_exit.sh