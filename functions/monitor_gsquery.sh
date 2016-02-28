#!/bin/bash
# LGSM monitor_gsquery.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: uses gsquery.py to query the server port.
# Detects if the server has frozen with the proccess still running.

local modulename="Monitor"

# Downloads gsquery.py if missing
if [ ! -f "${functionsdir}/gsquery.py" ]; then
	fn_fetch_file_github "functions" "gsquery.py" "${functionsdir}" "executecmd" "norun" "noforce" "nomd5"
fi	

info_config.sh

if [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	port=$((${port} + 1))
elif [ "${engine}" == "spark" ]; then
	port=$((${port} + 1))
fi

if [ -z "${queryport}" ]; then
	port="${queryport}"
fi


fn_print_info "Querying port: gsquery.py enabled"
fn_scriptlog "gsquery.py enabled"
sleep 1
fn_print_dots "Querying port: ${ip}:${port}: 0/1 : "
fn_print_querying_eol
fn_scriptlog "Querying port: ${ip}:${port}: 1 : QUERYING"
sleep 1


# Will query up to 4 times every 15 seconds.
# Servers changing map can return a failure.
# Will Wait up to 60 seconds to confirm server is down giving server time to change map.
queryattempt=0
totalseconds=0
for i in {1..4}; do
	gsquerycmd=$("${functionsdir}"/gsquery.py -a ${ip} -p 1 -e ${engine} 2>&1)
	exitcode=$?

	if [ "${exitcode}" == "0" ]; then
		# Server OK
		fn_print_ok "Querying port: ${ip}:${port}: "
		fn_print_ok_eol
		fn_scriptlog "Querying port: ${ip}:${port}: OK"
		sleep 1
		exit
	else
		# Server failed query
		queryattempt=$((queryattempt + 1))
		fn_scriptlog "Querying port: ${ip}:${port}: ${totalseconds}/${queryattempt} : ${gsquerycmd}"
		seconds=0
		# Seconds counter
		while [ true ]; do
		    fn_print_fail "Querying port: ${ip}:${port}: ${totalseconds}/${queryattempt} : \e[0;31m${gsquerycmd}\e[0m"
		    seconds=$((seconds + 1))
		    totalseconds=$((totalseconds + 1))
		    sleep 1
		    if [ "${seconds}" == "15" ]; then
		    	fn_print_dots "Querying port: ${ip}:${port}: ${totalseconds}/${queryattempt} : "
		    	fn_print_querying_eol
				fn_scriptlog "Querying port: ${ip}:${port}: ${queryattempt} : QUERYING"
				sleep 1
		    	break
		    fi
		done
	fi

	if [ "${queryattempt}" == "4" ]; then
		# Server failed query 4 times confirmed failure
		fn_print_fail "Querying port: ${ip}:${port}: "
		fn_print_fail_eol
		fn_scriptlog "Querying port: ${ip}:${port}: ${gsquerycmd}"
		fn_scriptlog "Querying port: ${ip}:${port}: FAIL"
		sleep 1

		# Send email notification if enabled
		if [ "${emailnotification}" = "on" ]; then
			info_config.sh
			subject="${servicename} Monitor - Starting ${servername}"
			failurereason="Failed to query ${servicename}: ${gsquerycmd}"
			actiontaken="restarted ${servicename}"
			email.sh
		fi
		fn_restart
	fi	
done