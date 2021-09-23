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
info_game.sh
info_distro.sh
info_messages.sh

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
echo -e "${lightblue}Port Name \tPort Number \tStatus \tTCP \tUDP${default}"
if [ -v port ]; then
	echo -e "Game: \t${port} \t$(ss -tupl|grep ${port}|wc -l) \t$(ss -tupl|grep ${port}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${port}|grep udp|awk '{ print $2 }')"
else
	echo -e "Game:"
fi
if [ "${shortname}" == "rw" ]; then
	if [ -v port2 ]; then
		echo -e "Game+1: \t${port2} \t$(ss -tupl|grep ${port}|wc -l) \t$(ss -tupl|grep ${port2}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${port2}|grep udp|awk '{ print $2 }')"
	else
		echo -e "Game+1:"
	fi

	if [ -v port3 ]; then
		echo -e "Game+2: \t${port3} \t$(ss -tupl|grep ${port}|wc -l) \t$(ss -tupl|grep ${port3}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${port3}|grep udp|awk '{ print $2 }')"
	else
		echo -e "Game+2:"
	fi

	if [ -v port4 ]; then
		echo -e "Game+3: \t${port4} \t$(ss -tupl|grep ${port}|wc -l) \t$(ss -tupl|grep ${port4}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${port4}|grep udp|awk '{ print $2 }')"
	else
		echo -e "Game+3:"
	fi
fi

if [ -v port401 ]; then
	echo -e "Game+400: \t${port401} \t$(ss -tupl|grep ${port401}|wc -l) \t$(ss -tupl|grep ${port401}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${port401}|grep udp|awk '{ print $2 }')"
else
	echo -e "Game+400:"
fi

if [ -v portipv6 ]; then
	echo -e "Game ipv6: \t${portipv6} \t$(ss -tupl|grep ${portipv6}|wc -l) \t$(ss -tupl|grep ${portipv6}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${portipv6}|grep udp|awk '{ print $2 }')"
else
	echo -e "Game ipv6:"
fi

if [ -v queryport ]; then
	echo -e "Query: \t${queryport} \t$(ss -tupl|grep ${queryport}|wc -l) \t$(ss -tupl|grep ${queryport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${queryport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Query:"
fi

if [ -v httpport ]; then
	echo -e "HTTP: \t${httpport} \t$(ss -tupl|grep ${httpport}|wc -l) \t$(ss -tupl|grep ${httpport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${httpport}|grep udp|awk '{ print $2 }')"
else
	echo -e "HTTP:"
fi

if [ -v httpqueryport ]; then
	echo -e "HTTP Query: \t${httpqueryport} \t$(ss -tupl|grep ${httpqueryport}|wc -l) \t$(ss -tupl|grep ${httpqueryport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${httpqueryport}|grep udp|awk '{ print $2 }')"
else
	echo -e "HTTP Query:"
fi


if [ -v webadminport ]; then
	echo -e "Web Admin: \t${webadminport} \t$(ss -tupl|grep ${webadminport}|wc -l) \t$(ss -tupl|grep ${webadminport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${webadminport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Web Admin:"
fi

if [ -v clientport ]; then
	echo -e "Client: \t${clientport} \t$(ss -tupl|grep ${clientport}|wc -l) \t$(ss -tupl|grep ${clientport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${clientport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Client:"
fi

if [ -v rconport ]; then
	echo -e "RCON: \t${rconport} \t$(ss -tupl|grep ${rconport}|wc -l) \t$(ss -tupl|grep ${rconport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${rconport}|grep udp|awk '{ print $2 }')"
else
	echo -e "RCON:"
fi

if [ -v rawport ]; then
	echo -e "RAW UDP Socket: \t${rawport} \t$(ss -tupl|grep ${rawport}|wc -l) \t$(ss -tupl|grep ${rawport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${rawport}|grep udp|awk '{ print $2 }')"
else
	echo -e "RAW UDP Socket:"
fi

if [ -v masterport ]; then
	echo -e "Game: Master: \t${masterport} \t$(ss -tupl|grep ${masterport}|wc -l) \t$(ss -tupl|grep ${masterport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${masterport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Game: Master:"
fi

if [ -v steamport ]; then
	echo -e "Steam: \t${steamport} \t$(ss -tupl|grep ${steamport}|wc -l) \t$(ss -tupl|grep ${steamport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${steamport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Steam:"
fi

if [ -v steamauthport ]; then
	echo -e "Steam: Auth: \t${steamauthport} \t$(ss -tupl|grep ${steamauthport}|wc -l) \t$(ss -tupl|grep ${steamauthport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${steamauthport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Steam: Auth:"
fi

if [ -v steammasterport ]; then
	echo -e "Steam: Master: \t${steammasterport} \t$(ss -tupl|grep ${steammasterport}|wc -l) \t$(ss -tupl|grep ${steammasterport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${steammasterport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Steam: Master:"
fi

if [ -v steamqueryport ]; then
	echo -e "Steam: Query: \t${steamqueryport} \t$(ss -tupl|grep ${steamqueryport}|wc -l) \t$(ss -tupl|grep ${steamqueryport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${steamqueryport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Steam: Query:"
fi
if [ -v beaconport ]; then
	echo -e "Beacon: \t${beaconport} \t$(ss -tupl|grep ${beaconport}|wc -l) \t$(ss -tupl|grep ${beaconport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${beaconport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Beacon:"
fi

if [ -v appport ]; then
	echo -e "App: \t${appport} \t$(ss -tupl|grep ${appport}|wc -l) \t$(ss -tupl|grep ${appport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${appport}|grep udp|awk '{ print $2 }')"
else
	echo -e "App:"
fi

if [ -v telnetport ]; then
	echo -e "Telnet: \t${telnetport} \t$(ss -tupl|grep ${telnetport}|wc -l) \t$(ss -tupl|grep ${telnetport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${telnetport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Telnet:"
fi

if [ -v sourcetvport ]; then
	echo -e "SourceTV: \t${sourcetvport} \t$(ss -tupl|grep ${sourcetvport}|wc -l) \t$(ss -tupl|grep ${sourcetvport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${sourcetvport}|grep udp|awk '{ print $2 }')"
else
	echo -e "SourceTV:"
fi

if [ -v fileport ]; then
	echo -e "File: \t${fileport} \t$(ss -tupl|grep ${fileport}|wc -l) \t$(ss -tupl|grep ${fileport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${fileport}|grep udp|awk '{ print $2 }')"
else
	echo -e "File:"
fi

if [ -v udplinkport ]; then
	echo -e "UDP Link: \t${udplinkport} \t$(ss -tupl|grep ${udplinkport}|wc -l) \t$(ss -tupl|grep ${udplinkport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${udplinkport}|grep udp|awk '{ print $2 }')"
else
	echo -e "UDP Link:"
fi

if [ -v voiceport ]; then
	echo -e "Voice: \t${voiceport} \t$(ss -tupl|grep ${voiceport}|wc -l) \t$(ss -tupl|grep ${voiceport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${voiceport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Voice:"
fi

if [ -v voiceunusedport ]; then
	echo -e "Voice (Unused): \t${voiceunusedport} \t$(ss -tupl|grep ${voiceunusedport}|wc -l) \t$(ss -tupl|grep ${voiceunusedport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${voiceunusedport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Voice (Unused):"
fi

if [ -v battleeyeport ]; then
	echo -e "BattleEye: \t${battleeyeport} \t$(ss -tupl|grep ${battleeyeport}|wc -l) \t$(ss -tupl|grep ${battleeyeport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${battleeyeport}|grep udp|awk '{ print $2 }')"
else
	echo -e "BattleEye:"
fi

if [ -v statsport ]; then
	echo -e "Stats: \t${battleeyeport} \t$(ss -tupl|grep ${statsport}|wc -l) \t$(ss -tupl|grep ${statsport}|grep tcp|awk '{ print $2 }') \t$(ss -tupl|grep ${statsport}|grep udp|awk '{ print $2 }')"
else
	echo -e "Stats:"
fi

} | column -s $'\t' -t
echo -e ""
echo -e "${lightgreen}SS Output${default}"
echo -e "================================="
fn_info_message_ports
echo -e ""
echo -e "${lightgreen}Query Port - Raw Output${default}"
echo -e "=================================================================="
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
echo -e "Response: ${displaymasterserver}"
echo -e ""

exitcode=0
core_exit.sh
