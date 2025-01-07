#!/bin/bash
# LinuxGSM command_dev_query_raw.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Raw gamedig output of the server.

commandname="DEV-QUERY-RAW"
commandaction="Developer Query Raw"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_header

check.sh
info_game.sh
info_distro.sh
info_messages.sh

echo -e ""
echo -e "${lightgreen}IP Addresses Variables${default}"
fn_messages_separator
echo -e ""
echo -e "IP: ${ip}"
echo -e "HTTP IP: ${httpip}"
echo -e "Public IP: ${publicip}"
echo -e "Telnet IP: ${telnetip}"
echo -e "Display IP: ${displayip}"

echo -e ""
echo -e "${bold}${lightyellow}Query IP Addresses${default}"
fn_messages_separator
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "${queryip}"
done
echo -e ""
echo -e "${bold}${lightyellow}Game Server Ports${default}"
fn_messages_separator
{
	echo -e "${lightblue}Port Name \tPort Number \tStatus \tTCP \tUDP${default}"
	if [ -n "${port}" ]; then
		echo -e "Game: \t${port} \t$(ss -tupl | grep -c "${port}") \t$(ss -tupl | grep "${port}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${port}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Game:"
	fi
	if [ "${shortname}" == "pvr" ]; then
		if [ -n "${port401}" ]; then
			echo -e "Game+400: \t${port401} \t$(ss -tupl | grep -c "${port401}") \t$(ss -tupl | grep "${port401}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${port401}" | grep udp | awk '{ print $2 }')"
		else
			echo -e "Game+400:"
		fi
	fi

	if [ "${shortname}" == "mcb" ]; then
		if [ -n "${portipv6}" ]; then
			echo -e "Game ipv6: \t${portipv6} \t$(ss -tupl | grep -c "${portipv6}") \t$(ss -tupl | grep "${portipv6}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${portipv6}" | grep udp | awk '{ print $2 }')"
		else
			echo -e "Game ipv6:"
		fi
	fi

	if [ -n "${queryport}" ]; then
		echo -e "Query: \t${queryport} \t$(ss -tupl | grep -c "${queryport}") \t$(ss -tupl | grep "${queryport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${queryport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Query:"
	fi

	if [ -n "${apiport}" ]; then
		echo -e "Game: \t${apiport} \t$(ss -tupl | grep -c "${apiport}") \t$(ss -tupl | grep "${apiport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${apiport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "API:"
	fi

	if [ -n "${appport}" ]; then
		echo -e "App: \t${appport} \t$(ss -tupl | grep -c "${appport}") \t$(ss -tupl | grep "${appport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${appport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "App:"
	fi

	if [ -n "${battleeyeport}" ]; then
		echo -e "BattleEye: \t${battleeyeport} \t$(ss -tupl | grep -c "${battleeyeport}") \t$(ss -tupl | grep "${battleeyeport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${battleeyeport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "BattleEye:"
	fi

	if [ -n "${beaconport}" ]; then
		echo -e "Beacon: \t${beaconport} \t$(ss -tupl | grep -c "${beaconport}") \t$(ss -tupl | grep "${beaconport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${beaconport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Beacon:"
	fi

	if [ -n "${clientport}" ]; then
		echo -e "Client: \t${clientport} \t$(ss -tupl | grep -c "${clientport}") \t$(ss -tupl | grep "${clientport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${clientport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Client:"
	fi

	if [ -n "${fileport}" ]; then
		echo -e "File: \t${fileport} \t$(ss -tupl | grep -c "${fileport}") \t$(ss -tupl | grep "${fileport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${fileport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "File:"
	fi

	if [ -n "${httpport}" ]; then
		echo -e "HTTP: \t${httpport} \t$(ss -tupl | grep -c "${httpport}") \t$(ss -tupl | grep "${httpport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${httpport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "HTTP:"
	fi

	if [ -n "${httpqueryport}" ]; then
		echo -e "HTTP Query: \t${httpqueryport} \t$(ss -tupl | grep -c "${httpqueryport}") \t$(ss -tupl | grep" ${httpqueryport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${httpqueryport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "HTTP Query:"
	fi

	if [ -n "${httpport}" ]; then
		echo -e "Web Interface: \t${httpport} \t$(ss -tupl | grep -c "${httpport}") \t$(ss -tupl | grep "${httpport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${httpport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Web Interface:"
	fi

	if [ -n "${masterport}" ]; then
		echo -e "Game: Master: \t${masterport} \t$(ss -tupl | grep -c "${masterport}") \t$(ss -tupl | grep "${masterport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${masterport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Game: Master:"
	fi

	if [ -n "${rawport}" ]; then
		echo -e "RAW UDP Socket: \t${rawport} \t$(ss -tupl | grep -c "${rawport}") \t$(ss -tupl | grep "${rawport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${rawport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "RAW UDP Socket:"
	fi

	if [ -n "${rconport}" ]; then
		echo -e "RCON: \t${rconport} \t$(ss -tupl | grep -c "${rconport}") \t$(ss -tupl | grep "${rconport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${rconport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "RCON:"
	fi

	if [ -n "${steamport}" ]; then
		echo -e "Steam: \t${steamport} \t$(ss -tupl | grep -c "${steamport}") \t$(ss -tupl | grep "${steamport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${steamport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Steam:"
	fi

	if [ -n "${steamworksport}" ]; then
		echo -e "Steamworks P2P: \t${steamworksport} \t$(ss -tupl | grep -c "${steamworksport}") \t$(ss -tupl | grep "${steamworksport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${steamworksport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Steamworks P2P:"
	fi

	if [ -n "${steamauthport}" ]; then
		echo -e "Steam: Auth: \t${steamauthport} \t$(ss -tupl | grep -c "${steamauthport}") \t$(ss -tupl | grep "${steamauthport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${steamauthport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Steam: Auth:"
	fi

	if [ -n "${telnetport}" ]; then
		echo -e "Telnet: \t${telnetport} \t$(ss -tupl | grep -c "${telnetport}") \t$(ss -tupl | grep "${telnetport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${telnetport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Telnet:"
	fi

	if [ -n "${statsport}" ]; then
		echo -e "Stats: \t${battleeyeport} \t$(ss -tupl | grep -c "${statsport}") \t$(ss -tupl | grep "${statsport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${statsport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Stats:"
	fi

	if [ -n "${sourcetvport}" ]; then
		echo -e "SourceTV: \t${sourcetvport} \t$(ss -tupl | grep -c "${sourcetvport}") \t$(ss -tupl | grep "${sourcetvport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${sourcetvport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "SourceTV:"
	fi

	if [ -n "${udplinkport}" ]; then
		echo -e "UDP Link: \t${udplinkport} \t$(ss -tupl | grep -c "${udplinkport}") \t$(ss -tupl | grep "${udplinkport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${udplinkport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "UDP Link:"
	fi

	if [ -n "${voiceport}" ]; then
		echo -e "Voice: \t${voiceport} \t$(ss -tupl | grep -c "${voiceport}") \t$(ss -tupl | grep "${voiceport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${voiceport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Voice:"
	fi

	if [ -n "${voiceunusedport}" ]; then
		echo -e "Voice (Unused): \t${voiceunusedport} \t$(ss -tupl | grep -c "${voiceunusedport}") \t$(ss -tupl | grep "${voiceunusedport}" | grep tcp | awk '{ print $2 }') \t$(ss -tupl | grep "${voiceunusedport}" | grep udp | awk '{ print $2 }')"
	else
		echo -e "Voice (Unused):"
	fi

} \
	| column -s $'\t' -t

echo -e ""
echo -e "${bold}${lightyellow}SS Output${default}"
fn_messages_separator
fn_info_messages_ports
eval "${portcommand}"

echo -e ""
echo -e "${bold}${lightyellow}Query Port (${queryport}) - Gamedig Output${default}"
fn_messages_separator
echo -e ""
echo -e "PORT: ${port}"
echo -e "QUERY PORT: ${queryport}"
echo -e ""
echo -e "${lightgreen}Is My Game Server Online?${default}"
fn_messages_separator
echo -e "Game server status: https://ismygameserver.online/${imgsoquerytype}/${queryip}:${queryport}"
echo -e ""
echo -e "${lightgreen}Gamedig Raw Output${default}"
fn_messages_separator
echo -e ""
if [ ! "$(command -v gamedig 2> /dev/null)" ] && [ ! -f "${lgsmdir}/node_modules/gamedig/bin/gamedig.js" ]; then
	fn_print_failure_nl "gamedig not installed"
fi
for queryip in "${queryips[@]}"; do
	query_gamedig.sh
	echo -e "${italic}${gamedigcmd}${default}"
	echo""
	echo "${gamedigraw}" | jq
done

echo -e ""
echo -e "${bold}${lightyellow}Query Port (${queryport}) - gsquery Output${default}"
fn_messages_separator
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "${italic}./query_gsquery.py -a \"${queryip}\" -p \"${queryport}\" -e \"${querytype}\"${default}"
	echo -e ""
	if [ ! -f "${modulesdir}/query_gsquery.py" ]; then
		fn_fetch_file_github "lgsm/modules" "query_gsquery.py" "${modulesdir}" "chmodx" "norun" "noforce" "nohash"
	fi
	"${modulesdir}"/query_gsquery.py -a "${queryip}" -p "${queryport}" -e "${querytype}"
done

echo -e ""
echo -e "${bold}${lightyellow}Query Port (${queryport}) - TCP Output${default}"
fn_messages_separator
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "${italic}bash -c 'exec 3<> /dev/tcp/'${queryip}'/'${queryport}''${default}"
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
echo -e "${bold}${lightyellow}Game Port (${port}) - TCP Output${default}"
fn_messages_separator
echo -e ""
echo -e "${lightgreen}TCP Raw Output${default}"
fn_messages_separator
echo -e ""
for queryip in "${queryips[@]}"; do
	echo -e "${italic}bash -c 'exec 3<> /dev/tcp/'${queryip}'/'${port}''${default}"
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
echo -e "${bold}${lightyellow}Steam Master Server Response${default}"
fn_messages_separator
echo -e ""
echo -e "${italic}curl -m 3 -s https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=${publicip}${default}"
echo -e ""
echo -e "Response: ${displaymasterserver}"
echo -e ""

exitcode=0
core_exit.sh
