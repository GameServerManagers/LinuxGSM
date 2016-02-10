#!/bin/bash
# LGSM command_start.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com

# Description: Starts the server.

local modulename="Starting"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_start_teamspeak3(){
check.sh
info_ts3status.sh

if [ "${ts3status}" != "Server is running" ]; then
	# Will check for updates is updateonstart is yes
	if [ "${updateonstart}" == "yes" ]||[ "${updateonstart}" == "1" ]||[ "${updateonstart}" == "on" ]; then
		update_check.sh
	fi	
fi

if [ ! -e "${servercfgfullpath}" ]; then
	fn_printwarn "${servercfgfullpath} is missing"
	fn_scriptlog "${servercfgfullpath} is missing"
	sleep 2
	echo -en "\n"
	echo  "	* Creating blank ${servercfg}"
	fn_scriptlog "Creating blank ${servercfg}"
	sleep 2
	echo  "	* ${servercfg} can remain blank by default."
	fn_scriptlog "${servercfgfullpath} can remain blank by default."
	sleep 2
	echo  "	* ${servercfg} is located in ${servercfgfullpath}."
	fn_scriptlog "${servercfg} is located in ${servercfgfullpath}."
	sleep 5
	touch "${servercfgfullpath}"
fi

logs.sh

fn_printdots "${servername}"
fn_scriptlog "${servername}"
sleep 1

if [ "${ts3status}" == "Server is running" ]; then
	fn_printinfo "${servername} is already running"
	fn_scriptlog "${servername} is already running"
	sleep 1
	echo -en "\n"
	exit
fi

mv "${scriptlog}" "${scriptlogdate}"
# Create lock file
date > "${lgsmdir}/${lockselfname}"
cd "${executabledir}"
if [ "${ts3serverpass}" == "1" ];then
	./ts3server_startscript.sh start serveradmin_password="${newpassword}" 
else
	./ts3server_startscript.sh start inifile="${servercfgfullpath}" > /dev/null 2>&1
fi
sleep 1
info_ts3status.sh
if [ "${ts3status}" = "Server seems to have died" ]||[ "${ts3status}"	= "No server running (ts3server.pid is missing)" ]; then
	fn_printfailnl "Unable to start ${servername}"
	fn_scriptlog "Unable to start ${servername}"
	echo -e "	Check log files: ${lgsmdir}/log"
	exit 1
else
	fn_printok "${servername}"
	fn_scriptlog "Started ${servername}"
fi
sleep 0.5
echo -en "\n"
}

fn_start_tmux(){
check.sh
fix.sh
info_config.sh
fn_parms
logs.sh

tmuxwc=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -v failed|grep -Ec "^${servicename}:")
# Will check for updates if updateonstart is yes
if [ "${tmuxwc}" -eq 0 ]; then
	if [ "${updateonstart}" == "yes" ]||[ "${updateonstart}" == "1" ]||[ "${updateonstart}" == "on" ]; then
		update_check.sh
	fi
fi

fn_printdots "${servername}"
fn_scriptlog "${servername}"
sleep 1

if [ "${tmuxwc}" -eq 0 ]; then
	fn_scriptlog "Rotating log files"
	if [ "${engine}" == "unreal2" ]; then
		mv "${gamelog}" "${gamelogdate}"
	fi
	mv "${scriptlog}" "${scriptlogdate}"
	mv "${consolelog}" "${consolelogdate}"
fi

if [ "${tmuxwc}" -eq 1 ]; then
	fn_printinfo "${servername} is already running"
	fn_scriptlog "${servername} is already running"
	sleep 1
	echo -en "\n"
	exit
fi

# Create lock file
date > "${lgsmdir}/${lockselfname}"
cd "${executabledir}"
tmux new-session -d -s "${servicename}" "${executable} ${parms}" 2> "${scriptlogdir}/.${servicename}-tmux-error.tmp"
# tmux pipe-pane not supported in tmux versions < 1.6
if [ "$(tmux -V|sed "s/tmux //"|sed -n '1 p'|tr -cd '[:digit:]')" -lt "16" ]; then
	echo "Console logging disabled: Tmux => 1.6 required" >> "${consolelog}"
	echo "http://gameservermanagers.com/tmux-upgrade" >> "${consolelog}"
	echo "Currently installed: $(tmux -V)" >> "${consolelog}"
elif [ "$(tmux -V|sed "s/tmux //"|sed -n '1 p'|tr -cd '[:digit:]')" -eq "18" ]; then
	echo "Console logging disabled: Bug in tmux 1.8 breaks logging" >> "${consolelog}"
	echo "http://gameservermanagers.com/tmux-upgrade" >> "${consolelog}"
	echo "Currently installed: $(tmux -V)" >> "${consolelog}"
else
	touch "${consolelog}"
	tmux pipe-pane -o -t "${servicename}" "exec cat >> '${consolelog}'"
fi
sleep 1
tmuxwc=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -Ec "^${servicename}:")
# If the server fails to start
if [ "${tmuxwc}" -eq 0 ]; then
	fn_printfailnl "Unable to start ${servername}"
	fn_scriptlog "Unable to start ${servername}"
	sleep 1
	if [ -s "${scriptlogdir}/.${servicename}-tmux-error.tmp" ]; then
		fn_printfailnl "Unable to start ${servername}: Tmux error:"
		fn_scriptlog "Tmux error"
		sleep 1
		echo -en "\n"
		echo ""
		echo "Command"
		echo "================================="
		echo "tmux new-session -d -s \"${servicename}\" \"${executable} ${parms}\""
		echo "tmux new-session -d -s \"${servicename}\" \"${executable} ${parms}\"" >> "${scriptlog}"
		echo ""
		echo "Error"
		echo "================================="
		cat "${scriptlogdir}/.${servicename}-tmux-error.tmp"
		cat "${scriptlogdir}/.${servicename}-tmux-error.tmp" >> "${scriptlog}"

		# Detected error http://gameservermanagers.com/issues
		if [ $(grep -c "Operation not permitted" "${scriptlogdir}/.${servicename}-tmux-error.tmp") ]; then
		echo ""
		echo "Fix"
		echo "================================="
			if [ ! $(grep "tty:" /etc/group|grep "$(whoami)") ]; then
				echo "$(whoami) is not part of the tty group."
				fn_scriptlog "$(whoami) is not part of the tty group."
				group=$(grep tty /etc/group)
				echo ""
				echo "	${group}"
				fn_scriptlog "${group}"
				echo ""
				echo "Run the following command with root privileges."
				echo ""
				echo "	usermod -G tty $(whoami)"
				echo ""
				echo "http://gameservermanagers.com/tmux-op-perm"
				fn_scriptlog "http://gameservermanagers.com/tmux-op-perm"
			else
				echo "No known fix currently. Please log an issue."
				fn_scriptlog "No known fix currently. Please log an issue."
				echo "http://gameservermanagers.com/issues"
				fn_scriptlog "http://gameservermanagers.com/issues"
			fi
		fi
	fi
exit 1	
else
	fn_printok "${servername}"
	fn_scriptlog "Started ${servername}"
fi
rm "${scriptlogdir}/.${servicename}-tmux-error.tmp"
echo -en "\n"
}

if [ "${gamename}" == "Teamspeak 3" ]; then
	fn_start_teamspeak3
else
	fn_start_tmux
fi
