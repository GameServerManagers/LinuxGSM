#!/bin/bash
# LGSM monitor_gsquery.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: uses gsquery.py to directly query the server.
# Detects if the server has frozen.

local modulename="Monitor"
if [ -f "${rootdir}/gsquery.py" ]; then
	if [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
		gameport=$(grep Port= "${servercfgfullpath}"|grep -v Master|grep -v LAN|grep -v Proxy|grep -v Listen|tr -d '\r'|tr -cd '[:digit:]')
		port=$((${gameport} + 1))
	elif [ "${engine}" == "spark" ]; then
		port=$((${port} + 1))
	elif [ "${engine}" == "realvirtuality" ]; then
		queryport=$(grep -s steamqueryport= "${servercfgfullpath}"|grep -v //|tr -d '\r'|tr -cd '[:digit:]')
		port=${queryport}
	elif [ "${gamename}" == "7 Days To Die" ]; then
		gameport=$(grep ServerPort "${servercfgfullpath}"|tr -cd '[:digit:]')
		port=$((${gameport} + 1))
	elif [ "${gamename}" == "Hurtworld" ]; then
		gameport="${port}"
		port="${queryport}"
	fi
	fn_printinfo "Detected gsquery.py"
	fn_scriptlog "Detected gsquery.py"
	sleep 1
	fn_printdots "Querying port: ${ip}:${port} : QUERYING"
	fn_scriptlog "Querying port: ${ip}:${port} : QUERYING"
	sleep 1
	serverquery=$("${rootdir}/gsquery.py" -a ${ip} -p ${port} -e ${engine} 2>&1)
	exitcode=$?
	if [ "${exitcode}" == "1" ]||[ "${exitcode}" == "2" ]||[ "${exitcode}" == "3" ]||[ "${exitcode}" == "4" ]; then
		fn_printfail "Querying port: ${ip}:${port} : ${serverquery}"
		fn_scriptlog "Querying port: ${ip}:${port} : ${serverquery}"
		sleep 1
		echo -en "\n"
		if [ -z "${secondquery}" ]; then
			if [ "${engine}" == "unreal2" ]; then
				# unreal 2: Map change can take around 60 seconds
				fn_printinfo "Waiting 60 seconds to re-query"
				fn_scriptlog "Waiting 60 seconds to re-query"
				sleep 60
			else
				fn_printinfo "Waiting 30 seconds to re-query"
				fn_scriptlog "Waiting 30 seconds to re-query"
				sleep 30
			fi
			secondquery=1
			monitor_gsquery.sh
		fi
		if [ "${emailnotification}" = "on" ]; then
			info_config.sh
			subject="${servicename} Monitor - Starting ${servername}"
			failurereason="Failed to query ${servicename}: ${serverquery}"
			actiontaken="restarted ${servicename}"
			email.sh
		fi
		fn_restart
		exit 1
	elif [ "${exitcode}" == "0" ]; then
		fn_printok "Querying port: ${ip}:${port} : OK"
		fn_scriptlog "Querying port: ${ip}:${port} : OK"
		sleep 1
		echo -en "\n"
		exit
	elif [ "${exitcode}" == "126" ]; then
		fn_printfail "Querying port: ${ip}:${port} : ERROR: ${rootdir}/gsquery.py: Permission denied"
		fn_scriptlog "Querying port: ${ip}:${port} : ERROR: ${rootdir}/gsquery.py: Permission denied"
		sleep 1
		echo -en "\n"
		echo "Attempting to resolve automatically"
		chmod +x -v "${rootdir}/gsquery.py"
		if [ $? -eq 0 ]; then
			monitor_gsquery.sh
		else
			fn_printfailure "Unable to resolve automatically. Please manually fix permissions.\n"
			owner=$(ls -al ${rootdir}/gsquery.py|awk '{ print $3 }')
			echo "As user ${owner} or root run the following command."
			whoami=$(whoami)
			echo -en "\nchown ${whoami}:${whoami} ${rootdir}/gsquery.py\n\n"
		exit 1
		fi
	else
		fn_printfail "Querying port: ${ip}:${port} : UNKNOWN ERROR"
		fn_scriptlog "Querying port: ${ip}:${port} : UNKNOWN ERROR"
		sleep 1
		echo -en "\n"
		${rootdir}/gsquery.py -a ${ip} -p ${port} -e ${engine}
		exit 1
	fi
else
	fn_printfailnl "Could not find ${rootdir}/gsquery.py"
	fn_scriptlog "Could not find ${rootdir}/gsquery.py"
fi
