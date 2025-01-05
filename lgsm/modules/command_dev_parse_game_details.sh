#!/bin/bash
# LinuxGSM command_dev_parse_game_details.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Display parsed gameserver details.

commandname="DEV-PARSE-GAME-DETAILS"
commandaction="Parse Game Details"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_header

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
echo -e "${lightblue}Game: ${default}${gamename}"
echo -e "${lightblue}Config type: ${default}${configtype}"
echo -e "${lightblue}Config file: ${default}${servercfgfullpath}"
if [ -f "${clustercfgfullpath}" ]; then
	echo -e "${lightblue}Cluster config file: ${default}${clustercfgfullpath}"
fi
echo -e "${lightblue}Carriage Return: ${default}${carriagereturn}"

# Create an associative array of the server details.
declare -A server_details=(
	['Admin Password']="${adminpassword}"
	['Alert IP']="${alertip}"
	['API Port']="${apiport}"
	['App Port']="${appport}"
	['ASE']="${ase}"
	['Auth Token']="${authtoken}"
	['BattleEye Port']="${battleeyeport}"
	['Beacon Port']="${beaconport}"
	['Cave']="${cave}"
	['Client Port']="${clientport}"
	['Cluster']="${cluster}"
	['Config IP']="${configip}"
	['Creative Mode']="${creativemode}"
	['Custom Level URL']="${customlevelurl}"
	['DB Plugin']="${dbplugin}"
	['Default Map']="${defaultmap}"
	['Default Scenario']="${defaultscenario}"
	['Display Master Server']="${displaymasterserver}"
	['Epic Settings']="${epicsettings}"
	['File Port']="${fileport}"
	['Files Port']="${filesport}"
	['Game Mode']="${gamemode}"
	['Game Type']="${gametype}"
	['Home Kingdom']="${homekingdom}"
	['Home Server']="${homeserver}"
	['HTTP Enabled']="${httpenabled}"
	['HTTP IP']="${httpip}"
	['HTTP Password']="${httppassword}"
	['HTTP Port']="${httpport}"
	['HTTP User']="${httpuser}"
	['Internet IP']="${publicip}"
	['LAN Port']="${lanport}"
	['Login Server']="${loginserver}"
	['Master Port']="${masterport}"
	['Master Server']="${masterserver}"
	['Master']="${master}"
	['Max Players']="${maxplayers}"
	['Mod Server Port']="${modserverport}"
	['OldQueryPortNumber']="${oldqueryportnumber}"
	['Port 401']="${port401}"
	['Port IPv6']="${portipv6}"
	['Port']="${port}"
	['Query Enabled']="${queryenabled}"
	['Query HTTP Port']="${httpqueryport}"
	['Query HTTPS Port']="${httpsqueryport}"
	['Query Mode']="${querymode}"
	['Query Port GS']="${gamespyqueryport}"
	['Query Port']="${queryport}"
	['Query SSH Port']="${sshqueryport}"
	['Queue Enabled']="${queueenabled}"
	['Queue Port']="${queueport}"
	['Random Map']="${randommap}"
	['Raw Port']="${rawport}"
	['RCON Enabled']="${rconenabled}"
	['RCON Password']="${rconpassword}"
	['RCON Port']="${rconport}"
	['RCON Web']="${rconweb}"
	['Reserved Slots']="${reservedslots}"
	['RMI Port']="${rmiport}"
	['RMI Reg Port']="${rmiregport}"
	['Salt']="${salt}"
	['Save Game Interval']="${savegameinterval}"
	['Save Interval']="${saveinterval}"
	['Secondary Port']="${port3}"
	['Seed']="${seed}"
	['Server Description']="${serverdescription}"
	['Server IP']="${ip}"
	['Server Level']="${serverlevel}"
	['Server Name']="${servername}"
	['Server Password Enabled']="${serverpasswordenabled}"
	['Server Password']="${serverpassword}"
	['Server Version']="${serverversion}"
	['Shard']="${shard}"
	['Sharding']="${sharding}"
	['Shutdown Port']="${shutdownport}"
	['Stats Port']="${statsport}"
	['Steam Auth Port']="${steamauthport}"
	['Steam Port']="${steamport}"
	['Steamworks Port']="${steamworksport}"
	['Telnet Enabled']="${telnetenabled}"
	['Telnet IP']="${telnetip}"
	['Telnet Password']="${telnetpassword}"
	['Telnet Port']="${telnetport}"
	['Tickrate']="${tickrate}"
	['Unknown Port']="${unknownport}"
	['Version Count']="${versioncount}"
	['Voice Port']="${voiceport}"
	['Voice Unused Port']="${voiceunusedport}"
	['World Name']="${worldname}"
	['World Size']="${worldsize}"
	['World Type']="${worldtype}"
)

# Initialize variables to keep track of available and missing server details.
available_details=""
missing_details=""

# Loop through the server details and store them.
for key in "${!server_details[@]}"; do
	value=${server_details[$key]}
	if [ -n "$value" ]; then
		available_details+="${lightblue}${key}: ${default}${value}\n"
	else
		missing_details+="${key}\n"
	fi
done

# Sort and output the available distro details.
if [ -n "$available_details" ]; then
	echo -e ""
	echo -e "${bold}${lightgreen}Available Gameserver Details${default}"
	fn_messages_separator
	echo -e "${available_details}" | sort
fi

# Output the missing server details if there are any.
if [ -n "$missing_details" ]; then
	echo -e ""
	echo -e "${lightgreen}Missing or unsupported Gameserver Details${default}"
	fn_messages_separator
	echo -e "${missing_details}" | sort
fi

core_exit.sh
