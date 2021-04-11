#!/bin/bash
# LinuxGSM info_messages.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Defines server info messages for details and alerts.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Separator is different for details.
fn_messages_separator(){
	if [ "${commandname}" == "DETAILS" ]; then
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	else
		echo -e "================================="
	fi
}

# Removes the passwords form all but details.
fn_info_message_password_strip(){
	if [ "${commandname}" != "DETAILS" ]; then
		if [ "${serverpassword}" ]; then
			serverpassword="********"
		fi

		if [ "${rconpassword}" ]; then
			rconpassword="********"
		fi

		if [ "${adminpassword}" ]; then
			adminpassword="********"
		fi

		if [ "${statspassword}" ]; then
			statspassword="********"
		fi

		if [ "${webadminpass}" ]; then
			webadminpass="********"
		fi

		if [ "${telnetpass}" ]; then
			telnetpass="********"
		fi

		if [ "${wsapikey}" ]; then
			wsapikey="********"
		fi

		if [ "${gslt}" ]; then
			gslt="********"
		fi
	fi
}

# Alert Summary
# used with alertlog
fn_info_message_head(){
	echo -e ""
	echo -e "${lightyellow}Alert Summary${default}"
	fn_messages_separator
	echo -e "Message"
	echo -e "${alertbody}"
	echo -e ""
	echo -e "Game"
	echo -e "${gamename}"
	echo -e ""
	echo -e "Server name"
	echo -e "${servername}"
	echo -e ""
	echo -e "Hostname"
	echo -e "${HOSTNAME}"
	echo -e ""
	echo -e "Server IP"
	echo -e "${ip}:${port}"
}

fn_info_message_distro(){
	#
	# Distro Details
	# =================================
	# Date:      Sun 21 Feb 2021 09:22:53 AM UTC
	# Distro:    Ubuntu 20.04.2 LTS
	# Arch:      x86_64
	# Kernel:    5.4.0-65-generic
	# Hostname:  server
	# Uptime:    16d, 5h, 18m
	# tmux:      tmux 3.0a
	# glibc:     2.31

	echo -e ""
	echo -e "${lightyellow}Distro Details${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Date:\t${default}${date}"
		echo -e "${lightblue}Distro:\t${default}${distroname}"
		echo -e "${lightblue}Arch:\t${default}${arch}"
		echo -e "${lightblue}Kernel:\t${default}${kernel}"
		echo -e "${lightblue}Hostname:\t${default}${HOSTNAME}"
		echo -e "${lightblue}Uptime:\t${default}${days}d, ${hours}h, ${minutes}m"
		echo -e "${lightblue}tmux:\t${default}${tmuxv}"
		echo -e "${lightblue}glibc:\t${default}${glibcversion}"
	} | column -s $'\t' -t
}

fn_info_message_server_resource(){
	#
	# Server Resource
	# =================================
	# CPU
	# Model:      AMD EPYC 7601 32-Core Processor
	# Cores:      2
	# Frequency:  2199.994MHz
	# Avg Load:   0.01, 0.05, 0.18
	#
	# Memory
	# Mem:       total  used   free   cached  available
	# Physical:  3.9GB  350MB  3.3GB  3.2GB   3.3GB
	# Swap:      512MB  55MB   458MB
	#
	# Storage
	# Filesystem:  /dev/sda
	# Total:       79G
	# Used:        73G
	# Available:   1.4G
	#
	# Network
	# IP:           0.0.0.0
	# Internet IP:  176.58.124.96

	echo -e ""
	echo -e "${lightyellow}Server Resource${default}"
	fn_messages_separator
	{
		echo -e "${lightyellow}CPU\t${default}"
		echo -e "${lightblue}Model:\t${default}${cpumodel}"
		echo -e "${lightblue}Cores:\t${default}${cpucores}"
		echo -e "${lightblue}Frequency:\t${default}${cpufreqency}MHz"
		echo -e "${lightblue}Avg Load:\t${default}${load}"
	} | column -s $'\t' -t
	echo -e ""
	{
		echo -e "${lightyellow}Memory\t${default}"
		echo -e "${lightblue}Mem:\t${lightblue}total\tused\tfree\tcached\tavailable${default}"
		echo -e "${lightblue}Physical:\t${default}${physmemtotal}\t${physmemused}\t${physmemfree}\t${physmemcached}\t${physmemavailable}${default}"
		echo -e "${lightblue}Swap:\t${default}${swaptotal}\t${swapused}\t${swapfree}${default}"
	} | column -s $'\t' -t
	echo -e ""
	{
		echo -e "${lightyellow}Storage${default}"
		echo -e "${lightblue}Filesystem:\t${default}${filesystem}"
		echo -e "${lightblue}Total:\t\t${default}${totalspace}"
		echo -e "${lightblue}Used:\t\t${default}${usedspace}"
		echo -e "${lightblue}Available:\t${default}${availspace}"
	} | column -s $'\t' -t
	echo -e ""
	{
		echo -e "${lightyellow}Network${default}"
		if [ -n "${netint}" ]; then
			echo -e "${lightblue}Interface:\t${default}${netint}"
		fi
		if [ -n "${netlink}" ]; then
			echo -e "${lightblue}Link Speed:\t${default}${netlink}"
		fi
		echo -e "${lightblue}IP:\t${default}${ip}"
		if [ "${ip}" != "${extip}" ]; then
			echo -e "${lightblue}Internet IP:\t${default}${extip}"
		fi
	} | column -s $'\t' -t
}

fn_info_message_gameserver_resource(){
	#
	# Game Server Resource Usage
	# =================================
	# CPU Used:  1.1%
	# Mem Used:  4.8%  189MB
	#
	# Storage
	# Total:        241M
	# Serverfiles:  240M
	# Backups:      24K

	echo -e ""
	echo -e "${lightyellow}Game Server Resource Usage${default}"
	fn_messages_separator
	{
		if [ "${status}" != "0" ]&&[ -v status ]; then
			if [ -n "${cpuused}" ]; then
				echo -e "${lightblue}CPU Used:\t${default}${cpuused}%${default}"
			else
				echo -e "${lightblue}CPU Used:\t${red}unknown${default}"
			fi
			if [ -n "${memused}" ]; then
				echo -e "${lightblue}Mem Used:\t${default}${pmemused}%\t${memused}MB${default}"
			else
				echo -e "${lightblue}Mem Used:\t${default}${pmemused}\t${red}unknown${default}"
			fi
		else
			echo -e "${lightblue}CPU Used:\t${default}0%${default}"
			echo -e "${lightblue}Mem Used:\t${default}0%\t0MB${default}"
		fi
	} | column -s $'\t' -t
		echo -e ""
	{
		echo -e "${lightyellow}Storage${default}"
		echo -e "${lightblue}Total:\t${default}${rootdirdu}"
		echo -e "${lightblue}Serverfiles:\t${default}${serverfilesdu}"
		if [ -d "${backupdir}" ]; then
			echo -e "${lightblue}Backups:\t${default}${backupdirdu}"
		fi
	} | column -s $'\t' -t
}

fn_info_message_gameserver(){
	#
	# Counter-Strike: Global Offensive Server Details
	# =================================
	# Server name:      LinuxGSM
	# Server IP:        0.0.0.0:27015
	# Internet IP:      176.48.124.96:34197
	# Server password:  NOT SET
	# RCON password:    adminF54CC0VR
	# Players:          0/16
	# Current map:      de_mirage
	# Default map:      de_mirage
	# Game type:        0
	# Game mode:        0
	# Tick rate:        64
	# Master Server:    listed
	# Status:           STARTED

	echo -e ""
	echo -e "${lightgreen}${gamename} Server Details${default}"
	fn_info_message_password_strip
	fn_messages_separator
	{
		# Server name
		if [ -n "${gdname}" ]; then
			echo -e "${lightblue}Server name:\t${default}${gdname}"
		elif [ -n "${servername}" ]; then
			echo -e "${lightblue}Server name:\t${default}${servername}"
		fi

		# Server description
		if [ -n "${serverdescription}" ]; then
			echo -e "${lightblue}Server Description:\t${default}${serverdescription}"
		fi

		# Appid
		if [ -n "${appid}" ]; then
			echo -e "${lightblue}App ID:\t${default}${appid}"
		fi

		# Branch
		if [ -n "${branch}" ]; then
			echo -e "${lightblue}Branch:\t${default}${branch}"
		fi

		# Beta Password
		if [ -n "${betapassword}" ]; then
			echo -e "${lightblue}Beta Password:\t${default}${betapassword}"
		fi

		# Server Version
		if [ -n "${gdversion}" ]; then
			echo -e "${lightblue}Server Version:\t${default}${gdversion}"
		fi

		# Server ip
		echo -e "${lightblue}Server IP:\t${default}${ip}:${port}"

		# Internet ip
		if [ -n "${extip}" ]; then
			if [ "${ip}" != "${extip}" ]; then
				echo -e "${lightblue}Internet IP:\t${default}${extip}:${port}"
			fi
		fi

		# Display ip
		if [ -n "${displayip}" ]; then
			echo -e "${lightblue}Display IP:\t${default}${displayip}:${port}"
		fi

		# Server password
		if [ -n "${serverpassword}" ]; then
			echo -e "${lightblue}Server password:\t${default}${serverpassword}"
		fi

		# Query enabled (Starbound)
		if [ -n "${queryenabled}" ]; then
			echo -e "${lightblue}Query enabled:\t${default}${queryenabled}"
		fi

		# RCON enabled (Starbound)
		if [ -n "${rconenabled}" ]; then
			echo -e "${lightblue}RCON enabled:\t${default}${rconenabled}"
		fi

		# RCON password
		if [ -n "${rconpassword}" ]; then
			echo -e "${lightblue}RCON password:\t${default}${rconpassword}"
		fi

		# RCON web (Rust)
		if [ -n "${rconweb}" ]; then
			echo -e "${lightblue}RCON web:\t${default}${rconweb}"
		fi

		# Admin password
		if [ -n "${adminpassword}" ]; then
			echo -e "${lightblue}Admin password:\t${default}${adminpassword}"
		fi

		# Stats password (Quake Live)
		if [ -n "${statspassword}" ]; then
			echo -e "${lightblue}Stats password:\t${default}${statspassword}"
		fi

		# Players
		if [ "${querystatus}" != "0" ]; then
			if [ -n "${maxplayers}" ]; then
				echo -e "${lightblue}Maxplayers:\t${default}${maxplayers}"
			fi
		else
			if [ -n "${gdplayers}" ]&&[ -n "${gdmaxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}${gdplayers}/${gdmaxplayers}"
			elif [ -n "${gdplayers}" ]&&[ -n "${maxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}${gdplayers}/${maxplayers}"
			elif [ -z "${gdplayers}" ]&&[ -n "${gdmaxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}0/${gdmaxplayers}"
			elif [ -n "${gdplayers}" ]&&[ -z "${gdmaxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}${gdplayers}/∞"
			elif [ -z "${gdplayers}" ]&&[ -z "${gdmaxplayers}" ]&&[ -n "${maxplayers}" ]; then
				echo -e "${lightblue}Maxplayers:\t${default}${maxplayers}"
			fi
		fi

		# Bots
		if [ -n "${gdbots}" ]; then
			echo -e "${lightblue}Bots:\t${default}${gdbots}"
		fi

		# Current map
		if [ -n "${gdmap}" ]; then
			echo -e "${lightblue}Current map:\t${default}${gdmap}"
		fi

		# Default map
		if [ -n "${defaultmap}" ]; then
			echo -e "${lightblue}Default map:\t${default}${defaultmap}"
		fi

		if [ -n "${defaultscenario}" ]; then
			# Current scenario (Insurgency: Sandstorm)
			if [ -n "${gdgamemode}" ]; then
				echo -e "${lightblue}Current scenario:\t${default}${gdgamemode}"
			fi
		else
			# Current game mode
			if [ -n "${gdgamemode}" ]; then
				echo -e "${lightblue}Current game mode:\t${default}${gdgamemode}"
			fi
		fi

		# Default scenario
		if [ -n "${defaultscenario}" ]; then
			echo -e "${lightblue}Default scenario:\t${default}${defaultscenario}"
		fi

		# Game type
		if [ -n "${gametype}" ]; then
			echo -e "${lightblue}Game type:\t${default}${gametype}"
		fi

		# Game mode
		if [ -n "${gamemode}" ]; then
			echo -e "${lightblue}Game mode:\t${default}${gamemode}"
		fi

		# Game world
		if [ -n "${gameworld}" ]; then
			echo -e "${lightblue}Game world:\t${default}${gameworld}"
		fi

		# Tick rate
		if [ -n "${tickrate}" ]; then
			echo -e "${lightblue}Tick rate:\t${default}${tickrate}"
		fi

		# Sharding (Don't Starve Together)
		if [ -n "${sharding}" ]; then
			echo -e "${lightblue}Sharding:\t${default}${sharding}"
		fi

		# Master (Don't Starve Together)
		if [ -n "${master}" ]; then
			echo -e "${lightblue}Master:\t${default}${master}"
		fi

		# Shard (Don't Starve Together)
		if [ -n "${shard}" ]; then
			echo -e "${lightblue}Shard:\t${default}${shard}"
		fi

		# Cluster (Don't Starve Together)
		if [ -n "${cluster}" ]; then
			echo -e "${lightblue}Cluster:\t${default}${cluster}"
		fi

		# Cave (Don't Starve Together)
		if [ -n "${cave}" ]; then
			echo -e "${lightblue}Cave:\t${default}${cave}"
		fi

		# Creativemode (Hurtworld)
		if [ -n "${creativemode}" ]; then
			echo -e "${lightblue}Creativemode:\t${default}${creativemode}"
		fi

		# TeamSpeak dbplugin
		if [ -n "${dbplugin}" ]; then
			echo -e "${lightblue}dbplugin:\t${default}${dbplugin}"
		fi

		# ASE (Multi Theft Auto)
		if [ -n "${ase}" ]; then
			echo -e "${lightblue}ASE:\t${default}${ase}"
		fi

		# Save interval (Rust)
		if [ -n "${saveinterval}" ]; then
			echo -e "${lightblue}Save interval:\t${default}${saveinterval}s"
		fi

		# Seed (Rust)
		if [ -n "${seed}" ]; then
			echo -e "${lightblue}Seed:\t${default}${seed}"
		fi

		# Salt (Rust)
		if [ -n "${salt}" ]; then
			echo -e "${lightblue}Salt:\t${default}${salt}"
		fi

		# World Size (Rust)
		if [ -n "${worldsize}" ]; then
			echo -e "${lightblue}World size:\t${default}${worldsize}m"
		fi

		# Random map rotation mode (Squad and Post Scriptum)
		if [ -n "${randommap}" ]; then
			echo -e "${lightblue}Map rotation:\t${default}${randommap}"
		fi

		# Server Version (Jedi Knight II: Jedi Outcast)
		if [ -n "${serverversion}" ]; then
			echo -e "${lightblue}Server Version:\t${default}${serverversion}"
		fi

		# authentication token (Factorio)
		if [ -n "${authtoken}" ]; then
			echo -e "${lightblue}Auth Token:\t${default}${authtoken}"
		fi

		# savegameinterval (Factorio)
		if [ -n "${savegameinterval}" ]; then
			echo -e "${lightblue}Savegame Interval:\t${default}${savegameinterval}"
		fi

		# versioncount (Factorio)
		if [ -n "${versioncount}" ]; then
			echo -e "${lightblue}Version Count:\t${default}${versioncount}"
		fi

		# Listed on Master server
		if [ -n "${displaymasterserver}" ]; then
			if [ "${displaymasterserver}" == "true" ]; then
				echo -e "${lightblue}Master server:\t${green}listed${default}"
			else
				echo -e "${lightblue}Master server:\t${red}not listed${default}"
			fi
		fi

		# Game server status
		if [ "${status}" == "0" ]; then
			echo -e "${lightblue}Status:\t${red}STOPPED${default}"
		else
			echo -e "${lightblue}Status:\t${green}STARTED${default}"
		fi
	} | column -s $'\t' -t
	echo -e ""
}

fn_info_message_script(){
	# csgoserver Script Details
	# =================================
	# Script name:            csgoserver
	# LinuxGSM version:       v21.1.3
	# glibc required:         2.18
	# Discord alert:          off
	# Email alert:            off
	# IFTTT alert:            off
	# Mailgun (email) alert:  off
	# Pushbullet alert:       off
	# Pushover alert:         off
	# Rocketchat alert:       off
	# Slack alert:            off
	# Telegram alert:         off
	# Update on start:        off
	# User:                   lgsm
	# Location:               /home/lgsm/csgoserver
	# Config file:            /home/lgsm/csgoserver/serverfiles/csgo/cfg/csgoserver.cfg

	echo -e "${lightgreen}${selfname} Script Details${default}"
	fn_messages_separator
	{
		# Script name
		echo -e "${lightblue}Script name:\t${default}${selfname}"

		# LinuxGSM version
		if [ -n "${version}" ]; then
			echo -e "${lightblue}LinuxGSM version:\t${default}${version}"
		fi

		# glibc required
		if [ -n "${glibc}" ]; then
			if [ "${glibc}" == "null" ]; then
				# Glibc is not required.
				:
			elif [ -z "${glibc}" ]; then
				echo -e "${lightblue}glibc required:\t${red}UNKNOWN${default}"
			elif [ "$(printf '%s\n'${glibc}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibc}" ]; then
				echo -e "${lightblue}glibc required:\t${red}${glibc} ${default}(${red}distro glibc ${glibcversion} too old${default})"
			else
				echo -e "${lightblue}glibc required:\t${green}${glibc}${default}"
			fi
		fi

		# Discord alert
		echo -e "${lightblue}Discord alert:\t${default}${discordalert}"
		# Email alert
		echo -e "${lightblue}Email alert:\t${default}${emailalert}"
		# IFTTT alert
		echo -e "${lightblue}IFTTT alert:\t${default}${iftttalert}"
		# Mailgun alert
		echo -e "${lightblue}Mailgun (email) alert:\t${default}${mailgunalert}"
		# Pushbullet alert
		echo -e "${lightblue}Pushbullet alert:\t${default}${pushbulletalert}"
		# Pushover alert
		echo -e "${lightblue}Pushover alert:\t${default}${pushoveralert}"
		# Rocketchat alert
		echo -e "${lightblue}Rocketchat alert:\t${default}${rocketchatalert}"
		# Slack alert
		echo -e "${lightblue}Slack alert:\t${default}${slackalert}"
		# Telegram alert
		echo -e "${lightblue}Telegram alert:\t${default}${telegramalert}"

		# Update on start
		if [ -n "${updateonstart}" ]; then
			echo -e "${lightblue}Update on start:\t${default}${updateonstart}"
		fi

		# User
		echo -e "${lightblue}User:\t${default}$(whoami)"

		# Script location
		echo -e "${lightblue}Location:\t${default}${rootdir}"

		# Config file location
		if [ -n "${servercfgfullpath}" ]; then
			if [ -f "${servercfgfullpath}" ]; then
				echo -e "${lightblue}Config file:\t${default}${servercfgfullpath}"
			elif [ -d "${servercfgfullpath}" ]; then
				echo -e "${lightblue}Config dir:\t${default}${servercfgfullpath}"
			else
				echo -e "${lightblue}Config file:\t${default}${red}${servercfgfullpath}${default} (${red}FILE MISSING${default})"
			fi
		fi

		# Network config file location (ARMA 3)
		if [ -n "${networkcfgfullpath}" ]; then
			echo -e "${lightblue}Network config file:\t${default}${networkcfgfullpath}"
		fi
	} | column -s $'\t' -t
}

fn_info_message_backup(){
	#
	# Backups
	# =================================
	# No. of backups:    1
	# Latest backup:
	#     date:          Fri May  6 18:34:19 UTC 2016
	#     file:          /home/lgsm/qlserver/backups/ql-server-2016-05-06-183239.tar.gz
	#     size:          945M

	echo -e ""
	echo -e "${lightgreen}Backups${default}"
	fn_messages_separator
	if [ ! -d "${backupdir}" ]||[ "${backupcount}" == "0" ]; then
		echo -e "No Backups created"
	else
		{
			echo -e "${lightblue}No. of backups:\t${default}${backupcount}"
			echo -e "${lightblue}Latest backup:${default}"
			if [ "${lastbackupdaysago}" == "0" ]; then
				echo -e "${lightblue}    date:\t${default}${lastbackupdate} (less than 1 day ago)"
			elif [ "${lastbackupdaysago}" == "1" ]; then
				echo -e "${lightblue}    date:\t${default}${lastbackupdate} (1 day ago)"
			else
				echo -e "${lightblue}    date:\t${default}${lastbackupdate} (${lastbackupdaysago} days ago)"
			fi
			echo -e "${lightblue}    file:\t${default}${lastbackup}"
			echo -e "${lightblue}    size:\t${default}${lastbackupsize}"
		} | column -s $'\t' -t
	fi
}

fn_info_message_commandlineparms(){
	#
	# Command-line Parameters
	# =================================
	# ./run_server_x86.sh +set net_strict 1

	echo -e ""
	echo -e "${lightgreen}Command-line Parameters${default}"
	fn_info_message_password_strip
	fn_messages_separator
	if [ "${serverpassword}" == "NOT SET" ]; then
		unset serverpassword
	fi
	fn_reload_startparameters
	echo -e "${preexecutable} ${executable} ${startparameters}"
}

fn_info_message_ports(){
	#
	# Ports
	# =================================
	# Change ports by editing the parameters in:
	# /home/lgsm/qlserver/serverfiles/baseq3/ql-server.cfg
	echo -e ""
	echo -e "${lightgreen}Ports${default}"
	fn_messages_separator
	echo -e "${lightblue}Change ports by editing the parameters in:${default}"

	startparameterslocation="${red}UNKNOWN${default}"
	# engines/games that require editing in the config file.
	local ports_edit_array=( "avalanche2.0" "avalanche3.0" "Ballistic Overkill" "Barotrauma" "dontstarve" "Eco" "idtech2" "idtech3" "idtech3_ql" "lwjgl2" "Minecraft Bedrock" "Project Cars" "projectzomboid" "quake" "refractor" "realvirtuality" "renderware" "Stationeers" "teeworlds" "terraria" "unreal" "unreal2" "unreal3" "TeamSpeak 3" "Mumble" "7 Days To Die" "Vintage Story" "wurm")
	for port_edit in "${ports_edit_array[@]}"; do
		if [ "${shortname}" == "ut3" ]; then
			startparameterslocation="${servercfgdir}/UTWeb.ini"
		elif [ "${shortname}" == "kf2" ]; then
			startparameterslocation="${servercfgdir}/LinuxServer-KFEngine.ini\n${servercfgdir}/KFWeb.ini"
		elif [ "${engine}" == "${port_edit}" ]||[ "${gamename}" == "${port_edit}" ]; then
			startparameterslocation="${servercfgfullpath}"
		fi
	done
	# engines/games that require editing the start parameters.
	local ports_edit_array=( "Avorion" "col" "goldsrc" "Factorio" "Hurtworld" "iw3.0" "ioquake3" "qfusion" "Rust" "scpsl" "scpslsm" "Soldat" "spark" "source" "starbound" "unreal4" "realvirtuality" "Unturned" "vh" )
	for port_edit in "${ports_edit_array[@]}"; do
		if [ "${engine}" == "${port_edit}" ]||[ "${gamename}" == "${port_edit}" ]||[ "${shortname}" == "${port_edit}" ]; then
			startparameterslocation="${configdirserver}"
		fi
	done
	echo -e "${startparameterslocation}"
	echo -e ""
	echo -e "${lightblue}Useful port diagnostic command:${default}"
	echo -e "ss -tupl | grep ${executable//.\/}"
	echo -e ""
}

fn_info_message_statusbottom(){
	echo -e ""
	if [ "${status}" == "0" ]; then
		echo -e "${lightblue}Status:\t${red}STOPPED${default}"
	else
		echo -e "${lightblue}Status:\t${green}STARTED${default}"
	fi
	echo -e ""
}

fn_info_logs(){
	echo -e ""
	echo -e "${selfname} Logs"
	echo -e "================================="

	if [ -n "${lgsmlog}" ]; then
		echo -e "\nScript log\n==================="
		if [ ! "$(ls -A "${lgsmlogdir}")" ]; then
			echo -e "${lgsmlogdir} (NO LOG FILES)"
		elif [ ! -s "${lgsmlog}" ]; then
			echo -e "${lgsmlog} (LOG FILE IS EMPTY)"
		else
			echo -e "${lgsmlog}"
			tail -25 "${lgsmlog}"
		fi
		echo -e ""
	fi

	if [ -n "${consolelog}" ]; then
		echo -e "\nConsole log\n===================="
		if [ ! "$(ls -A "${consolelogdir}")" ]; then
			echo -e "${consolelogdir} (NO LOG FILES)"
		elif [ ! -s "${consolelog}" ]; then
			echo -e "${consolelog} (LOG FILE IS EMPTY)"
		else
			echo -e "${consolelog}"
			tail -25 "${consolelog}" | awk '{ sub("\r$", ""); print }'
		fi
		echo -e ""
	fi

	if [ -n "${gamelogdir}" ]; then
		echo -e "\nServer log\n==================="
		if [ ! "$(ls -A "${gamelogdir}")" ]; then
			echo -e "${gamelogdir} (NO LOG FILES)"
		else
			echo -e "${gamelogdir}"
			# dos2unix sed 's/\r//'
			tail "${gamelogdir}"/* 2>/dev/null | grep -v "==>" | sed '/^$/d' | sed 's/\r//' | tail -25
		fi
		echo -e ""
	fi
}

# Engine/Game Specific details

fn_info_message_ark(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp\t$(echo "${ssinfo}" | grep ${port} | wc -l)"
		# Don't do arithmetics if ever the port wasn't a numeric value
		if [ "${port}" -eq "${port}" ]; then
			echo -e "> RAW UDP Socket\t$((port+1))\tudp"
		fi
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> RCON\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_assettocorsa(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> HTTP\t${httpport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_avorion(){
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\t${port}\tudp"
		echo -e "> RCON\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_ballisticoverkill(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/RCON\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_bt1944(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Steam\t${steamport}\tudp"
		echo -e "> RCON\t${rconport}\ttcp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_cod(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_coduo(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_chivalry(){
	fn_info_message_password_strip
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> RCON\t27960\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_cod2(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_cod4(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_codwaw(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_dst(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game: Server\t${port}\tudp"
		echo -e "> Game: Master\t${masterport}\tudp"
		echo -e "> Steam: Auth\t${steamauthenticationport}\tudp"
		echo -e "> Steam: Master\t${steammasterport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_eco(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Web Admin\t${webadminport}\ttcp"
	} | column -s $'\t' -t
}


fn_info_message_etlegacy(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_factorio(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> RCON\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_goldsrc(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/RCON\t${port}\ttcp/udp"
		echo -e "< Client\t${clientport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_hurtworld(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/RCON\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_inss(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		if [ -n "${rconport}" ]; then
			echo -e "> RCON\t${rconport}\ttcp"
		fi
	} | column -s $'\t' -t
}

	fn_info_message_jk2(){
		{
			echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
			echo -e "> Game\t${port}\tudp"
		} | column -s $'\t' -t
	}

fn_info_message_justcause2(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_justcause3(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> Steam\t${steamport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_minecraft(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\ttcp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> Rcon\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_minecraft_bedrock(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Game\t${port6}\tudp6"
	} | column -s $'\t' -t
}

fn_info_message_onset(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> HTTP\t${httpport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_mohaa(){
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_mom(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> BeaconPort\t${beaconport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_mumble(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Voice\t${port}\tudp"
		echo -e "> ServerQuery\t${port}\ttcp"
	} | column -s $'\t' -t
}
fn_info_message_pstbs(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> RCON\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_projectcars(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> Steam\t${steamport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_projectzomboid(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_quake(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_quake2(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_quake3(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_quakelive(){
	if [ -z "${port}" ]||[ -z "${rconport}" ]||[ -z "${statsport}" ]; then
		echo -e "${red}ERROR!${default} Missing/commented ports in ${servercfg}."
		echo -e ""
	fi
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
		echo -e "> Rcon\t${rconport}\tudp"
		echo -e "> Stats\t${statsport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_arma3(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "Game\t${port}\tudp\t$(echo "${ssinfo}" | grep ${port} | wc -l)"
		echo -e "Voice\t${voiceport}\tudp\t$(echo "${ssinfo}" | grep ${voiceport} | wc -l)"
		echo -e "Query Steam\t${queryport}\tudp\t$(echo "${ssinfo}" | grep ${queryport} | wc -l)"
		echo -e "Steam Master\t${steammasterport}\tudp\t$(echo "${ssinfo}" | grep ${steammasterport} | wc -l)"
		echo -e "Voice (unused)\t${voiceunusedport}\tudp\t$(echo "${ssinfo}" | grep ${voiceunusedport} | wc -l)"
		echo -e "BattleEye\t${battleeyeport}\tudp\t$(echo "${ssinfo}" | grep ${battleeyeport} | wc -l)"
	} | column -s $'\t' -t
}

fn_info_message_bf1942(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
		echo -e "> Query Steam\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_bfv(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_risingworld(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\ttcp/udp"
		echo -e "> Query HTTP\t${httpqueryport}\ttcp"
		echo -e "> RCON\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_rtcw(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_rust(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
		echo -e "> RCON\t${rconport}\ttcp"
		echo -e "> App\t${appport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_samp(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/RCON\t${port}\ttcp/udp"
	} | column -s $'\t' -t
}

fn_info_message_sbots(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_sdtd(){
	fn_info_message_password_strip
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/RCON\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> Web Admin\t${webadminport}\ttcp"
		echo -e "> Telnet\t${telnetport}\ttcp"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${gamename} Web Admin${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Admin enabled:\t${default}${webadminenabled}"
		echo -e "${lightblue}Web Admin url:\t${default}http://${webadminip}:${webadminport}"
		echo -e "${lightblue}Web Admin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${gamename} Telnet${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Telnet enabled:\t${default}${telnetenabled}"
		echo -e "${lightblue}Telnet address:\t${default}${telnetip} ${telnetport}"
		echo -e "${lightblue}Telnet password:\t${default}${telnetpass}"
	} | column -s $'\t' -t
}

fn_info_message_sof2(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_source(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/RCON\t${port}\ttcp/udp"
		echo -e "> SourceTV\t${sourcetvport}\tudp"
		echo -e "< Client\t${clientport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_spark(){
	fn_info_message_password_strip
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/RCON\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> Web Admin\t${webadminport}\ttcp"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} Web Admin${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Admin url:\t${default}http://${webadminip}:${webadminport}/index.html"
		echo -e "${lightblue}Web Admin username:\t${default}${webadminuser}"
		echo -e "${lightblue}Web Admin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
}

fn_info_message_squad(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> RCON\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_starbound(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\ttcp"
		echo -e "> Query\t${queryport}\ttcp"
		echo -e "> RCON\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_stationeers(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\ttcp"
		echo -e "> Query\t${queryport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_teamspeak3(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Voice\t${port}\tudp"
		echo -e "> ServerQuery\t${queryport}\ttcp"
		echo -e "> File transfer\t${fileport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_teeworlds(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\Query\t${port}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_terraria(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_towerunite(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\ttcp"
		# Don't do arithmetics if ever the port wasn't a numeric value
		if [ "${port}" -eq "${port}" ]; then
			echo -e "> Steam\t$((port+1))\tudp"
		fi
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_unreal(){
	fn_info_message_password_strip
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL\tINI VARIABLE"
		echo -e "> Game\t${port}\tudp\tPort=${port}"
		echo -e "> Query\t${queryport}\tudp"
		if [ "${engine}" == "unreal" ]; then
			echo -e "< UdpLink Port (random)\t${udplinkport}+\tudp"
		fi
		if [ "${engine}" != "unreal" ]&&[ "${appid}" != "223250" ]; then
			echo -e "> Query (GameSpy)\t${queryportgs}\tudp\tOldQueryPortNumber=${queryportgs}"
		fi
		if [ "${appid}" == "215360" ]; then
			echo -e "< Master server\t28852\ttcp/udp"
		else
			echo -e "< Master server\t28900/28902\ttcp/udp"
		fi
		if [ "${appid}" ]; then
			if [ "${appid}" == "223250" ]; then
				echo -e "> Steam\t20610\tudp"
			else
				echo -e "> Steam\t20660\tudp"
			fi
		fi
		echo -e "> Web Admin\t${webadminport}\ttcp\tListenPort=${webadminport}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} Web Admin${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Admin enabled:\t${default}${webadminenabled}"
		echo -e "${lightblue}Web Admin url:\t${default}http://${webadminip}:${webadminport}"
		echo -e "${lightblue}Web Admin username:\t${default}${webadminuser}"
		echo -e "${lightblue}Web Admin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
}

fn_info_message_unreal2(){
	fn_info_message_password_strip
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL\tINI VARIABLE"
		echo -e "> Game\t${port}\tudp\tPort=${port}"
		echo -e "> Query\t${queryport}\tudp"
		if [ "${appid}" != "223250" ]; then
			echo -e "> Query (GameSpy)\t${queryportgs}\tudp\tOldQueryPortNumber=${queryportgs}"
		fi
		echo -e "> Web Admin\t${webadminport}\ttcp\tListenPort=${webadminport}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} Web Admin${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Admin enabled:\t${default}${webadminenabled}"
		echo -e "${lightblue}Web Admin url:\t${default}http://${webadminip}:${webadminport}"
		echo -e "${lightblue}Web Admin username:\t${default}${webadminuser}"
		echo -e "${lightblue}Web Admin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
}

fn_info_message_unreal3(){
	fn_info_message_password_strip
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> Web Admin\t${webadminport}\ttcp\tListenPort=${webadminport}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} Web Admin${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Admin enabled:\t${default}${webadminenabled}"
		echo -e "${lightblue}Web Admin url:\t${default}http://${webadminip}:${webadminport}"
		echo -e "${lightblue}Web Admin username:\t${default}${webadminuser}"
		echo -e "${lightblue}Web Admin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
}

fn_info_message_unturned(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_ut(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_vh(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_kf2(){
	fn_info_message_password_strip
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\ttcp\tPort=${port}"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> Steam\t20560\tudp"
		echo -e "> Web Admin\t${webadminport}\ttcp\tListenPort=${webadminport}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} Web Admin${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Admin enabled:\t${default}${webadminenabled}"
		echo -e "${lightblue}Web Admin url:\t${default}http://${webadminip}:${webadminport}"
		echo -e "${lightblue}Web Admin username:\t${default}${webadminuser}"
		echo -e "${lightblue}Web Admin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
}

fn_info_message_wolfensteinenemyterritory(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
	} | column -s $'\t' -t
}


fn_info_message_wurmunlimited(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\ttcp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_mta(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game/Query\t${port}\tudp"
		echo -e "> HTTP Server\t${httpport}\ttcp"
		if [ "${ase}" == "Enabled" ]; then
			echo -e "> Query Port\t${queryport}\tudp"
		fi
	} | column -s $'\t' -t
}

fn_info_message_mordhau(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> BeaconPort\t${beaconport}\tudp"
		echo -e "> Query\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_barotrauma(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t$((port+1))\tudp"
	} | column -s $'\t' -t
}

fn_info_message_soldat(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Query\t${queryport}\tudp"
		echo -e "> FILES\t$((port+10))\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_warfork(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> HTTP\t${httpport}\ttcp"
	} | column -s $'\t' -t
}

fn_info_message_pavlovvr(){
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Game\t$((port+400))\tudp"
	} | column -s $'\t' -t
}

fn_info_message_colony(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
		echo -e "> Steam\t${steamport}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_vintagestory(){
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\t${port}\tTCP"
	} | column -s $'\t' -t
}

fn_info_message_scpsl(){
	{
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tSTATUS${default}"
		echo -e "> Game\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_info_message_select_engine(){
	# Display details depending on game or engine.
	if [ "${shortname}" == "ac" ]; then
		fn_info_message_assettocorsa
	elif [ "${shortname}" == "ark" ]; then
		fn_info_message_ark
	elif [ "${shortname}" == "av" ]; then
		fn_info_message_avorion
	elif [ "${shortname}" == "arma3" ]; then
		fn_info_message_arma3
	elif [ "${shortname}" == "bf1942" ]; then
		fn_info_message_bf1942
	elif [ "${shortname}" == "bfv" ]; then
		fn_info_message_bfv
	elif [ "${shortname}" == "bo" ]; then
		fn_info_message_ballisticoverkill
	elif [ "${shortname}" == "bt" ]; then
		fn_info_message_barotrauma
	elif [ "${shortname}" == "bt1944" ]; then
		fn_info_message_bt1944
	elif [ "${shortname}" == "cmw" ]; then
		fn_info_message_chivalry
	elif [ "${shortname}" == "cod" ]; then
		fn_info_message_cod
	elif [ "${shortname}" == "coduo" ]; then
		fn_info_message_coduo
	elif [ "${shortname}" == "cod2" ]; then
		fn_info_message_cod2
	elif [ "${shortname}" == "cod4" ]; then
		fn_info_message_cod4
	elif [ "${shortname}" == "codwaw" ]; then
		fn_info_message_codwaw
	elif [ "${shortname}" == "col" ]; then
		fn_info_message_colony
	elif [ "${shortname}" == "dst" ]; then
		fn_info_message_dst
	elif [ "${shortname}" == "eco" ]; then
		fn_info_message_eco
	elif [ "${shortname}" == "etl" ]; then
		fn_info_message_etlegacy
	elif [ "${shortname}" == "fctr" ]; then
		fn_info_message_factorio
	elif [ "${shortname}" == "hw" ]; then
		fn_info_message_hurtworld
	elif [ "${shortname}" == "inss" ]; then
		fn_info_message_inss
	elif [ "${shortname}" == "jk2" ]; then
		fn_info_message_jk2
	elif [ "${shortname}" == "jc2" ]; then
		fn_info_message_justcause2
	elif [ "${shortname}" == "jc3" ]; then
		fn_info_message_justcause3
	elif [ "${shortname}" == "kf2" ]; then
		fn_info_message_kf2
	elif [ "${shortname}" == "mc" ]||[ "${shortname}" == "pmc" ]||[ "${shortname}" == "wmc" ]; then
		fn_info_message_minecraft
	elif [ "${shortname}" == "mcb" ]; then
		fn_info_message_minecraft_bedrock
	elif [ "${shortname}" == "mh" ]; then
		fn_info_message_mordhau
	elif [ "${shortname}" == "mohaa" ]; then
		fn_info_message_mohaa
	elif [ "${shortname}" == "mta" ]; then
		fn_info_message_mta
	elif [ "${shortname}" == "mumble" ]; then
		fn_info_message_mumble
	elif [ "${shortname}" == "onset" ]; then
		fn_info_message_onset
	elif [ "${shortname}" == "mom" ]; then
		fn_info_message_mom
	elif [ "${shortname}" == "pz" ]; then
		fn_info_message_projectzomboid
	elif [ "${shortname}" == "pstbs" ]; then
		fn_info_message_pstbs
	elif [ "${shortname}" == "pc" ]; then
		fn_info_message_projectcars
	elif [ "${shortname}" == "qw" ]; then
		fn_info_message_quake
	elif [ "${shortname}" == "q2" ]; then
		fn_info_message_quake2
	elif [ "${shortname}" == "q3" ]; then
		fn_info_message_quake3
	elif [ "${shortname}" == "ql" ]; then
		fn_info_message_quakelive
	elif [ "${shortname}" == "samp" ]; then
		fn_info_message_samp
	elif [ "${shortname}" == "scpsl" ]||[ "${shortname}" == "scpslsm" ]; then
		fn_info_message_scpsl
	elif [ "${shortname}" == "sdtd" ]; then
		fn_info_message_sdtd
	elif [ "${shortname}" == "squad" ]; then
		fn_info_message_squad
	elif [ "${shortname}" == "st" ]; then
		fn_info_message_stationeers
	elif [ "${shortname}" == "sof2" ]; then
		fn_info_message_sof2
	elif [ "${shortname}" == "sol" ]; then
		fn_info_message_soldat
	elif [ "${shortname}" == "sb" ]; then
		fn_info_message_starbound
	elif [ "${shortname}" == "sbots" ]; then
		fn_info_message_sbots
	elif [ "${shortname}" == "terraria" ]; then
		fn_info_message_terraria
	elif [ "${shortname}" == "ts3" ]; then
		fn_info_message_teamspeak3
	elif [ "${shortname}" == "tu" ]; then
		fn_info_message_towerunite
	elif [ "${shortname}" == "tw" ]; then
		fn_info_message_teeworlds
	elif [ "${shortname}" == "unt" ]; then
		fn_info_message_unturned
	elif [ "${shortname}" == "ut" ]; then
		fn_info_message_ut
	elif [ "${shortname}" == "vh" ]; then
		fn_info_message_vh
	elif [ "${shortname}" == "rtcw" ]; then
		fn_info_message_rtcw
	elif [ "${shortname}" == "pvr" ]; then
		fn_info_message_pavlovvr
	elif [ "${shortname}" == "rust" ]; then
		fn_info_message_rust
	elif [ "${shortname}" == "vints" ]; then
		fn_info_message_vintagestory
	elif [ "${shortname}" == "wf" ]; then
		fn_info_message_warfork
	elif [ "${shortname}" == "wurm" ]; then
		fn_info_message_wurmunlimited
	elif [ "${shortname}" == "rw" ]; then
		fn_info_message_risingworld
	elif [ "${shortname}" == "wet" ]; then
		fn_info_message_wolfensteinenemyterritory
	elif [ "${engine}" == "goldsrc" ]; then
		fn_info_message_goldsrc
	elif [ "${engine}" == "source" ]; then
		fn_info_message_source
	elif [ "${engine}" == "spark" ]; then
		fn_info_message_spark
	elif [ "${engine}" == "unreal" ]; then
		fn_info_message_unreal
	elif [ "${engine}" == "unreal2" ]; then
		fn_info_message_unreal2
	elif [ "${engine}" == "unreal3" ]; then
		fn_info_message_unreal3
	else
		fn_print_error_nl "Unable to detect server engine."
	fi
}
