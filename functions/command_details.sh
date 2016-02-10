#!/bin/bash
# LGSM command_details.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com

# Description: Displays server infomation.

function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

# Standard Details
# This applies to all engines

fn_details_os(){
echo -e ""
echo -e "\e[93mDistro Details\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	echo -e "\e[34mDistro:\t\e[0m${os}"
	echo -e "\e[34mArch:\t\e[0m${arch}"
	echo -e "\e[34mKernel:\t\e[0m${kernel}"
	echo -e "\e[34mHostname:\t\e[0m$HOSTNAME"
	echo -e "\e[34mtmux:\t\e[0m${tmuxv}"
	echo -e "\e[34mGLIBC:\t\e[0m${glibcv}"
} | column -s $'\t' -t 
}

fn_details_performance(){
echo -e ""
echo -e "\e[93mPerformance\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	echo -e "\e[34mUptime:\t\e[0m${days}d, ${hours}h, ${minutes}m"
	echo -e "\e[34mAvg Load:\t\e[0m${load}"
} | column -s $'\t' -t 
echo -e ""
{
	echo -e "\e[34mMem:\t\e[34mtotal\t used\t free\e[0m"
	echo -e "\e[34mPhysical:\t\e[0m${physmemtotal}\t${physmemused}\t${physmemfree}\e[0m"
	echo -e "\e[34mSwap:\t\e[0m${swaptotal}\t${swapused}\t${swapfree}\e[0m"
} | column -s $'\t' -t 
}

fn_details_disk(){
echo -e ""
echo -e "\e[93mStorage\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	echo -e "\e[34mFilesystem:\t\e[0m${filesystem}"
	echo -e "\e[34mTotal:\t\e[0m${totalspace}"
	echo -e "\e[34mUsed:\t\e[0m${usedspace}"
	echo -e "\e[34mAvailable:\t\e[0m${availspace}"
	echo -e "\e[34mServerfiles:\t\e[0m${filesdirdu}"
	if [ -d "${backupdir}" ]; then
		echo -e "\e[34mBackups:\t\e[0m${backupdirdu}"
	fi
} | column -s $'\t' -t 
}

fn_details_gameserver(){
echo -e ""

## server details
echo -e "\e[92m${gamename} Server Details\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	# server name
	echo -e "\e[34mServer name:\t\e[0m${servername}"

	# server ip
	echo -e "\e[34mServer IP:\t\e[0m${ip}:${port}"

	# rcon password
	if [ -n "${rconpassword}" ]; then
		echo -e "\e[34mRCON password:\t\e[0m${rconpassword}"
	fi

	# server password
	if [ -n "${serverpassword}" ]; then
		echo -e "\e[34mServer password:\t\e[0m${serverpassword}"
	fi

	# admin password
	if [ -n "${adminpassword}" ]; then
		echo -e "\e[34mAdmin password:\t\e[0m${adminpassword}"
	fi

	# slots
	if [ -n "${slots}" ]; then
		echo -e "\e[34mSlots:\t\e[0m${slots}"
	fi

	# game mode
	if [ -n "${gamemode}" ]; then
		echo -e "\e[34mGame mode:\t\e[0m${gamemode}"
	fi

	# game world
	if [ -n "${gameworld}" ]; then
		echo -e "\e[34mGame world:\t\e[0m${gameworld}"
	fi

	# tick rate
	if [ -n "${tickrate}" ]; then
		echo -e "\e[34mTick rate:\t\e[0m${tickrate}"
	fi

	# online status
	if [ "${gamename}" == "Teamspeak 3" ]; then
		info_ts3status.sh
		if [ "${ts3status}" = "Server seems to have died" ]||[ "${ts3status}"	= "No server running (ts3server.pid is missing)" ]; then
			echo -e "\e[34mStatus:\t\e[0;31mOFFLINE\e[0m"
		else
			echo -e "\e[34mStatus:\t\e[0;32mONLINE\e[0m"
		fi
	else
		pid=$(tmux list-sessions 2>&1 | awk '{print $1}' | grep -Ec "^${servicename}:")
		if [ "${pid}" == "0" ]; then
			echo -e "\e[34mStatus:\t\e[0;31mOFFLINE\e[0m"
		else
			echo -e "\e[34mStatus:\t\e[0;32mONLINE\e[0m"
		fi
	fi

	# teamspeak dbplugin
	if [ -n "${dbplugin}" ]; then
		echo -e "\e[34mdbplugin:\t\e[0m${dbplugin}"
	fi
} | column -s $'\t' -t 
echo -e ""

## script details
echo -e "\e[92m${selfname} Script Details\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	# service name
	echo -e "\e[34mService name:\t\e[0m${servicename}"

	# script version
	if [ -n "${version}" ]; then
		echo -e "\e[34m${selfname} version:\t\e[0m${version}"
	fi

	# script user
	echo -e "\e[34mUser:\t\e[0m$(whoami)"

	# GLIBC required
	if [ -n "${glibcrequired}" ]; then
		if [ "$(ldd --version | sed -n '1 p' | tr -cd '[:digit:]' | tail -c 3)" -lt "$(echo "${glibcrequired}" | sed -n '1 p' | tr -cd '[:digit:]' | tail -c 3)" ]; then
			if [ "${glibcfix}" == "yes" ]; then
				echo -e "\e[34mGLIBC required:\t\e[0;31m${glibcrequired} \e[0m(\e[0;32mUsing GLIBC fix\e[0m)"
			else
				echo -e "\e[34mGLIBC required:\t\e[0;31m${glibcrequired}\e[0m(\e[0;32mGLIBC version too old\e[0m)"
			fi
		else
			echo -e "\e[34mGLIBC required:\t\e[0;32m${glibcrequired}\e[0m"
		fi
	fi

	# email notification
	if [ -n "${emailnotification}" ]; then
		echo -e "\e[34mEmail notification:\t\e[0m${emailnotification}"
	fi

	# update on start
	if [ -n "${updateonstart}" ]; then
		echo -e "\e[34mUpdate on start:\t\e[0m${updateonstart}"
	fi

	# script location
	echo -e "\e[34mLocation:\t\e[0m${rootdir}"

	# config file location
	if [ -n "${servercfgfullpath}" ]; then
		echo -e "\e[34mConfig file:\t\e[0m${servercfgfullpath}"
	fi

	# network config file location (ARMA 3)
	if [ -n "${networkcfgfullpath}" ]; then
		echo -e "\e[34mNetwork config file:\t\e[0m${networkcfgfullpath}"
	fi
} | column -s $'\t' -t 
}

fn_details_backup(){
echo -e ""
echo -e "\e[92mBackups\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
if [ ! -d "${backupdir}" ]||[ "${backupcount}" == "0" ]; then
	echo -e "No Backups created"
else
	{
		echo -e "\e[34mNo. of backups:\t\e[0m${backupcount}"
		echo -e "\e[34mLatest backup:\e[0m"
		echo -e "\e[34m    date:\t\e[0m${lastbackupdate}"
		echo -e "\e[34m    file:\t\e[0m${lastbackup}"
		echo -e "\e[34m    size:\t\e[0m${lastbackupsize}"
	} | column -s $'\t' -t 
fi
}

fn_details_commandlineparms(){
echo -e ""
echo -e "\e[92mCommand-line Parameters\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "${executable} ${parms}"
}

fn_details_statusbottom(){
echo -e ""
if [ "${gamename}" == "Teamspeak 3" ]; then
	if [ "${ts3status}" = "Server seems to have died" ]||[ "${ts3status}"	= "No server running (ts3server.pid is missing)" ]; then
        echo -e "\e[34mStatus: \e[0;31mOFFLINE\e[0m"
	else
		echo -e "\e[34mStatus: \e[0;32mONLINE\e[0m"
	fi
else
	pid=$(tmux list-sessions 2>&1 | awk '{print $1}' | grep -Ec "^${servicename}:")
	if [ "${pid}" == "0" ]; then
		echo -e "\e[34mStatus: \e[0;31mOFFLINE\e[0m"
	else
		echo -e "\e[34mStatus: \e[0;32mONLINE\e[0m"
	fi
fi
echo -e ""
}

# Engine Specific details

fn_details_avalanche(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep Jcmp-Server"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game\tINBOUND\t${port}\tudp"
} | column -s $'\t' -t 

fn_details_statusbottom
}

fn_details_dontstarve(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep dontstarve"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game\tINBOUND\t${port}\tudp"
} | column -s $'\t' -t 

fn_details_statusbottom
}

fn_details_projectzomboid(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep java"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game\tINBOUND\t${port}\tudp"
} | column -s $'\t' -t 

fn_details_statusbottom
}


fn_details_realvirtuality(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep arma3server"
echo -e ""
if [ -z "${port}" ]||[ -z "${queryport}" ]||[ -z "${masterport}" ]; then
	echo -e "\e[0;31mERROR!\e[0m Missing/commented ports in ${servercfg}."
	echo -e ""
fi
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game\tINBOUND\t${port}\tudp"
	echo -e "> Steam: Query\tINBOUND\t${queryport}\tudp"
	echo -e "> Steam: Master traffic\tINBOUND\t${masterport}\tudp"
} | column -s $'\t' -t 

fn_details_statusbottom
}

fn_details_seriousengine35(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep Sam3_Dedicate"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game/RCON\tINBOUND\t${port}\ttcp"
	echo -e "> Query\tINBOUND\t${queryport}\tudp"
} | column -s $'\t' -t 

fn_details_statusbottom
}

fn_details_source(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the command-line"
echo -e "parameters in ${selfname}."
echo -e ""
echo -e "Useful port diagnostic command:"
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

fn_details_statusbottom
}

fn_details_spark(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the command-line"
echo -e "parameters in ${selfname}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep server_linux3"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game/RCON\tINBOUND\t${port}\tudp"
	echo -e "> Query\tINBOUND\t${queryport}\tudp"
	echo -e "> WebAdmin\tINBOUND\t${webadminport}\ttcp"
} | column -s $'\t' -t
echo -e ""
echo -e "\e[92m${servername} WebAdmin\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	echo -e "\e[34mWebAdmin url:\t\e[0mhttp://${ip}:${webadminport}/index.html"
	echo -e "\e[34mWebAdmin username:\t\e[0m${webadminuser}"
	echo -e "\e[34mWebAdmin password:\t\e[0m${webadminpass}"
} | column -s $'\t' -t

fn_details_statusbottom
}

fn_details_starbound(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the command-line"
echo -e "parameters in ${selfname}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep starbound"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game\tINBOUND\t${port}\ttcp"
	echo -e "> Query\tINBOUND\t${queryport}\ttcp"
	echo -e "> Rcon\tINBOUND\t${rconport}\ttcp"
} | column -s $'\t' -t

fn_details_statusbottom

}

fn_details_teamspeak3(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep ts3server"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Voice\tINBOUND\t${port}\tudp"
	echo -e "> ServerQuery\tINBOUND\t${queryport}\ttcp"
	echo -e "> File transfer\tINBOUND\t${fileport}\ttcp"
} | column -s $'\t' -t

fn_details_statusbottom
}

fn_details_teeworlds(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the command-line"
echo -e "parameters in ${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep teeworlds_srv"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game\tINBOUND\t${port}\ttcp"
} | column -s $'\t' -t

fn_details_statusbottom
}

fn_details_terraria(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the command-line"
echo -e "parameters in ${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep terraia"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game\tINBOUND\t${port}\ttcp"
	echo -e "> Query\tINBOUND\t${queryport}\ttcp"
	echo -e "> Rcon\tINBOUND\t${rconport}\ttcp"
} | column -s $'\t' -t

fn_details_statusbottom
}

fn_details_sdtd(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
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
echo -e "\e[92m${servername} WebAdmin\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	echo -e "\e[34mWebAdmin enabled:\t\e[0m${webadminenabled}"
	echo -e "\e[34mWebAdmin url:\t\e[0mhttp://${ip}:${webadminport}"
	echo -e "\e[34mWebAdmin password:\t\e[0m${webadminpass}"
} | column -s $'\t' -t
echo -e ""
echo -e "\e[92m${servername} Telnet\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	echo -e "\e[34mTelnet enabled:\t\e[0m${telnetenabled}"
	echo -e "\e[34mTelnet address:\t\e[0m${ip} ${telnetport}"
	echo -e "\e[34mTelnet password:\t\e[0m${telnetpass}"
} | column -s $'\t' -t

fn_details_statusbottom
}

fn_details_hurtworld(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "hwserver script"
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep Hurtworld"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL"
	echo -e "> Game/RCON\tINBOUND\t${port}\tudp"
	echo -e "> Query\tINBOUND\t${queryport}\tudp"

} | column -s $'\t' -t
echo -e ""

fn_details_statusbottom
}

fn_details_unreal(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
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
echo -e "\e[92m${servername} WebAdmin\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
{
	echo -e "\e[34mWebAdmin enabled:\t\e[0m${webadminenabled}"
	echo -e "\e[34mWebAdmin url:\t\e[0mhttp://${ip}:${webadminport}"
	echo -e "\e[34mWebAdmin username:\t\e[0m${webadminuser}"
	echo -e "\e[34mWebAdmin password:\t\e[0m${webadminpass}"
} | column -s $'\t' -t

fn_details_statusbottom
}

fn_details_ark(){
echo -e ""
echo -e "\e[92mPorts\e[0m"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "Change ports by editing the parameters in"
echo -e "${servercfgfullpath}."
echo -e ""
echo -e "Useful port diagnostic command:"
echo -e "netstat -atunp | grep ShooterGame"
echo -e ""
{
	echo -e "DESCRIPTION\tDIRECTION\tPORT\tPROTOCOL\tINI VARIABLE"
	echo -e "> Game\tINBOUND\t${port}\tudp\tPort=${port}"
	echo -e "> Query\tINBOUND\t${queryport}\tudp"
} | column -s $'\t' -t

fn_details_statusbottom
}


# Run checks and gathers details to display.
check.sh 
info_config.sh
info_distro.sh
info_glibc.sh
fn_details_os
fn_details_performance
fn_details_gameserver
fn_details_backup
# Some game servers do not have parms.
if [ "${gamename}" != "Teamspeak 3" ]||[ "${engine}" != "avalanche" ]||[ "${engine}" != "dontstarve" ]||[ "${engine}" == "projectzomboid" ]; then
	fn_parms
	fn_details_commandlineparms
fi


# Display details depending on game or engine.
if [ "${engine}" == "avalanche" ]; then
	fn_details_avalanche
elif [ "${engine}" == "dontstarve" ]; then
		fn_details_dontstarve
elif [ "${engine}" == "projectzomboid" ]; then
	fn_details_projectzomboid
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
elif [ "${gamename}" == "Teamspeak 3" ]; then
	fn_details_teamspeak3
else
	fn_printerrornl "Unable to detect server engine."
fi
