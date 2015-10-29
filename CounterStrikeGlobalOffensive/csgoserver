#!/bin/bash
# Counter Strike: Global Offensive
# Server Management Script
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
version="291015"

#### Variables ####

# Notification Email
# (on|off)
emailnotification="off"
email="email@example.com"

# Steam login
steamuser="anonymous"
steampass=""

# Start Variables
# https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#Starting_the_Server
# [Game Modes]           gametype    gamemode
# Arms Race                  1            0
# Classic Casual             0            0
# Classic Competitive        0            1
# Demolition                 1            1
# Deathmatch                 1            2
gamemode="0"
gametype="0"
defaultmap="de_dust2"
mapgroup="random_classic"
maxplayers="16"
tickrate="64"
port="27015"
sourcetvport="27020"
clientport="27005"
ip="0.0.0.0"
updateonstart="off"
# Optional: Workshop Parameters
# https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators
# To get an authkey visit - http://steamcommunity.com/dev/apikey
# authkey=""
# ws_collection_id=""
# ws_start_map=""

# https://developer.valvesoftware.com/wiki/Command_Line_Options#Source_Dedicated_Server
fn_parms(){
parms="-game csgo -usercon -strictportbind -ip ${ip} -port ${port} +clientport ${clientport} +tv_port ${sourcetvport} -tickrate ${tickrate} +map ${defaultmap} +servercfgfile ${servercfg} -maxplayers_override ${maxplayers} +mapgroup ${mapgroup} +game_mode ${gamemode} +game_type ${gametype} +host_workshop_collection ${ws_collection_id} +workshop_start_map ${ws_start_map} -authkey ${authkey}"
}

#### Advanced Variables ####

# Steam
appid="740"

# Server Details
servicename="csgo-server"
gamename="Counter Strike: Global Offensive"
engine="source"

# Directories
rootdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
selfname="$(basename $0)"
lockselfname=".${servicename}.lock"
filesdir="${rootdir}/serverfiles"
systemdir="${filesdir}/csgo"
executabledir="${filesdir}"
executable="./srcds_run"
servercfg="${servicename}.cfg"
servercfgdir="${systemdir}/cfg"
servercfgfullpath="${servercfgdir}/${servercfg}"
servercfgdefault="${servercfgdir}/lgsm-default.cfg"
backupdir="${rootdir}/backups"

# Logging
logdays="7"
gamelogdir="${systemdir}/logs"
scriptlogdir="${rootdir}/log/script"
consolelogdir="${rootdir}/log/console"

scriptlog="${scriptlogdir}/${servicename}-script.log"
consolelog="${consolelogdir}/${servicename}-console.log"
emaillog="${scriptlogdir}/${servicename}-email.log"

scriptlogdate="${scriptlogdir}/${servicename}-script-$(date '+%d-%m-%Y-%H-%M-%S').log"
consolelogdate="${consolelogdir}/${servicename}-console-$(date '+%d-%m-%Y-%H-%M-%S').log"

##### Script #####
# Do not edit

fn_runfunction(){
# Functions are downloaded and run with this function
if [ ! -f "${rootdir}/functions/${functionfile}" ]; then
	cd "${rootdir}"
	if [ ! -d "functions" ]; then
		mkdir functions
	fi
	cd functions
	echo -e "    loading ${functionfile}...\c"
	wget -N /dev/null https://raw.githubusercontent.com/dgibbs64/linuxgsm/master/functions/${functionfile} 2>&1 | grep -F HTTP | cut -c45-
	chmod +x "${functionfile}"
	cd "${rootdir}"
fi
source "${rootdir}/functions/${functionfile}"
}

fn_functions(){
# Functions are defined in fn_functions.
functionfile="${FUNCNAME}"
fn_runfunction
}

fn_functions

getopt=$1
fn_getopt
