#!/bin/bash
# LinuxGSM command_dev_debug.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Dev only: Enables debugging log to be saved to dev-debug.log.

if [ -f "config" ]; then
	servercfgfullpath="config"
fi
if [ -f "clusterconfig" ]; then
	clustercfgfullpath="clusterconfig"
fi

info_game.sh

carriagereturn=$(file -b "${servercfgfullpath}" | grep -q CRLF && echo "${red}CRLF${default}" || echo "${lightgreen}LF${default}")

echo -e ""
echo -e "${bold}${lightgreen}Server Details${default}"
fn_messages_separator

echo -e ""
echo -e "Game: ${gamename}"
echo -e "Config type: ${configtype}"
echo -e "Config file: ${servercfgfullpath}"
if [ -f "${clustercfgfullpath}" ]; then
	echo -e "Cluster config file: ${clustercfgfullpath}"
fi
echo -e "Carriage Return: ${carriagereturn}"

# Create an associative array of the server details.
declare -A server_details=(
	['Admin Password']="${adminpassword}"
	['API Port']="${apiport}"
	['Cave']="${cave}"
	['Cluster']="${cluster}"
	['Config IP']="${configip}"
	['Default Map']="${defaultmap}"
	['Game Mode']="${gamemode}"
	['Game Type']="${gametype}"
	['HTTP Enabled']="${httpenabled}"
	['HTTP IP']="${httpip}"
	['HTTP Password']="${httppassword}"
	['HTTP Port']="${httpport}"
	['HTTP User']="${httpuser}"
	['Internet IP']="${publicip}"
	['LAN Port']="${lanport}"
	['Master Port']="${masterport}"
	['Master']="${master}"
	['Maxplayers']="${maxplayers}"
	['OldQueryPortNumber']="${oldqueryportnumber}"
	['Port']="${port}"
	['Query Port']="${queryport}"
	['RCON Enabled']="${rconenabled}"
	['RCON Password']="${rconpassword}"
	['RCON Port']="${rconport}"
	['Reserved Slots']="${reservedslots}"
	['Server IP']="${ip}"
	['Server Password']="${serverpassword}"
	['Servername']="${servername}"
	['Shard']="${shard}"
	['Sharding']="${sharding}"
	['Steam Auth Port']="${steamauthport}"
	['Telnet Enabled']="${telnetenabled}"
	['Telnet IP']="${telnetip}"
	['Telnet Password']="${telnetpassword}"
	['Telnet Port']="${telnetport}"
	['Tickrate']="${tickrate}"
	['World Name']="${worldname}"
	['World Type']="${worldtype}"
)

# Initialize a variable to keep track of missing server details.
missing_details=""

# Loop through the server details and output them.
echo -e ""
echo -e "${bold}${lightgreen}Available Server Details${default}"
fn_messages_separator
for key in "${!server_details[@]}"; do
	value=${server_details[$key]}
	if [ -z "$value" ]; then
		missing_details+="\n${key}"
	else
		echo -e "$key: $value "
	fi
done

# Output the missing server details if there are any.
if [ -n "$missing_details" ]; then
	echo -e ""
	echo -e "${lightgreen}Missing Server Details${default}"
	fn_messages_separator
	echo -e "${missing_details}"
fi

core_exit.sh
