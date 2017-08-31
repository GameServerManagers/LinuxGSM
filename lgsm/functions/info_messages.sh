#!/bin/bash
# LinuxGSM info_messages.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Defines server info messages for details, alerts.

# Standard Details
# This applies to all engines

info_message_head(){
	{
		echo -e ""
		echo -e "Summery"
		echo -e "================================="
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
		echo -e ""
		echo -e "More info"
		echo -e "${alerturl}"
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${emaillog}" > /dev/null 2>&1
}

info_message_distro(){
	#
	# Distro Details
	# =====================================
	# Distro:    Ubuntu 14.04.4 LTS
	# Arch:      x86_64
	# Kernel:    3.13.0-79-generic
	# Hostname:  hostname
	# tmux:      tmux 1.8
	# GLIBC:     2.19

	echo -e ""
	echo -e "${lightyellow}Distro Details${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		echo -e "${blue}Distro:\t${default}${distroname}"
		echo -e "${blue}Arch:\t${default}${arch}"
		echo -e "${blue}Kernel:\t${default}${kernel}"
		echo -e "${blue}Hostname:\t${default}${HOSTNAME}"
		echo -e "${blue}tmux:\t${default}${tmuxv}"
		echo -e "${blue}GLIBC:\t${default}${glibcversion}"
	} | column -s $'\t' -t
}

info_message_performance(){
	#
	# Performance
	# =====================================
	# Uptime:    55d, 3h, 38m
	# Avg Load:  1.00, 1.01, 0.78
	#
	# Mem:       total   used   free  cached
	# Physical:  741M    656M   85M   256M
	# Swap:      0B      0B     0B

	echo -e ""
	echo -e "${lightyellow}Performance${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		echo -e "${blue}Uptime:\t${default}${days}d, ${hours}h, ${minutes}m"
		echo -e "${blue}Avg Load:\t${default}${load}"
	} | column -s $'\t' -t
	echo -e ""
	{
		echo -e "${blue}Mem:\t${blue}total\t used\t free\t cached${default}"
		echo -e "${blue}Physical:\t${default}${physmemtotal}\t${physmemused}\t${physmemfree}\t${physmemcached}${default}"
		echo -e "${blue}Swap:\t${default}${swaptotal}\t${swapused}\t${swapfree}${default}"
	} | column -s $'\t' -t
}

info_message_disk(){
	#
	# Storage
	# =====================================
	# Filesystem:   /dev/disk/by-uuid/320c8edd-a2ce-4a23-8c9d-e00a7af2d6ff
	# Total:        15G
	# Used:         8.4G
	# Available:    5.7G
	# LinuxGSM Total:	1G
	# Serverfiles:  961M
	# Backups:  	2G

	echo -e ""
	echo -e "${lightyellow}Storage${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		echo -e "${blue}Filesystem:\t${default}${filesystem}"
		echo -e "${blue}Total:\t${default}${totalspace}"
		echo -e "${blue}Used:\t${default}${usedspace}"
		echo -e "${blue}Available:\t${default}${availspace}"
		echo -e "${blue}LinuxGSM Total:\t${default}${rootdirdu}"
		echo -e "${blue}Serverfiles:\t${default}${serverfilesdu}"
		if [ -d "${backupdir}" ]; then
			echo -e "${blue}Backups:\t${default}${backupdirdu}"
		fi
	} | column -s $'\t' -t
}

info_message_gameserver(){
	#
	# Quake Live Server Details
	# =====================================
	# Server name:      ql-server
	# Server IP:        1.2.3.4:27960
	# RCON password:    CHANGE_ME
	# Server password:  NOT SET
	# Maxplayers:		16
	# Status:           OFFLINE

	echo -e ""
	echo -e "${lightgreen}${gamename} Server Details${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		# Server name
		if [ -n "${servername}" ]; then
			echo -e "${blue}Server name:\t${default}${servername}"
		fi

		# Branch
		if [ -n "${branch}" ]; then
			echo -e "${blue}Branch:\t${default}${branch}"
		fi

		# Server ip
		echo -e "${blue}Server IP:\t${default}${ip}:${port}"

		# Server password
		if [ -n "${serverpassword}" ]; then
			echo -e "${blue}Server password:\t${default}${serverpassword}"
		fi

		# RCON password
		if [ -n "${rconpassword}" ]; then
			echo -e "${blue}RCON password:\t${default}${rconpassword}"
		fi

		# RCON web (Rust)
		if [ -n "${rconweb}" ]; then
			echo -e "${blue}RCON web:\t${default}${rconweb}"
		fi

		# Admin password
		if [ -n "${adminpassword}" ]; then
			echo -e "${blue}Admin password:\t${default}${adminpassword}"
		fi

		# Stats password (Quake Live)
		if [ -n "${statspassword}" ]; then
			echo -e "${blue}Stats password:\t${default}${statspassword}"
		fi

		# Maxplayers
		if [ -n "${maxplayers}" ]; then
			echo -e "${blue}Maxplayers:\t${default}${maxplayers}"
		fi

		# Game mode
		if [ -n "${gamemode}" ]; then
			echo -e "${blue}Game mode:\t${default}${gamemode}"
		fi

		# Game world
		if [ -n "${gameworld}" ]; then
			echo -e "${blue}Game world:\t${default}${gameworld}"
		fi

		# Tick rate
		if [ -n "${tickrate}" ]; then
			echo -e "${blue}Tick rate:\t${default}${tickrate}"
		fi

		# Sharding (Don't Starve Together)
		if [ -n "${sharding}" ]; then
			echo -e "${blue}Sharding:\t${default}${sharding}"
		fi

		# Master (Don't Starve Together)
		if [ -n "${master}" ]; then
			echo -e "${blue}Master:\t${default}${master}"
		fi

		# Shard (Don't Starve Together)
		if [ -n "${shard}" ]; then
			echo -e "${blue}Shard:\t${default}${shard}"
		fi

		# Cluster (Don't Starve Together)
		if [ -n "${cluster}" ]; then
			echo -e "${blue}Cluster:\t${default}${cluster}"
		fi

		# Cave (Don't Starve Together)
		if [ -n "${cave}" ]; then
			echo -e "${blue}Cave:\t${default}${cave}"
		fi

		# Creativemode (Hurtworld)
		if [ -n "${creativemode}" ]; then
			echo -e "${blue}Creativemode:\t${default}${creativemode}"
		fi

		# TeamSpeak dbplugin
		if [ -n "${dbplugin}" ]; then
			echo -e "${blue}dbplugin:\t${default}${dbplugin}"
		fi

		# ASE (Multi Theft Auto)
		if [ -n "${ase}" ]; then
			echo -e "${blue}ASE:\t${default}${ase}"
		fi

		# Save interval (Rust)
		if [ -n "${saveinterval}" ]; then
			echo -e "${blue}ASE:\t${default}${saveinterval} s"
		fi

		# Random map rotation mode (Squad)
		if [ -n "${randommap}" ]; then
			echo -e "${blue}Map rotation:\t${default}${randommap}"
		fi

		# Online status
		if [ "${status}" == "0" ]; then
			echo -e "${blue}Status:\t${red}OFFLINE${default}"
		else
			echo -e "${blue}Status:\t${green}ONLINE${default}"
		fi
	} | column -s $'\t' -t
	echo -e ""
}

info_message_script(){
	#
	# qlserver Script Details
	# =====================================
	# Service name:        ql-server
	# qlserver version:    150316
	# User:                lgsm
	# Email alert:         off
	# Update on start:     off
	# Location:            /home/lgsm/qlserver
	# Config file:         /home/lgsm/qlserver/serverfiles/baseq3/ql-server.cfg

	echo -e "${lightgreen}${selfname} Script Details${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		# Service name
		echo -e "${blue}Service name:\t${default}${servicename}"

		# Script version
		if [ -n "${version}" ]; then
			echo -e "${blue}${selfname} version:\t${default}${version}"
		fi

		# User
		echo -e "${blue}User:\t${default}$(whoami)"

		# GLIBC required
		if [ -n "${glibcrequired}" ]; then
			if [ "${glibcrequired}" == "NOT REQUIRED" ]; then
					:
			elif [ "${glibcrequired}" == "UNKNOWN" ]; then
				echo -e "${blue}GLIBC required:\t${red}${glibcrequired}"
			elif [ "$(printf '%s\n'${glibcrequired}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibcrequired}" ]; then
				if [ "${glibcfix}" == "yes" ]; then
					echo -e "${blue}GLIBC required:\t${red}${glibcrequired} ${default}(${green}Using GLIBC fix${default})"
				else
					echo -e "${blue}GLIBC required:\t${red}${glibcrequired} ${default}(${red}GLIBC version too old${default})"
				fi
			else
				echo -e "${blue}GLIBC required:\t${green}${glibcrequired}${default}"
			fi
		fi

		# Email alert
		echo -e "${blue}Email alert:\t${default}${emailalert}"

		# Pushbullet alert
		echo -e "${blue}Pushbullet alert:\t${default}${pushbulletalert}"

		# Update on start
		if [ -n "${updateonstart}" ]; then
			echo -e "${blue}Update on start:\t${default}${updateonstart}"
		fi

		# Script location
		echo -e "${blue}Location:\t${default}${rootdir}"

		# Config file location
		if [ -n "${servercfgfullpath}" ]; then
			if [ -f "${servercfgfullpath}" ]; then
				echo -e "${blue}Config file:\t${default}${servercfgfullpath}"
			elif [ -d "${servercfgfullpath}" ]; then
				echo -e "${blue}Config dir:\t${default}${servercfgfullpath}"
			else
				echo -e "${blue}Config file:\t${default}${red}${servercfgfullpath}${default} (${red}FILE MISSING${default})"
			fi
		fi

		# Network config file location (ARMA 3)
		if [ -n "${networkcfgfullpath}" ]; then
			echo -e "${blue}Network config file:\t${default}${networkcfgfullpath}"
		fi
	} | column -s $'\t' -t
}

info_message_backup(){
	#
	# Backups
	# =====================================
	# No. of backups:    1
	# Latest backup:
	#     date:          Fri May  6 18:34:19 UTC 2016
	#     file:          /home/lgsm/qlserver/backups/ql-server-2016-05-06-183239.tar.gz
	#     size:          945M

	echo -e ""
	echo -e "${lightgreen}Backups${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	if [ ! -d "${backupdir}" ]||[ "${backupcount}" == "0" ]; then
		echo -e "No Backups created"
	else
		{
			echo -e "${blue}No. of backups:\t${default}${backupcount}"
			echo -e "${blue}Latest backup:${default}"
			if [ "${lastbackupdaysago}" == "0" ]; then
				echo -e "${blue}    date:\t${default}${lastbackupdate} (less than 1 day ago)"
			elif [ "${lastbackupdaysago}" == "1" ]; then
				echo -e "${blue}    date:\t${default}${lastbackupdate} (1 day ago)"
			else
				echo -e "${blue}    date:\t${default}${lastbackupdate} (${lastbackupdaysago} days ago)"
			fi
			echo -e "${blue}    file:\t${default}${lastbackup}"
			echo -e "${blue}    size:\t${default}${lastbackupsize}"
		} | column -s $'\t' -t
	fi
}

info_message_commandlineparms(){
	#
	# Command-line Parameters
	# =====================================
	# ./run_server_x86.sh +set net_strict 1

	echo -e ""
	echo -e "${lightgreen}Command-line Parameters${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	echo -e "${executable} ${parms}"
}

info_message_ports(){
	# Ports
	# =====================================
	# Change ports by editing the parameters in:
	# /home/lgsm/qlserver/serverfiles/baseq3/ql-server.cfg

	echo -e ""
	echo -e "${lightgreen}Ports${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	echo -e "Change ports by editing the parameters in:"

	parmslocation="${red}UNKNOWN${default}"
	# engines/games that require editing in the config file
	local ports_edit_array=( "avalanche" "Ballistic Overkill" "dontstarve" "idtech2" "idtech3" "idtech3_ql" "lwjgl2" "Project Cars" "projectzomboid" "quake" "refractor" "realvirtuality" "renderware" "seriousengine35" "teeworlds" "terraria" "unreal" "unreal2" "unreal3" "TeamSpeak 3" "Mumble" "7 Days To Die" )
	for port_edit in "${ports_edit_array[@]}"
	do
		if [ "${engine}" == "${port_edit}" ]||[ "${gamename}" == "${port_edit}" ]; then
			parmslocation="${servercfgfullpath}"
		fi
	done
	# engines/games that require editing in the script file
	local ports_edit_array=( "goldsource" "Factorio" "Hurtworld" "iw3.0"  "Rust" "spark" "source" "starbound" "unreal4" "realvirtuality")
	for port_edit in "${ports_edit_array[@]}"
	do
		if [ "${engine}" == "${port_edit}" ]||[ "${gamename}" == "${port_edit}" ]; then
			parmslocation="${selfname}"
		fi
	done
	echo -e "${parmslocation}"
	echo -e ""
	echo -e "Useful port diagnostic command:"
}

info_message_statusbottom(){
	echo -e ""
	if [ "${status}" == "0" ]; then
		echo -e "${blue}Status:\t${red}OFFLINE${default}"
	else
		echo -e "${blue}Status:\t${green}ONLINE${default}"
	fi
	echo -e ""
}