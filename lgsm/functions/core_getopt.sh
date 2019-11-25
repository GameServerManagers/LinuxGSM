#!/bin/bash
# LinuxGSM core_getopt.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: getopt arguments.

local function_selfname=$(basename "$(readlink -f "${BASH_SOURCE[0]}")")

### Define all commands here.
## User commands | Trigger commands | Description
# Standard commands.
cmd_install=( "i;install" "command_install.sh" "Install the server." )
cmd_auto_install=( "ai;auto-install" "fn_autoinstall" "Install the server without prompts." )
cmd_start=( "st;start" "command_start.sh" "Start the server." )
cmd_stop=( "sp;stop" "command_stop.sh" "Stop the server." )
cmd_restart=( "r;restart" "command_restart.sh" "Restart the server." )
cmd_details=( "dt;details" "command_details.sh" "Display server information." )
cmd_postdetails=( "pd;postdetails" "command_postdetails.sh" "Post details to hastebin (removing passwords)." )
cmd_backup=( "b;backup" "command_backup.sh" "Create backup archives of the server." )
cmd_update_linuxgsm=( "ul;update-lgsm;uf;update-functions" "command_update_linuxgsm.sh" "Check and apply any LinuxGSM updates." )
cmd_test_alert=( "ta;test-alert" "command_test_alert.sh" "Send a test alert." )
cmd_monitor=( "m;monitor" "command_monitor.sh" "Check server status and restart if crashed." )
cmd_donate=( "do;donate" "command_donate.sh" "Donation options." )
# Console servers only.
cmd_console=( "c;console" "command_console.sh" "Access server console." )
cmd_debug=( "d;debug" "command_debug.sh" "Start server directly in your terminal." )
# Update servers only.
cmd_update=( "u;update" "command_update.sh" "Check and apply any server updates." )
cmd_force_update=( "fu;force-update;update-restart;ur" "forceupdate=1; command_update.sh" "Apply server updates bypassing check." )
# SteamCMD servers only.
cmd_validate=( "v;validate" "command_validate.sh" "Validate server files with SteamCMD." )
# Server with mods-install.
cmd_mods_install=( "mi;mods-install" "command_mods_install.sh" "View and install available mods/addons." )
cmd_mods_remove=( "mr;mods-remove" "command_mods_remove.sh" "View and remove an installed mod/addon." )
cmd_mods_update=( "mu;mods-update" "command_mods_update.sh" "Update installed mods/addons." )
# Server specific.
cmd_change_password=( "pw;change-password" "command_ts3_server_pass.sh" "Change TS3 serveradmin password." )
cmd_install_default_resources=( "ir;install-default-resources" "command_install_resources_mta.sh" "Install the MTA default resources." )
cmd_wipe=( "wi;wipe" "command_wipe.sh" "Wipe your main game server data." )
cmd_wipeall=( "wa;wipeall" "wipeall=1; command_wipe.sh" "Wipe your game server data and blueprints." )
cmd_map_compressor_u99=( "mc;map-compressor" "compress_ut99_maps.sh" "Compresses all ${gamename} server maps." )
cmd_map_compressor_u2=( "mc;map-compressor" "compress_unreal2_maps.sh" "Compresses all ${gamename} server maps." )
cmd_install_cdkey=( "cd;server-cd-key" "install_ut2k4_key.sh" "Add your server cd key." )
cmd_install_dst_token=( "ct;cluster-token" "install_dst_token.sh" "Configure cluster token." )
cmd_install_squad_license=( "li;license" "install_squad_license.sh" "Add your Squad server license." )
cmd_fastdl=( "fd;fastdl" "command_fastdl.sh" "Build a FastDL directory." )
# Dev commands.
cmd_dev_debug=( "dev;developer" "command_dev_debug.sh" "Enable developer Mode." )
cmd_dev_detect_deps=( "dd;detect-deps" "command_dev_detect_deps.sh" "Detect required dependencies." )
cmd_dev_detect_glibc=( "dg;detect-glibc" "command_dev_detect_glibc.sh" "Detect required glibc." )
cmd_dev_detect_ldd=( "dl;detect-ldd" "command_dev_detect_ldd.sh" "Detect required dynamic dependencies." )
cmd_dev_query_raw=( "qr;query-raw" "command_dev_query_raw.sh" "The raw output of gamedig and gsquery." )
cmd_dev_clear_functions=( "cf;clear-functions" "command_dev_clear_functions.sh" "Delete the contents of the functions dir." )


### Set specific opt here.

currentopt=( "${cmd_start[@]}" "${cmd_stop[@]}" "${cmd_restart[@]}" "${cmd_monitor[@]}" "${cmd_test_alert[@]}" "${cmd_details[@]}" "${cmd_postdetails[@]}" )

# Update LGSM.
currentopt+=( "${cmd_update_linuxgsm[@]}" )

# Exclude noupdate games here.
if [ "${engine}" != "quake" ]&&[ "${engine}" != "idtech2" ]&&[ "${engine}" != "idtech3" ]&&[ "${engine}" != "iw2.0" ]&&[ "${engine}" != "iw3.0" ]&&[ "${shortname}" != "bf1942" ]&&[ "${shortname}" != "samp" ]; then
	currentopt+=( "${cmd_update[@]}" )
	# force update for SteamCMD only or MTA.
	if [ -n "${appid}" ]||[ "${shortname}" == "mta" ]; then
		currentopt+=( "${cmd_force_update[@]}" )
	fi
fi

# Validate command.
if [ -n "${appid}" ]; then
	currentopt+=( "${cmd_validate[@]}" )
fi

# Backup.
currentopt+=( "${cmd_backup[@]}" )

# Console & Debug
currentopt+=( "${cmd_console[@]}" "${cmd_debug[@]}" )

## Game server exclusive commands.

# FastDL command.
if [ "${engine}" == "source" ]; then
	currentopt+=( "${cmd_fastdl[@]}" )
fi

# TeamSpeak exclusive.
if [ "${shortname}" == "ts3" ]; then
	currentopt+=( "${cmd_change_password[@]}" )
fi

# Unreal exclusive.
if [ "${shortname}" == "rust" ]; then
	currentopt+=( "${cmd_wipe[@]}" "${cmd_wipeall[@]}" )
fi
if [ "${engine}" == "unreal2" ]; then
	if [ "${shortname}" == "ut2k4" ]; then
		currentopt+=( "${cmd_install_cdkey[@]}" "${cmd_map_compressor_u2[@]}" )
	else
		currentopt+=( "${cmd_map_compressor_u2[@]}" )
	fi
fi
if [ "${engine}" == "unreal" ]; then
	currentopt+=( "${cmd_map_compressor_u99[@]}" )
fi

# DST exclusive.
if [ "${shortname}" == "dst" ]; then
	currentopt+=( "${cmd_install_dst_token[@]}" )
fi

# MTA exclusive.
if [ "${shortname}" == "mta" ]; then
	currentopt+=( "${cmd_install_default_resources[@]}" )
fi

# Squad license exclusive.
if [ "${shortname}" == "squad" ]; then
	currentopt+=( "${cmd_install_squad_license[@]}" )
fi

## Mods commands.
if [ "${engine}" == "source" ]||[ "${shortname}" == "rust" ]||[ "${shortname}" == "hq" ]||[ "${shortname}" == "sdtd" ]; then
	currentopt+=( "${cmd_mods_install[@]}" "${cmd_mods_remove[@]}" "${cmd_mods_update[@]}" )
fi

## Installer.
currentopt+=( "${cmd_install[@]}" "${cmd_auto_install[@]}" )

## Developer commands.
currentopt+=( "${cmd_dev_debug[@]}" )
if [ -f ".dev-debug" ]; then
	currentopt+=( "${cmd_dev_detect_deps[@]}" "${cmd_dev_detect_glibc[@]}" "${cmd_dev_detect_ldd[@]}" "${cmd_dev_query_raw[@]}" "${cmd_dev_clear_functions[@]}" )
fi

## Donate.
currentopt+=( "${cmd_donate[@]}" )

### Build list of available commands.
optcommands=()
index="0"
for ((index="0"; index < ${#currentopt[@]}; index+=3)); do
	cmdamount=$(echo -e "${currentopt[index]}" | awk -F ';' '{ print NF }')
	for ((cmdindex=1; cmdindex <= cmdamount; cmdindex++)); do
		optcommands+=( "$(echo -e "${currentopt[index]}" | awk -F ';' -v x=${cmdindex} '{ print $x }')" )
	done
done

# Shows LinuxGSM usage.
fn_opt_usage(){
	echo -e "Usage: $0 [option]"
	echo -e ""
	echo -e "LinuxGSM - ${gamename} - Version ${version}"
	echo -e "https://linuxgsm.com/${gameservername}"
	echo -e ""
	echo -e "${lightyellow}Commands${default}"
	# Display available commands.
	index="0"
	{
	for ((index="0"; index < ${#currentopt[@]}; index+=3)); do
		# Hide developer commands.
		if [ "${currentopt[index+2]}" != "DEVCOMMAND" ]; then
			echo -e "${cyan}$(echo -e "${currentopt[index]}" | awk -F ';' '{ print $2 }')\t${default}$(echo -e "${currentopt[index]}" | awk -F ';' '{ print $1 }')\t| ${currentopt[index+2]}"
		fi
	done
	} | column -s $'\t' -t
	core_exit.sh
}

# Check if user commands exist and run corresponding scripts, or display script usage.
if [ -z "${getopt}" ]; then
	fn_opt_usage
fi
# Command exists.
for i in "${optcommands[@]}"; do
	if [ "${i}" == "${getopt}" ] ; then
		# Seek and run command.
		index="0"
		for ((index="0"; index < ${#currentopt[@]}; index+=3)); do
			currcmdamount=$(echo -e "${currentopt[index]}" | awk -F ';' '{ print NF }')
			for ((currcmdindex=1; currcmdindex <= currcmdamount; currcmdindex++)); do
				if [ "$(echo -e "${currentopt[index]}" | awk -F ';' -v x=${currcmdindex} '{ print $x }')" == "${getopt}" ]; then
					# Run command.
					eval "${currentopt[index+1]}"
					core_exit.sh
					break
				fi
			done
		done
	fi
done

# If we're executing this, it means command was not found.
echo -e "${red}Unknown command${default}: $0 ${getopt}"
exitcode=2
fn_opt_usage
core_exit.sh
