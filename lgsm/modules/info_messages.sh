#!/bin/bash
# LinuxGSM info_messages.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Defines server info messages for details and alerts.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Removes the passwords form all but details.
fn_info_messages_password_strip() {
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

		if [ "${httppassword}" ]; then
			httppassword="********"
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
fn_info_messages_head() {
	echo -e ""
	echo -e "LinuxGSM Alert Summary"
	fn_messages_separator
	echo -e ""
	echo -e "Server name"
	echo -e "${servername}"
	echo -e ""
	echo -e "Information"
	echo -e "${alertmessage}"
	echo -e ""
	echo -e "Game"
	echo -e "${gamename}"
	echo -e ""
	echo -e "Server IP"
	echo -e "${alertip}:${port}"
	echo -e ""
	echo -e "Hostname"
	echo -e "${HOSTNAME}"
	echo -e ""
	echo -e "Server Time"
	echo -e "$(date)"
}

fn_info_messages_distro() {
	#
	# Distro Details
	# =================================
	# Date:      Sun 21 Feb 2021 09:22:53 AM UTC
	# Distro:    Ubuntu 20.04.2 LTS
	# Arch:      x86_64
	# Kernel:    5.4.0-65-generic
	# Hostname:  server
	# Environment: kvm
	# Uptime:    16d, 5h, 18m
	# tmux:      tmux 3.0a
	# glibc:     2.31

	echo -e ""
	echo -e "${bold}${lightyellow}Distro Details${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Date:\t${default}$(date)"
		echo -e "${lightblue}Distro:\t${default}${distroname}"
		echo -e "${lightblue}Arch:\t${default}${arch}"
		echo -e "${lightblue}Kernel:\t${default}${kernel}"
		echo -e "${lightblue}Hostname:\t${default}${HOSTNAME}"
		echo -e "${lightblue}Environment:\t${default}${virtualenvironment}"
		echo -e "${lightblue}Uptime:\t${default}${days}d, ${hours}h, ${minutes}m"
		echo -e "${lightblue}tmux:\t${default}${tmuxversion}"
		echo -e "${lightblue}glibc:\t${default}${glibcversion}"
		if [ -n "${javaram}" ]; then
			echo -e "${lightblue}Java:\t${default}${javaversion}"
		fi
	} | column -s $'\t' -t
}

fn_info_messages_server_resource() {
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
	echo -e "${bold}${lightyellow}Server Resource${default}"
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
		echo -e "${lightblue}Total:\t${default}${totalspace}"
		echo -e "${lightblue}Used:\t${default}${usedspace}"
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
		if [ "${ip}" != "${publicip}" ]; then
			echo -e "${lightblue}Internet IP:\t${default}${publicip}"
		fi
	} | column -s $'\t' -t
}

fn_info_messages_gameserver_resource() {
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
	echo -e "${bold}${lightgreen}${gamename} Resource Usage${default}"
	fn_messages_separator
	{
		if [ "${status}" != "0" ] && [ -v status ]; then
			if [ -n "${cpuused}" ]; then
				echo -e "${lightblue}CPU Used:\t${default}${cpuused}%${default}"
			else
				echo -e "${lightblue}CPU Used:\t${red}unknown${default}"
			fi
			if [ -n "${memusedmb}" ]; then
				echo -e "${lightblue}Mem Used:\t${default}${memusedpct}%\t${memusedmb}MB${default}"
			else
				echo -e "${lightblue}Mem Used:\t${default}${memusedpct}\t${red}unknown${default}"
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

fn_info_messages_gameserver() {
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
	echo -e "${bold}${lightgreen}${gamename} Server Details${default}"
	fn_info_messages_password_strip
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
		if [ -n "${publicip}" ]; then
			if [ "${ip}" != "${publicip}" ]; then
				echo -e "${lightblue}Internet IP:\t${default}${publicip}:${port}"
			fi
		fi

		# Display ip
		if [ -n "${displayip}" ]; then
			echo -e "${lightblue}Display IP:\t${default}${displayip}:${port}"
		fi

		# Server password enabled (Craftopia)
		if [ -n "${serverpasswordenabled}" ]; then
			echo -e "${lightblue}Server password enabled:\t${default}${serverpasswordenabled}"
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
			if [ -n "${gdplayers}" ] && [ -n "${gdmaxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}${gdplayers}/${gdmaxplayers}"
			elif [ -n "${gdplayers}" ] && [ -n "${maxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}${gdplayers}/${maxplayers}"
			elif [ -z "${gdplayers}" ] && [ -n "${gdmaxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}0/${gdmaxplayers}"
			elif [ -n "${gdplayers}" ] && [ -z "${gdmaxplayers}" ]; then
				echo -e "${lightblue}Players:\t${default}${gdplayers}/∞"
			elif [ -z "${gdplayers}" ] && [ -z "${gdmaxplayers}" ] && [ -n "${maxplayers}" ]; then
				echo -e "${lightblue}Maxplayers:\t${default}${maxplayers}"
			fi
		fi

		# Reverved Slots
		if [ -n "${statspassword}" ]; then
			echo -e "${lightblue}Reserved Slots:\t${default}${reservedslots}"
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

fn_info_messages_script() {
	# csgoserver Script Details
	# =================================
	# Script name:            csgoserver
	# LinuxGSM version:       v21.1.3
	# glibc required:         2.18
	# Discord alert:          off
	# Email alert:            off
	# Gotify alert:           off
	# IFTTT alert:            off
	# Pushbullet alert:       off
	# Pushover alert:         off
	# Rocketchat alert:       off
	# Slack alert:            off
	# Telegram alert:         off
	# Update on start:        off
	# User:                   lgsm
	# Location:               /home/lgsm/csgoserver
	# Config file:            /home/lgsm/csgoserver/serverfiles/csgo/cfg/csgoserver.cfg

	echo -e "${bold}${lightgreen}${selfname} Script Details${default}"
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
		# Gotify alert
		echo -e "${lightblue}Gotify alert:\t${default}${gotifyalert}"
		# IFTTT alert
		echo -e "${lightblue}IFTTT alert:\t${default}${iftttalert}"
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

		# Cluster config file location (DST)
		if [ -n "${clustercfgfullpath}" ]; then
			echo -e "${lightblue}Cluster config file:\t${default}${clustercfgfullpath}"
		fi

	} | column -s $'\t' -t
}

fn_info_messages_backup() {
	#
	# Backups
	# =================================
	# No. of backups:    1
	# Latest backup:
	#     date:          Fri May  6 18:34:19 UTC 2016
	#     file:          /home/lgsm/qlserver/backups/ql-server-2016-05-06-183239.tar.gz
	#     size:          945M

	echo -e ""
	echo -e "${bold}${lightgreen}Backups${default}"
	fn_messages_separator
	if [ ! -d "${backupdir}" ] || [ "${backupcount}" == "0" ]; then
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

fn_info_messages_commandlineparms() {
	#
	# Command-line Parameters
	# =================================
	# ./run_server_x86.sh +set net_strict 1

	echo -e ""
	echo -e "${bold}${lightgreen}Command-line Parameters${default}"
	fn_info_messages_password_strip
	fn_messages_separator
	if [ "${serverpassword}" == "NOT SET" ]; then
		unset serverpassword
	fi
	fn_reload_startparameters
	echo -e "${preexecutable} ${executable} ${startparameters}"
}

fn_info_messages_ports_edit() {
	#
	# Ports
	# =================================
	# Change ports by editing the parameters in:
	# /home/lgsm/qlserver/serverfiles/baseq3/ql-server.cfg
	echo -e ""
	echo -e "${bold}${lightgreen}Ports${default}"
	fn_messages_separator
	echo -e "${lightblue}Change ports by editing the parameters in:${default}"

	startparameterslocation="${red}UNKNOWN${default}"
	# engines/games that require editing in the config file.
	local ports_edit_array=("ac" "arma3" "armar" "bo" "bt" "ct" "dst" "eco" "idtech2" "idtech3" "idtech3_ql" "jc2" "jc3" "lwjgl2" "mcb" "nec" "pc" "pc2" "prism3d" "pz" "qw" "refractor" "renderware" "rw" "sb" "sdtd" "st" "stn" "ts3" "tw" "terraria" "unreal" "unreal2" "unreal3" "vints" "wurm")
	for port_edit in "${ports_edit_array[@]}"; do
		if [ "${shortname}" == "ut3" ]; then
			startparameterslocation="${servercfgdir}/UTWeb.ini"
		elif [ "${shortname}" == "kf2" ]; then
			startparameterslocation="${servercfgdir}/LinuxServer-KFEngine.ini\n${servercfgdir}/KFWeb.ini"
		elif [ "${engine}" == "${port_edit}" ] || [ "${gamename}" == "${port_edit}" ] || [ "${shortname}" == "${port_edit}" ]; then
			startparameterslocation="${servercfgfullpath}"
		fi
	done
	# engines/games that require editing the start parameters.
	local ports_edit_array=("av" "ck" "col" "cs2" "fctr" "goldsrc" "hcu" "hw" "iw3.0" "ioquake3" "pw" "qfusion" "rust" "scpsl" "scpslsm" "sf" "sol" "spark" "source" "unreal4" "arma3" "dayz" "unt" "vh")
	for port_edit in "${ports_edit_array[@]}"; do
		if [ "${engine}" == "${port_edit}" ] || [ "${gamename}" == "${port_edit}" ] || [ "${shortname}" == "${port_edit}" ]; then
			startparameterslocation="${configdirserver}"
		fi
	done
	echo -e "${startparameterslocation}"
	echo -e ""
}

fn_info_messages_ports() {
	echo -e "${lightblue}Useful port diagnostic command:${default}"
	if [ "${shortname}" == "armar" ]; then
		portcommand="ss -tuplwn | grep enfMain"
	elif [ "${shortname}" == "av" ]; then
		portcommand="ss -tuplwn | grep AvorionServer"
	elif [ "${shortname}" == "bf1942" ]; then
		portcommand="ss -tuplwn | grep bf1942_lnxded"
	elif [ "${shortname}" == "bfv" ]; then
		portcommand="ss -tuplwn | grep bfv_linded"
	elif [ "${shortname}" == "dayz" ]; then
		portcommand="ss -tuplwn | grep enfMain"
	elif [ "${shortname}" == "q4" ]; then
		portcommand="ss -tuplwn | grep q4ded.x86"
	elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "nec" ] || [ "${shortname}" == "pmc" ] || [ "${shortname}" == "vpmc" ] || [ "${shortname}" == "wmc" ]; then
		portcommand="ss -tuplwn | grep java"
	elif [ "${shortname}" == "terraria" ]; then
		portcommand="ss -tuplwn | grep Main"
	elif [ "${engine}" == "source" ]; then
		portcommand="ss -tuplwn | grep srcds_linux"
	elif [ "${engine}" == "goldsrc" ]; then
		portcommand="ss -tuplwn | grep hlds_linux"
	else
		executableshort="$(basename "${executable}" | cut -c -15)"
		portcommand="ss -tuplwn | grep ${executableshort}"
	fi
	echo -e "${portcommand}"
	echo -e ""
}

fn_info_messages_statusbottom() {
	echo -e ""
	if [ "${status}" == "0" ]; then
		echo -e "${lightblue}Status:\t${red}STOPPED${default}"
	else
		echo -e "${lightblue}Status:\t${green}STARTED${default}"
	fi
	echo -e ""
}

fn_info_logs() {
	echo -e ""
	echo -e "${bold}${selfname} Logs"
	fn_messages_separator

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
			tail "${gamelogdir}"/* 2> /dev/null | grep -av "==>" | sed '/^$/d' | sed 's/\r//' | tail -25
		fi
		echo -e ""
	fi
}

# Engine/Game Specific details

# Function used to generate port info. by passing info to function. (Reduces repeating code)
# example output
# DESCRIPTION     PORT   PROTOCOL  LISTEN
# Game            7777   udp       1
# RAW UDP Socket  7778   udp       1
# Query           27015  udp       1
# RCON            27020  tcp       1

fn_port() {
	if [ "${1}" == "header" ]; then
		echo -e "${lightblue}DESCRIPTION\tPORT\tPROTOCOL\tLISTEN${default}"
	else
		portname="${1}"
		porttype="${2}"
		portprotocol="${3}"
		echo -e "${portname}\t${!porttype}\t${portprotocol}\t$(echo "${ssinfo}" | grep "${portprotocol}" | grep -c "${!porttype}")"
	fi
}

fn_info_messages_ac() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Game" port tcp
		fn_port "Query" queryport udp
		fn_port "HTTP" httpport tcp
	} | column -s $'\t' -t
}

fn_info_messages_ark() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "RAW UDP Socket" rawport udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_arma3() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Voice" voiceport udp
		fn_port "Query" queryport udp
		fn_port "Steam" steamport udp
		fn_port "Voice (unused)" voiceunusedport udp
		fn_port "BattleEye" battleeyeport udp
	} | column -s $'\t' -t
}

fn_info_messages_armar() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Steam Query" queryport udp
		fn_port "BattleEye" battleeyeport tcp
	} | column -s $'\t' -t
}

fn_info_messages_av() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Steam" steamport udp
		fn_port "Steamworks P2P" steamworksport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_bf1942() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_bfv() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_bo() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_bt() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_btl() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_cd() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Steam" steamport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_ck() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_cmw() {
	fn_info_messages_password_strip
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_cod() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_coduo() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_cod2() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_cod4() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_codwaw() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_col() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "Steam" steamport tcp
	} | column -s $'\t' -t
}

fn_info_messages_cs2() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
	} | column -s $'\t' -t
}

fn_info_messages_csgo() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "RCON" rconport tcp
		fn_port "SourceTV" sourcetvport udp
		fn_port "Client" clientport udp
	} | column -s $'\t' -t
}

fn_info_messages_ct() {
	fn_info_messages_password_strip
	{
		fn_port "header"
		fn_port "Game" port udp
	} | column -s $'\t' -t
}

fn_info_messages_dayz() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query Steam" queryport udp
		fn_port "Steam" steamport udp
		fn_port "BattleEye" battleeyeport udp
	} | column -s $'\t' -t
}

fn_info_messages_dodr() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_dst() {
	{
		fn_port "header"
		fn_port "Game: Server" port udp
		fn_port "Game: Master" masterport udp
		fn_port "Steam" steamport udp
		fn_port "Steam: Auth" steamauthport udp
	} | column -s $'\t' -t
}

fn_info_messages_eco() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Web Interface" httpport tcp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_etl() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_fctr() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_goldsrc() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "Client" clientport udp
	} | column -s $'\t' -t
}

fn_info_messages_hcu() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
	} | column -s $'\t' -t
}

fn_info_messages_hw() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_hz() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_ins() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "RCON" rconport tcp
		fn_port "SourceTV" sourcetvport udp
		fn_port "Client" clientport udp
	} | column -s $'\t' -t
}

fn_info_messages_inss() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_jc2() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_jc3() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Steam" steamport udp
		fn_port "HTTP" httpport tcp
	} | column -s $'\t' -t
}

fn_info_messages_jk2() {
	{
		fn_port "header"
		fn_port "Game" port udp
	} | column -s $'\t' -t
}

fn_info_messages_kf() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Query (GameSpy)" queryportgs udp
		fn_port "Web Interface" httpport tcp
		fn_port "LAN" lanport udp
		fn_port "Steamworks P2P" steamworksport udp
		fn_port "Steam" steamport udp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${servername} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}"
		echo -e "${lightblue}Web Interface username:\t${default}${httpuser}"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
}

fn_info_messages_kf2() {
	fn_info_messages_password_strip
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Web Interface" httpport tcp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${servername} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}"
		echo -e "${lightblue}Web Interface username:\t${default}${httpuser}"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
}

fn_info_messages_mc() {
	{
		fn_port "header"
		fn_port "Game" port tcp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_mcb() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Game" portipv6 udp6
	} | column -s $'\t' -t
}

fn_info_messages_mh() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Beacon" beaconport udp
	} | column -s $'\t' -t
}

fn_info_messages_mohaa() {
	{
		fn_port "header"
		fn_port "Game" port udp
	} | column -s $'\t' -t
}

fn_info_messages_mom() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Beacon" beaconport udp
	} | column -s $'\t' -t
}

fn_info_messages_mta() {
	{
		fn_port "header"
		fn_port "Game" port udp
		if [ "${ase}" == "Enabled" ]; then
			fn_port "Query" queryport udp
		fi
		fn_port "HTTP" httpport tcp
	} | column -s $'\t' -t
}

fn_info_messages_nec() {
	{
		fn_port "header"
		fn_port "Game" port udp
	} | column -s $'\t' -t
}

fn_info_messages_ohd() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_onset() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "HTTP" httpport tcp
	} | column -s $'\t' -t
}

fn_info_messages_pc() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Steam" steamport udp
		fn_port "HTTP" httpport tcp
		fn_port "API" apiport tcp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${gamename} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}"
	} | column -s $'\t' -t
}

fn_info_messages_pc2() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Steam" steamport udp
	} | column -s $'\t' -t
}

fn_info_messages_ps() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_pvr() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Game" port tcp
		fn_port "Game+400" port401 udp
		fn_port "Query" queryport tcp
	} | column -s $'\t' -t
}

fn_info_messages_pw() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Steam" steamport udp
		fn_port "Unknown" unknownport tcp
	} | column -s $'\t' -t
}

fn_info_messages_pz() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_qw() {
	{
		fn_port "header"
		fn_port "Game" port udp
	} | column -s $'\t' -t
}

fn_info_messages_q2() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_q3() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_q4() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_ql() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
		fn_port "Stats" statsport udp
	} | column -s $'\t' -t
}

fn_info_messages_ro() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Web Interface" httpport tcp
		fn_port "LAN" lanport udp
		fn_port "Steamworks P2P" steamworksport udp
		fn_port "Steam" steamport udp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${servername} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}"
		echo -e "${lightblue}Web Interface username:\t${default}${httpuser}"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
}

fn_info_messages_rtcw() {
	{
		fn_port "header"
		fn_port "Game" port udp
	} | column -s $'\t' -t
}

fn_info_messages_rust() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
		fn_port "App" appport tcp
	} | column -s $'\t' -t
}

fn_info_messages_rw() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_samp() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "RCON" rconport udp
	} | column -s $'\t' -t
}

fn_info_messages_sb() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_sbots() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_scpsl() {
	{
		fn_port "header"
		fn_port "Game" port tcp
	} | column -s $'\t' -t
}

fn_info_messages_sdtd() {
	fn_info_messages_password_strip
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Game+2" port3 udp
		fn_port "Query" queryport tcp
		fn_port "Web Interface" httpport tcp
		fn_port "Telnet" telnetport tcp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${gamename} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}/index.html"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${gamename} Telnet${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Telnet enabled:\t${default}${telnetenabled}"
		echo -e "${lightblue}Telnet address:\t${default}${telnetip} ${telnetport}"
		echo -e "${lightblue}Telnet password:\t${default}${telnetpass}"
	} | column -s $'\t' -t
}

fn_info_messages_sf() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Beacon" beaconport udp
	} | column -s $'\t' -t
}

fn_info_messages_sof2() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_sol() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Files" filesport tcp
	} | column -s $'\t' -t
}

fn_info_messages_prism3d() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_source() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "RCON" rconport tcp
		fn_port "SourceTV" sourcetvport udp
		# Will not show if unaviable
		if [ "${steamport}" == "0" ] || [ -v "${steamport}" ]; then
			fn_port "Steam" steamport udp
		fi
		fn_port "Client" clientport udp
	} | column -s $'\t' -t
}

fn_info_messages_spark() {
	fn_info_messages_password_strip
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Mod Server" modserverport tcp
		fn_port "Web Interface" httpport tcp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${gamename} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}/index.html"
		echo -e "${lightblue}Web Interface username:\t${default}${httpuser}"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
}

fn_info_messages_squad() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_st() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_ti() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Queue" queueport tcp
		fn_port "RCON" rconport tcp
	} | column -s $'\t' -t
}

fn_info_messages_ts3() {
	{
		fn_port "header"
		fn_port "Voice" port udp
		fn_port "Query" queryport tcp
		fn_port "Query (SSH)" querysshport tcp
		fn_port "Query (http)" queryhttpport tcp
		fn_port "Query (https)" queryhttpsport tcp
		fn_port "File Transfer" fileport tcp
		fn_port "Telnet" telnetport tcp
	} | column -s $'\t' -t
}

fn_info_messages_tw() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_terraria() {
	{
		fn_port "header"
		fn_port "Game" port tcp
		fn_port "Query" queryport tcp
	} | column -s $'\t' -t
}

fn_info_messages_tu() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Steam" steamport udp
	} | column -s $'\t' -t
}

fn_info_messages_tf() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport tcp
		fn_port "Beacon" beaconport udp
		fn_port "Shutdown" shutdownport tcp
	} | column -s $'\t' -t
}

fn_info_messages_ut2k4() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Query (GameSpy)" queryportgs udp
		fn_port "Web Interface" httpport tcp
		fn_port "LAN" lanport udp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${gamename} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}"
		echo -e "${lightblue}Web Interface username:\t${default}${httpuser}"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
}

fn_info_messages_unreal() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "LAN Beacon" beaconport udp
		fn_port "Web Interface" httpport tcp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${gamename} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}"
		echo -e "${lightblue}Web Interface username:\t${default}${httpuser}"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
}

fn_info_messages_unt() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Steam" steamport udp
	} | column -s $'\t' -t
}

fn_info_messages_ut() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_ut3() {
	fn_info_messages_password_strip
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
		fn_port "Web Interface" httpport tcp
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${bold}${lightgreen}${gamename} Web Interface${default}"
	fn_messages_separator
	{
		echo -e "${lightblue}Web Interface enabled:\t${default}${httpenabled}"
		echo -e "${lightblue}Web Interface url:\t${default}http://${httpip}:${httpport}"
		echo -e "${lightblue}Web Interface username:\t${default}${httpuser}"
		echo -e "${lightblue}Web Interface password:\t${default}${httppassword}"
	} | column -s $'\t' -t
}

fn_info_messages_vh() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_vints() {
	{
		fn_port "header"
		fn_port "Game" port tcp
	} | column -s $'\t' -t
}

fn_info_messages_vpmc() {
	{
		fn_port "header"
		fn_port "Game" port tcp
	} | column -s $'\t' -t
}

fn_info_messages_wet() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_wf() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "HTTP" httpport tcp
	} | column -s $'\t' -t
}

fn_info_messages_wurm() {
	{
		fn_port "header"
		fn_port "Game" port tcp
		fn_port "Query" queryport udp
		fn_port "RMI" rmiport tcp
		fn_port "RMI Registry" rmiregport tcp
	} | column -s $'\t' -t
}

fn_info_messages_stn() {
	{
		fn_port "header"
		fn_port "Game" port udp
		fn_port "Query" queryport udp
	} | column -s $'\t' -t
}

fn_info_messages_select_engine() {
	# Display details depending on game or engine.
	if [ "${shortname}" == "ac" ]; then
		fn_info_messages_ac
	elif [ "${shortname}" == "ark" ]; then
		fn_info_messages_ark
	elif [ "${shortname}" == "arma3" ]; then
		fn_info_messages_arma3
	elif [ "${shortname}" == "armar" ]; then
		fn_info_messages_armar
	elif [ "${shortname}" == "av" ]; then
		fn_info_messages_av
	elif [ "${shortname}" == "bf1942" ]; then
		fn_info_messages_bf1942
	elif [ "${shortname}" == "bfv" ]; then
		fn_info_messages_bfv
	elif [ "${shortname}" == "bo" ]; then
		fn_info_messages_bo
	elif [ "${shortname}" == "bt" ]; then
		fn_info_messages_bt
	elif [ "${shortname}" == "btl" ]; then
		fn_info_messages_btl
	elif [ "${shortname}" == "ck" ]; then
		fn_info_messages_ck
	elif [ "${shortname}" == "cs2" ]; then
		fn_info_messages_cs2
	elif [ "${shortname}" == "csgo" ]; then
		fn_info_messages_csgo
	elif [ "${shortname}" == "cmw" ]; then
		fn_info_messages_cmw
	elif [ "${shortname}" == "cod" ]; then
		fn_info_messages_cod
	elif [ "${shortname}" == "coduo" ]; then
		fn_info_messages_coduo
	elif [ "${shortname}" == "cod2" ]; then
		fn_info_messages_cod2
	elif [ "${shortname}" == "cod4" ]; then
		fn_info_messages_cod4
	elif [ "${shortname}" == "codwaw" ]; then
		fn_info_messages_codwaw
	elif [ "${shortname}" == "col" ]; then
		fn_info_messages_col
	elif [ "${shortname}" == "ct" ]; then
		fn_info_messages_ct
	elif [ "${shortname}" == "dayz" ]; then
		fn_info_messages_dayz
	elif [ "${shortname}" == "dodr" ]; then
		fn_info_messages_dodr
	elif [ "${shortname}" == "dst" ]; then
		fn_info_messages_dst
	elif [ "${shortname}" == "eco" ]; then
		fn_info_messages_eco
	elif [ "${shortname}" == "etl" ]; then
		fn_info_messages_etl
	elif [ "${shortname}" == "fctr" ]; then
		fn_info_messages_fctr
	elif [ "${shortname}" == "hcu" ]; then
		fn_info_messages_hcu
	elif [ "${shortname}" == "hw" ]; then
		fn_info_messages_hw
	elif [ "${shortname}" == "hz" ]; then
		fn_info_messages_hz
	elif [ "${shortname}" == "ins" ]; then
		fn_info_messages_ins
	elif [ "${shortname}" == "inss" ]; then
		fn_info_messages_inss
	elif [ "${shortname}" == "jc2" ]; then
		fn_info_messages_jc2
	elif [ "${shortname}" == "jc3" ]; then
		fn_info_messages_jc3
	elif [ "${shortname}" == "jk2" ]; then
		fn_info_messages_jk2
	elif [ "${shortname}" == "kf" ]; then
		fn_info_messages_kf
	elif [ "${shortname}" == "kf2" ]; then
		fn_info_messages_kf2
	elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ] || [ "${shortname}" == "wmc" ]; then
		fn_info_messages_mc
	elif [ "${shortname}" == "mcb" ]; then
		fn_info_messages_mcb
	elif [ "${shortname}" == "mh" ]; then
		fn_info_messages_mh
	elif [ "${shortname}" == "mohaa" ]; then
		fn_info_messages_mohaa
	elif [ "${shortname}" == "mom" ]; then
		fn_info_messages_mom
	elif [ "${shortname}" == "mta" ]; then
		fn_info_messages_mta
	elif [ "${shortname}" == "nec" ]; then
		fn_info_messages_nec
	elif [ "${shortname}" == "ohd" ]; then
		fn_info_messages_ohd
	elif [ "${shortname}" == "onset" ]; then
		fn_info_messages_onset
	elif [ "${shortname}" == "pc" ]; then
		fn_info_messages_pc
	elif [ "${shortname}" == "pc2" ]; then
		fn_info_messages_pc2
	elif [ "${shortname}" == "ps" ]; then
		fn_info_messages_ps
	elif [ "${shortname}" == "pvr" ]; then
		fn_info_messages_pvr
	elif [ "${shortname}" == "pw" ]; then
		fn_info_messages_pw
	elif [ "${shortname}" == "pz" ]; then
		fn_info_messages_pz
	elif [ "${shortname}" == "q2" ]; then
		fn_info_messages_q2
	elif [ "${shortname}" == "q3" ]; then
		fn_info_messages_q3
	elif [ "${shortname}" == "q4" ]; then
		fn_info_messages_q3
	elif [ "${shortname}" == "ql" ]; then
		fn_info_messages_ql
	elif [ "${shortname}" == "qw" ]; then
		fn_info_messages_qw
	elif [ "${shortname}" == "ro" ]; then
		fn_info_messages_ro
	elif [ "${shortname}" == "rtcw" ]; then
		fn_info_messages_rtcw
	elif [ "${shortname}" == "samp" ]; then
		fn_info_messages_samp
	elif [ "${shortname}" == "sb" ]; then
		fn_info_messages_sb
	elif [ "${shortname}" == "sbots" ]; then
		fn_info_messages_sbots
	elif [ "${shortname}" == "scpsl" ] || [ "${shortname}" == "scpslsm" ]; then
		fn_info_messages_scpsl
	elif [ "${shortname}" == "sdtd" ]; then
		fn_info_messages_sdtd
	elif [ "${shortname}" == "sf" ]; then
		fn_info_messages_sf
	elif [ "${shortname}" == "sof2" ]; then
		fn_info_messages_sof2
	elif [ "${shortname}" == "sol" ]; then
		fn_info_messages_sol
	elif [ "${shortname}" == "squad" ]; then
		fn_info_messages_squad
	elif [ "${shortname}" == "st" ]; then
		fn_info_messages_st
	elif [ "${shortname}" == "stn" ]; then
		fn_info_messages_stn
	elif [ "${shortname}" == "terraria" ]; then
		fn_info_messages_terraria
	elif [ "${shortname}" == "tf" ]; then
		fn_info_messages_tf
	elif [ "${shortname}" == "ti" ]; then
		fn_info_messages_ti
	elif [ "${shortname}" == "ts3" ]; then
		fn_info_messages_ts3
	elif [ "${shortname}" == "tu" ]; then
		fn_info_messages_tu
	elif [ "${shortname}" == "tw" ]; then
		fn_info_messages_tw
	elif [ "${shortname}" == "unt" ]; then
		fn_info_messages_unt
	elif [ "${shortname}" == "vh" ]; then
		fn_info_messages_vh
	elif [ "${shortname}" == "vints" ]; then
		fn_info_messages_vints
	elif [ "${shortname}" == "rust" ]; then
		fn_info_messages_rust
	elif [ "${shortname}" == "rw" ]; then
		fn_info_messages_rw
	elif [ "${shortname}" == "ut" ]; then
		fn_info_messages_ut
	elif [ "${shortname}" == "ut2k4" ]; then
		fn_info_messages_ut2k4
	elif [ "${shortname}" == "ut3" ]; then
		fn_info_messages_ut3
	elif [ "${shortname}" == "vpmc" ]; then
		fn_info_messages_vpmc
	elif [ "${shortname}" == "wet" ]; then
		fn_info_messages_wet
	elif [ "${shortname}" == "wf" ]; then
		fn_info_messages_wf
	elif [ "${shortname}" == "wurm" ]; then
		fn_info_messages_wurm
	elif [ "${engine}" == "goldsrc" ]; then
		fn_info_messages_goldsrc
	elif [ "${engine}" == "prism3d" ]; then
		fn_info_messages_prism3d
	elif [ "${engine}" == "source" ]; then
		fn_info_messages_source
	elif [ "${engine}" == "spark" ]; then
		fn_info_messages_spark
	elif [ "${engine}" == "unreal" ]; then
		fn_info_messages_unreal
	else
		fn_print_error_nl "Unable to detect game server."
	fi
}
