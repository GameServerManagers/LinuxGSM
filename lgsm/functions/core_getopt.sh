#!/bin/bash
# LinuxGSM core_getopt.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: getopt arguments.

local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

### Define all commands here ###
## User commands | Trigger commands | Description
# Standard commands
cmd_install=( "i;install" "command_install.sh" "Install the server." )
cmd_auto_install=( "ai;auto-install" "command_autoinstall.sh" "Install the server without prompts." )
cmd_start=( "st;start" "command_start.sh" "Start the server." )
cmd_stop=( "sp;stop" "command_stop.sh" "Stop the server." )
cmd_restart=( "r;restart" "command_restart.sh" "Restart the server." )
cmd_details=( "dt;details" "command_details.sh" "Display relevant server information." )
cmd_postdetails=( "pd;postdetails" "command_postdetails.sh" "Post stripped details to pastebin for support." )
cmd_backup=( "b;backup" "command_backup.sh" "Create archives of the server." )
cmd_update_functions=( "uf;update-functions" "command_update_functions.sh" "Update LinuxGSM functions." )
cmd_test_alert=( "ta;test-alert" "command_test_alert.sh" "Send a test alert." )
cmd_monitor=( "m;monitor" "command_monitor.sh" "Check server status and restart it if crashed." )
# Console servers only
cmd_console=( "c;console" "command_console.sh" "Access server console." )
cmd_debug=( "d;debug" "command_debug.sh" "Start server directly in your terminal." )
# Update servers only
cmd_update=( "u;update" "command_update.sh" "Check for updates and apply if available." )
cmd_force_update=( "fu;force-update;update-restart;ur" "forceupdate=1; command_update.sh" "Unconditionally update the server." )
# SteamCMD servers only
cmd_validate=( "v;validate" "command_validate.sh" "Validate server files with SteamCMD." )
# Server with mods-install
cmd_mods_install=( "mi;mods-install" "command_mods_install.sh" "View and install available mods/addons." )
cmd_mods_remove=( "mr;mods-remove" "command_mods_remove.sh" "View and remove an installed mod/addon." )
cmd_mods_update=( "mu;mods-update" "command_mods_update.sh" "Update installed mods/addons." )
# Server specific
cmd_change_password=( "pw;change-password" "command_ts3_server_pass.sh" "Change TS3 serveradmin password." )
cmd_install_default_ressources=( "ir;install-default-ressources" "command_install_resources_mta.sh" "Install the MTA default resources." )
cmd_wipe=( "wi;wipe" "command_wipe.sh" "Wipe your server data." )
cmd_map_compressor_u99=( "mc;map-compressor" "compress_ut99_maps.sh" "Compresses all ${gamename} server maps." )
cmd_map_compressor_u2=( "mc;map-compressor" "compress_unreal2_maps.sh" "Compresses all ${gamename} server maps." )
cmd_install_cdkey=( "cd;server-cd-key" "install_ut2k4_key.sh" "Add your server cd key." )
cmd_install_dst_token=( "ct;cluster-token" "install_dst_token.sh" "Configure cluster token." )
cmd_fastdl=( "fd;fastdl" "command_fastdl.sh" "Build a FastDL directory." )
# Dev commands
cmd_dev_debug=( "dev;dev-debug" "command_dev_debug.sh" "DEVCOMMAND" )
cmd_dev_detect_deps=( "dd;detect-deps" "command_dev_detect_deps.sh" "DEVCOMMAND" )
cmd_dev_detect_glibc=( "dg;detect-glibc" "command_dev_detect_glibc.sh" "DEVCOMMAND" )
cmd_dev_detect_ldd=( "dl;detect-ldd" "command_dev_detect_ldd.sh" "DEVCOMMAND" )

### Set specific opt here ###

## Common opt to all servers

currentopt=( "${cmd_install[@]}" "${cmd_auto_install[@]}" "${cmd_start[@]}" "${cmd_stop[@]}" "${cmd_restart[@]}" "${cmd_details[@]}" )
currentopt+=( "${cmd_backup[@]}" "${cmd_update_functions[@]}" "${cmd_test_alert[@]}" "${cmd_monitor[@]}" )

## Servers that do not have a feature

# Exclude games without a console
if [ "${gamename}" != "TeamSpeak 3" ]; then
	currentopt+=( "${cmd_console[@]}" "${cmd_debug[@]}" )
fi
# Exclude noupdated games here
if [ "${gamename}" != "Battlefield: 1942" ]&&[ "${gamename}" != "Call of Duty" ]&&[ "${gamename}" != "Call of Duty: United Offensive" ]&&[ "${gamename}" != "Call of Duty 2" ]&&[ "${gamename}" != "Call of Duty 4" ]&&[ "${gamename}" != "Call of Duty: World at War" ]&&[ "${gamename}" != "QuakeWorld" ]&&[ "${gamename}" != "Quake 2" ]&&[ "${gamename}" != "Quake 3: Arena" ]&&[ "${gamename}" != "Wolfenstein: Enemy Territory" ]; then
	currentopt+=( "${cmd_update[@]}" "${cmd_force_update[@]}")
fi

## Include games that have access to specific commands
# Validate command
if [ -n "${appid}" ]; then
	currentopt+=( "${cmd_validate[@]}" )
fi
# FastDL command
if [ "${engine}" == "source" ]; then
	currentopt+=( "${cmd_fastdl[@]}" )
fi
# Wipe command
if [ "${gamename}" == "Rust" ]; then
	currentopt+=( "${cmd_wipe[@]}" )
fi
# Mods commands
if [ "${engine}" == "source" ]||[ "${gamename}" == "Rust" ]|[ "${gamename}" == "Hurtworld" ]|[ "${gamename}" == "7 Days To Die" ]; then
	currentopt+=( "${cmd_mods_install[@]}" "${cmd_mods_remove[@]}" "${cmd_mods_update[@]}" )
fi

## Game server exclusive commands
# TeamSpeak exclusive
if [ "${gamename}" == "TeamSpeak 3" ]; then
	currentopt+=( "${cmd_change_password[@]}" )
fi
# Unreal exclusive
if [ "${engine}" == "unreal2" ]; then
	if [ "${gamename}" == "Unreal Tournament 2004" ]; then
		currentopt+=( "${cmd_install_cdkey[@]}" "${cmd_map_compressor_u2[@]}" )
	else
		currentopt+=( "${cmd_map_compressor_u2[@]}" )
	fi
fi
if [ "${engine}" == "unreal" ]; then
	currentopt+=( "${cmd_map_compressor_u99[@]}" )
fi
# DST exclusive
if [ "${gamename}" == "Don't Starve Together" ]; then
	currentopt+=( "${cmd_install_dst_token[@]}" )
fi
# MTA exclusive
if [ "${gamename}" == "Multi Theft Auto" ]; then
	currentopt+=( "${cmd_install_default_ressources[@]}" )
fi

## Developer commands
currentopt+=( "${cmd_dev_debug[@]}" "${cmd_dev_detect_deps[@]}" "${cmd_dev_detect_glibc[@]}" "${cmd_dev_detect_ldd[@]}" )


### Build list of available commands
optcommands=()
index="0"
for ((index="0"; index < ${#currentopt[@]}; index+=3)); do
	cmdamount="$(echo "${currentopt[index]}"| awk -F ';' '{ print NF }')"
	for ((cmdindex=1; cmdindex <= ${cmdamount}; cmdindex++)); do
		optcommands+=( "$(echo "${currentopt[index]}"| awk -F ';' -v x=${cmdindex} '{ print $x }')" )
	done
done

### Check if user command exists or run the command
if [ -z "${getopt}" ]||[[ ! "${optcommands[@]}" =~ "${getopt}" ]]; then
	if [ -n "${getopt}" ]; then
		echo -e "${red}Unknown command${default}: $0 ${getopt}"
		exitcode=2
	fi
	echo "Usage: $0 [option]"
	echo "${gamename} - Linux Game Server Manager - Version ${version}"
	echo "https://gameservermanagers.com/${selfname}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	# Display available commands
	index="0"
	{
	for ((index="0"; index < ${#currentopt[@]}; index+=3)); do
		# Hide developer commands
		if [ "${currentopt[index+3]}" != "DEVCOMMAND" ]; then
			echo -e "${cyan}$(echo "${currentopt[index]}" | awk -F ';' '{ print $2 }')\t${default}$(echo "${currentopt[index]}" | awk -F ';' '{ print $1 }')\t| ${currentopt[index+2]}"
		fi
	done
	} | column -s $'\t' -t
else
	# Seek and run command
	index="0"
	for ((index="0"; index < ${#currentopt[@]}; index+=3)); do
		currcmdamount="$(echo "${currentopt[index]}"| awk -F ';' '{ print NF }')"
		for ((currcmdindex=1; currcmdindex <= ${currcmdamount}; currcmdindex++)); do
			if [ "$(echo "${currentopt[index]}"| awk -F ';' -v x=${currcmdindex} '{ print $x }')" == "${getopt}" ]; then
				# Run command
				${currentopt[index+1]}
				break
			fi
		done	
	done
fi

core_exit.sh
