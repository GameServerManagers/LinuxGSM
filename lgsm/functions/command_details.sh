#!/bin/bash
# LGSM command_details.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Displays server information.

local commandname="DETAILS"
local commandaction="Details"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Standard Details
# This applies to all engines

fn_details_os(){
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
		echo -e "${blue}Hostname:\t${default}$HOSTNAME"
		echo -e "${blue}tmux:\t${default}${tmuxv}"
		echo -e "${blue}GLIBC:\t${default}${glibcversion}"
	} | column -s $'\t' -t
}

fn_details_performance(){
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

fn_details_disk(){
	#
	# Storage
	# =====================================
	# Filesystem:   /dev/disk/by-uuid/320c8edd-a2ce-4a23-8c9d-e00a7af2d6ff
	# Total:        15G
	# Used:         8.4G
	# Available:    5.7G
	# LGSM Total:	1G
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
		echo -e "${blue}LGSM Total:\t${default}${rootdirdu}"
		echo -e "${blue}Serverfiles:\t${default}${filesdirdu}"
		if [ -d "${backupdir}" ]; then
			echo -e "${blue}Backups:\t${default}${backupdirdu}"
		fi
	} | column -s $'\t' -t
}

fn_details_gameserver(){
	#
	# Quake Live Server Details
	# =====================================
	# Server name:      ql-server
	# Server IP:        1.2.3.4:27960
	# RCON password:    CHANGE_ME
	# Server password:  NOT SET
	# Slots:            16
	# Status:           OFFLINE

	echo -e ""
	echo -e "${lightgreen}${gamename} Server Details${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		# Server name
		if [ -n "${servername}" ]; then
			echo -e "${blue}Server name:\t${default}${servername}"
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

		# Admin password
		if [ -n "${adminpassword}" ]; then
			echo -e "${blue}Admin password:\t${default}${adminpassword}"
		fi

		# Stats password (Quake Live)
		if [ -n "${statspassword}" ]; then
			echo -e "${blue}Stats password:\t${default}${statspassword}"
		fi

		# Slots
		if [ -n "${slots}" ]; then
			echo -e "${blue}Slots:\t${default}${slots}"
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

		# TeamSpeak dbplugin
		if [ -n "${dbplugin}" ]; then
			echo -e "${blue}dbplugin:\t${default}${dbplugin}"
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

fn_details_script(){
	#
	# qlserver Script Details
	# =====================================
	# Service name:        ql-server
	# qlserver version:    150316
	# User:                lgsm
	# Email alert:  off
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
		echo -e "${blue}Update on start:\t${default}${updateonstart}"

		# Script location
		echo -e "${blue}Location:\t${default}${rootdir}"

		# Config file location
		if [ -n "${servercfgfullpath}" ]; then
			if [ -f "${servercfgfullpath}" ]; then
				echo -e "${blue}Config file:\t${default}${servercfgfullpath}"
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

fn_details_backup(){
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
			echo -e "${blue}    date:\t${default}${lastbackupdate}"
			echo -e "${blue}    file:\t${default}${lastbackup}"
			echo -e "${blue}    size:\t${default}${lastbackupsize}"
		} | column -s $'\t' -t
	fi
}

fn_details_commandlineparms(){
	#
	# Command-line Parameters
	# =====================================
	# ./run_server_x86.sh +set net_strict 1

	echo -e ""
	echo -e "${lightgreen}Command-line Parameters${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	echo -e "${executable} ${parms}"
}

fn_details_ports(){
	# Ports
	# =====================================
	# Change ports by editing the parameters in:
	# /home/lgsm/qlserver/serverfiles/baseq3/ql-server.cfg

	echo -e ""
	echo -e "${lightgreen}Ports${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	echo -e "Change ports by editing the parameters in:"

	parmslocation="${red}UNKNOWN${default}"
	# engines that require editing in the config file
	local ports_edit_array=( "avalanche" "dontstarve" "idtech3" "lwjgl2" "projectzomboid" "realvirtuality" "seriousengine35" "teeworlds" "terraria" "unreal" "unreal2" "TeamSpeak 3" "Mumble" "7 Days To Die" )
	for port_edit in "${ports_edit_array[@]}"
	do
		if [ "${engine}" == "${port_edit}" ]||[ "${gamename}" == "${port_edit}" ]; then
			parmslocation="${servercfgfullpath}"
		fi
	done
	# engines that require editing in the script file
	local ports_edit_array=( "starbound" "spark" "source" "goldsource" "Rust" "Hurtworld" "unreal4")
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

fn_details_statusbottom(){
	echo -e ""
	if [ "${status}" == "0" ]; then
		echo -e "${blue}Status:\t${red}OFFLINE${default}"
	else
		echo -e "${blue}Status:\t${green}ONLINE${default}"
	fi
	echo -e ""
}

# Engine Specific details

fn_details_avalanche(){
	echo -e "netstat -atunp | grep Jcmp-Server"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_details_dontstarve(){
	echo -e "netstat -atunp | grep dontstarve"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_details_minecraft(){
	echo -e "netstat -atunp | grep java"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\tudp"
	} | column -s $'\t' -t
}

fn_details_projectzomboid(){
	echo -e "netstat -atunp | grep java"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\tudp"
	} | column -s $'\t' -t
}


fn_details_realvirtuality(){
	echo -e "netstat -atunp | grep arma3server"
	echo -e ""
	if [ -z "${port}" ]||[ -z "${queryport}" ]||[ -z "${masterport}" ]; then
		echo -e "${red}ERROR!${default} Missing/commented ports in ${servercfg}."
		echo -e ""
	fi
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\tudp"
		echo -e "> Steam: Query\tINBOUND\t${queryport}\tudp"
		echo -e "> Steam: Master traffic\tINBOUND\t${masterport}\tudp"
	} | column -s $'\t' -t
}

fn_details_idtech3(){
	echo -e "netstat -atunp | grep qzeroded"
	echo -e ""
	if [ -z "${port}" ]||[ -z "${rconport}" ]||[ -z "${statsport}" ]; then
		echo -e "${red}ERROR!${default} Missing/commented ports in ${servercfg}."
		echo -e ""
	fi
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\tudp"
		echo -e "> Rcon\tINBOUND\t${rconport}\tudp"
		echo -e "> Stats\tINBOUND\t${statsport}\tudp"
	} | column -s $'\t' -t
}


fn_details_seriousengine35(){
	echo -e "netstat -atunp | grep Sam3_Dedicate"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game/RCON\tINBOUND\t${port}\ttcp"
		echo -e "> Query\tINBOUND\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_details_source(){
	echo -e "netstat -atunp | grep srcds_linux"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game/RCON\tINBOUND\t${port}\ttcp/udp"
		if [ -n "${sourcetvport}" ]; then
		        echo -e "> SourceTV\tINBOUND\t${sourcetvport}\tudp"
		fi
		echo -e "< Client\tOUTBOUND\t${clientport}\tudp"
	} | column -s $'\t' -t
}

fn_details_spark(){
	echo -e "netstat -atunp | grep server_linux3"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game/RCON\tINBOUND\t${port}\tudp"
		echo -e "> Query\tINBOUND\t${queryport}\tudp"
		echo -e "> WebAdmin\tINBOUND\t${webadminport}\ttcp"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} WebAdmin${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		echo -e "${blue}WebAdmin url:\t${default}http://${ip}:${webadminport}/index.html"
		echo -e "${blue}WebAdmin username:\t${default}${webadminuser}"
		echo -e "${blue}WebAdmin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
}

fn_details_starbound(){
	echo -e "netstat -atunp | grep starbound"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\ttcp"
		echo -e "> Query\tINBOUND\t${queryport}\ttcp"
		echo -e "> Rcon\tINBOUND\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_details_teamspeak3(){
	echo -e "netstat -atunp | grep ts3server"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Voice\tINBOUND\t${port}\tudp"
		echo -e "> ServerQuery\tINBOUND\t${queryport}\ttcp"
		echo -e "> File transfer\tINBOUND\t${fileport}\ttcp"
	} | column -s $'\t' -t
}

fn_details_mumble(){
	echo -e "netstat -atunp | grep murmur"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Voice\tINBOUND\t${port}\tudp"
		echo -e "> ServerQuery\tINBOUND\t${port}\ttcp"
	} | column -s $'\t' -t
}

fn_details_teeworlds(){
	echo -e "netstat -atunp | grep teeworlds_srv"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\ttcp"
	} | column -s $'\t' -t
}

fn_details_terraria(){
	echo -e "netstat -atunp | grep TerrariaServer"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game\tINBOUND\t${port}\ttcp"
	} | column -s $'\t' -t
}

fn_details_sdtd(){
	echo -e "netstat -atunp | grep 7DaysToDie"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game/RCON\tINBOUND\t${port}\tudp"
		echo -e "> Query\tINBOUND\t${queryport}\tudp"
		echo -e "> WebAdmin\tINBOUND\t${webadminport}\ttcp"
		echo -e "> Telnet\tINBOUND\t${telnetport}\ttcp"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} WebAdmin${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		echo -e "${blue}WebAdmin enabled:\t${default}${webadminenabled}"
		echo -e "${blue}WebAdmin url:\t${default}http://${ip}:${webadminport}"
		echo -e "${blue}WebAdmin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} Telnet${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		echo -e "${blue}Telnet enabled:\t${default}${telnetenabled}"
		echo -e "${blue}Telnet address:\t${default}${ip} ${telnetport}"
		echo -e "${blue}Telnet password:\t${default}${telnetpass}"
	} | column -s $'\t' -t
}

fn_details_hurtworld(){
	echo -e "netstat -atunp | grep Hurtworld"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game/RCON\tINBOUND\t${port}\tudp"
		echo -e "> Query\tINBOUND\t${queryport}\tudp"
	} | column -s $'\t' -t
}

fn_details_rust(){
	echo -e "netstat -atunp | grep Rust"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
		echo -e "> Game/Query\tINBOUND\t${port}\ttcp/udp"
		echo -e "> RCON\tINBOUND\t${rconport}\ttcp"
	} | column -s $'\t' -t
}

fn_details_unreal(){
	echo -e "netstat -atunp | grep ucc-bin"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL\tINI VARIABLE"
		echo -e "> Game\tINBOUND\t${port}\tudp\tPort=${port}"
		echo -e "> Query\tINBOUND\t${queryport}\tudp"
		if [ "${engine}" == "unreal" ]; then
			echo -e "< UdpLink Port (random)\tOUTBOUND\t${udplinkport}+\tudp"
		fi
		if [ "${engine}" != "unreal" ] && [ "${appid}" != "223250" ]; then
			echo -e "> GameSpy query\tINBOUND\t${gsqueryport}\tudp\tOldQueryPortNumber=${gsqueryport}"
		fi
		if [ "${appid}" == "215360" ]; then
			echo -e "< Master server\tOUTBOUND\t28852\ttcp/udp"
		else
			echo -e "< Master server\tOUTBOUND\t28900/28902\ttcp/udp"
		fi
		if [ "${appid}" ]; then
			if [ "${appid}" == "223250" ]; then
				echo -e "< Steam\tOUTBOUND\t20610\tudp"
			else
				echo -e "< Steam\tOUTBOUND\t20660\tudp"
			fi
		fi
		echo -e "> WebAdmin\tINBOUND\t${webadminport}\ttcp\tListenPort=${webadminport}"
	} | column -s $'\t' -t
	echo -e ""
	echo -e "${lightgreen}${servername} WebAdmin${default}"
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	{
		echo -e "${blue}WebAdmin enabled:\t${default}${webadminenabled}"
		echo -e "${blue}WebAdmin url:\t${default}http://${ip}:${webadminport}"
		echo -e "${blue}WebAdmin username:\t${default}${webadminuser}"
		echo -e "${blue}WebAdmin password:\t${default}${webadminpass}"
	} | column -s $'\t' -t
}

fn_details_ark(){
	echo -e "netstat -atunp | grep ShooterGame"
	echo -e ""
	{
		echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL\tINI VARIABLE"
		echo -e "> Game\tINBOUND\t${port}\tudp\tPort=${port}"
		echo -e "> Query\tINBOUND\t${queryport}\tudp"
	} | column -s $'\t' -t
}


# Run checks and gathers details to display.
check.sh
info_config.sh
info_distro.sh
info_glibc.sh
info_parms.sh
fn_details_os
fn_details_performance
fn_details_disk
fn_details_gameserver
fn_details_script
fn_details_backup
# Some game servers do not have parms.
if [ "${gamename}" != "TeamSpeak 3" ]&&[ "${engine}" != "avalanche" ]&&[ "${engine}" != "dontstarve" ]&&[ "${engine}" != "projectzomboid" ]; then
	fn_parms
	fn_details_commandlineparms
fi
fn_details_ports

# Display details depending on game or engine.
if [ "${engine}" == "avalanche" ]; then
	fn_details_avalanche
elif [ "${engine}" == "dontstarve" ]; then
	fn_details_dontstarve
elif [ "${engine}" == "lwjgl2" ]; then
	fn_details_minecraft
elif [ "${engine}" == "projectzomboid" ]; then
	fn_details_projectzomboid
elif [ "${engine}" == "idtech3" ]; then
	fn_details_idtech3
elif [ "${engine}" == "realvirtuality" ]; then
	fn_details_realvirtuality
elif [ "${engine}" == "seriousengine35" ]; then
	fn_details_seriousengine35
elif [ "${engine}" == "source" ]||[ "${engine}" == "goldsource" ]; then
	fn_details_source
elif [ "${engine}" == "spark" ]; then
	fn_details_spark
elif [ "${engine}" == "starbound" ]; then
	fn_details_starbound
elif [ "${engine}" == "teeworlds" ]; then
	fn_details_teeworlds
elif [ "${engine}" == "terraria" ]; then
	fn_details_terraria
elif [ "${engine}" == "unreal" ]||[ "${engine}" == "unreal2" ]; then
	fn_details_unreal
elif [ "${gamename}" == "ARK: Survivial Evolved" ]; then
	fn_details_ark
elif [ "${gamename}" == "Hurtworld" ]; then
	fn_details_hurtworld
elif [ "${gamename}" == "7 Days To Die" ]; then
	fn_details_sdtd
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	fn_details_teamspeak3
elif [ "${gamename}" == "Mumble" ]; then
	fn_details_mumble
elif [ "${gamename}" == "Rust" ]; then
	fn_details_rust
else
	fn_print_error_nl "Unable to detect server engine."
fi

fn_details_statusbottom
core_exit.sh