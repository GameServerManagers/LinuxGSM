#!/bin/bash
# LinuxGSM install_config.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates default server configs.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Checks if server cfg dir exists, creates it if it doesn't.
fn_check_cfgdir() {
	if [ ! -d "${servercfgdir}" ]; then
		echo -e "creating ${servercfgdir} config directory."
		fn_script_log_info "Creating ${servercfgdir} config directory."
		mkdir -pv "${servercfgdir}"
	fi
}

# Downloads default configs from Game-Server-Configs repo to lgsm/config-default.
fn_fetch_default_config() {
	echo -e ""
	echo -e "${bold}${lightyellow}Downloading ${gamename} Configs${default}"
	fn_messages_separator
	echo -e "Downloading default configs from:"
	echo -e ""
	echo -e "${italic}https://github.com/GameServerManagers/Game-Server-Configs${default}"
	echo -e ""
	fn_sleep_time_1
	mkdir -p "${lgsmdir}/config-default/config-game"
	githuburl="https://raw.githubusercontent.com/GameServerManagers/Game-Server-Configs/main"
	for config in "${array_configs[@]}"; do
		fn_fetch_file "${githuburl}/${shortname}/${config}" "${remote_fileurl_backup}" "GitHub" "Bitbucket" "${lgsmdir}/config-default/config-game" "${config}" "nochmodx" "norun" "forcedl" "nohash"
	done
}

# Copys default configs from Game-Server-Configs repo to server config location.
fn_default_config_remote() {
	for config in "${array_configs[@]}"; do
		# every config is copied
		echo -e "copying ${config} config file."
		fn_script_log_info "Copying ${servercfg} config file."
		if [ "${config}" == "${servercfgdefault}" ]; then
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${servercfgfullpath}"
		elif [ "${shortname}" == "arma3" ] && [ "${config}" == "${networkcfgdefault}" ]; then
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${networkcfgfullpath}"
		elif [ "${shortname}" == "dst" ] && [ "${config}" == "${clustercfgdefault}" ]; then
			cp -nv "${lgsmdir}/config-default/config-game/${clustercfgdefault}" "${clustercfgfullpath}"
		else
			mkdir -p "${servercfgdir}"
			cp -nv "${lgsmdir}/config-default/config-game/${config}" "${servercfgdir}/${config}"
		fi
	done
	fn_sleep_time
}

# Copys local default config to server config location.
fn_default_config_local() {
	echo -e ""
	echo -e "${bold}${lightyellow}Copying ${gamename} Configs${default}"
	fn_messages_separator
	echo -e "Copying default configs."
	fn_check_cfgdir
	echo -en "copying config file [ ${italic}${servercfgdefault}${default} ]"
	cp -n "${servercfgdir}/${servercfgdefault}" "${servercfgfullpath}"
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol
		fn_script_log_fail "copying config file [ ${servercfgdefault} ]"
	else
		fn_print_ok_eol
		fn_script_log_pass "copying config file [ ${servercfgdefault} ]"
	fi
}

# Changes some variables within the default configs.
# SERVERNAME to LinuxGSM
# PASSWORD to random password
fn_set_config_vars() {
	if [ -f "${servercfgfullpath}" ]; then
		randomstring=$(tr -dc 'A-Za-z0-9_' < /dev/urandom 2> /dev/null | head -c 8 | xargs)
		servername="LinuxGSM"
		rconpass="admin${randomstring}"
		echo -e "changing hostname."
		fn_script_log_info "Changing hostname."
		fn_sleep_time
		# prevents var from being overwritten with the servername.
		if grep -q "SERVERNAME=SERVERNAME" "${lgsmdir}/config-default/config-game/${config}" 2> /dev/null; then
			sed -i "s/SERVERNAME=SERVERNAME/SERVERNAME=${servername}/g" "${servercfgfullpath}"
		elif grep -q "SERVERNAME=\"SERVERNAME\"" "${lgsmdir}/config-default/config-game/${config}" 2> /dev/null; then
			sed -i "s/SERVERNAME=\"SERVERNAME\"/SERVERNAME=\"${servername}\"/g" "${servercfgfullpath}"
		else
			sed -i "s/SERVERNAME/${servername}/g" "${servercfgfullpath}"
		fi
		echo -e "changing rcon/admin password."
		fn_script_log_info "Changing rcon/admin password."
		if [ "${shortname}" == "squad" ]; then
			sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgdir}/Rcon.cfg"
		else
			sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgfullpath}"
		fi
		fn_sleep_time
	else
		fn_script_log_warn "Config file not found, cannot alter it."
		echo -e "Config file not found, cannot alter it."
		fn_sleep_time
	fi
}

# Changes some variables within the default Don't Starve Together configs.
fn_set_dst_config_vars() {
	## cluster.ini
	if grep -Fq "SERVERNAME" "${clustercfgfullpath}"; then
		echo -e "changing server name."
		fn_script_log_info "Changing server name."
		sed -i "s/SERVERNAME/LinuxGSM/g" "${clustercfgfullpath}"
		fn_sleep_time
		echo -e "changing shard mode."
		fn_script_log_info "Changing shard mode."
		sed -i "s/USESHARDING/${sharding}/g" "${clustercfgfullpath}"
		fn_sleep_time
		echo -e "randomizing cluster key."
		fn_script_log_info "Randomizing cluster key."
		randomstring=$(tr -dc 'A-Za-z0-9_' < /dev/urandom 2> /dev/null | head -c 8 | xargs)
		sed -i "s/CLUSTERKEY/${randomstring}/g" "${clustercfgfullpath}"
		fn_sleep_time
	else
		echo -e "${clustercfg} is already configured."
		fn_script_log_info "${clustercfg} is already configured."
	fi

	## server.ini
	# removing unnecessary options (dependent on sharding & shard type).
	if [ "${sharding}" == "false" ]; then
		sed -i "s/ISMASTER//g" "${servercfgfullpath}"
		sed -i "/SHARDNAME/d" "${servercfgfullpath}"
	elif [ "${master}" == "true" ]; then
		sed -i "/SHARDNAME/d" "${servercfgfullpath}"
	fi

	echo -e "changing shard name."
	fn_script_log_info "Changing shard name."
	sed -i "s/SHARDNAME/${shard}/g" "${servercfgfullpath}"
	fn_sleep_time
	echo -e "changing master setting."
	fn_script_log_info "Changing master setting."
	sed -i "s/ISMASTER/${master}/g" "${servercfgfullpath}"
	fn_sleep_time

	## worldgenoverride.lua
	if [ "${cave}" == "true" ]; then
		echo -e "defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		fn_script_log_info "Defining ${shard} as cave in ${servercfgdir}/worldgenoverride.lua."
		echo 'return { override_enabled = true, preset = "DST_CAVE", }' > "${servercfgdir}/worldgenoverride.lua"
	fi
	fn_sleep_time
	echo -e ""
}

# Lists local config file locations
fn_list_config_locations() {
	echo -e ""
	echo -e "${bold}${lightyellow}Config Locations${default}"
	fn_messages_separator
	if [ -n "${servercfgfullpath}" ]; then
		if [ -f "${servercfgfullpath}" ]; then
			echo -e "Game Server Config File: ${servercfgfullpath}"
		elif [ -d "${servercfgfullpath}" ]; then
			echo -e "Game Server Config Dir: ${servercfgfullpath}"
		else
			echo -e "Config file: ${red}${servercfgfullpath}${default} (${red}FILE MISSING${default})"
		fi
	fi
	echo -e "LinuxGSM Config: ${lgsmdir}/config-lgsm/${gameservername}"
	echo -e "Documentation: https://docs.linuxgsm.com/configuration/game-server-config"
}

if [ "${shortname}" == "sdtd" ]; then
	fn_default_config_local
	fn_list_config_locations
elif [ "${shortname}" == "ac" ]; then
	array_configs+=(server_cfg.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ahl" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ahl2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ark" ]; then
	fn_check_cfgdir
	array_configs+=(GameUserSettings.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "arma3" ]; then
	fn_check_cfgdir
	array_configs+=(server.cfg network.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "armar" ]; then
	fn_check_cfgdir
	array_configs+=(server.json)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ats" ]; then
	fn_check_cfgdir
	array_configs+=(server_config.sii)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bo" ]; then
	array_configs+=(config.txt)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bd" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bt" ]; then
	fn_check_cfgdir
	array_configs+=(serversettings.xml)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "btl" ]; then
	fn_check_cfgdir
	array_configs+=(Game.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bf1942" ]; then
	array_configs+=(serversettings.con)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bfv" ]; then
	array_configs+=(serversettings.con)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bs" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bb" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bb2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bmdm" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ck" ]; then
	array_configs+=(ServerConfig.json)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "coduo" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod4" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "codwaw" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cc" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "col" ]; then
	array_configs+=(colserver.json)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cs" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cs2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cscz" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "csgo" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "css" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ct" ]; then
	array_configs+=(ServerSetting.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dayz" ]; then
	fn_check_cfgdir
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dod" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dodr" ]; then
	array_configs+=(Game.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "dods" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "doi" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dmc" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dst" ]; then
	fn_check_cfgdir
	array_configs+=(cluster.ini server.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_dst_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dab" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dys" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "eco" ]; then
	array_configs+=(Network.eco)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "em" ]; then
	fn_default_config_local
	fn_list_config_locations
elif [ "${shortname}" == "etl" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ets2" ]; then
	fn_check_cfgdir
	array_configs+=(server_config.sii)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "fctr" ]; then
	array_configs+=(server-settings.json)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "fof" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "gmod" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hldm" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hldms" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ohd" ]; then
	array_configs+=(Admins.cfg Engine.ini Game.ini MapCycle.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "opfor" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hl2dm" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ins" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ios" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jc2" ]; then
	array_configs+=(config.lua)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jc3" ]; then
	array_configs+=(config.json)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "kf" ]; then
	array_configs+=(Default.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "l4d" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "l4d2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ]; then
	array_configs+=(server.properties)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mcb" ]; then
	array_configs+=(server.properties)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mohaa" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mh" ]; then
	fn_check_cfgdir
	array_configs+=(Game.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ns" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nmrih" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nd" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mta" ]; then
	fn_check_cfgdir
	array_configs+=(acl.xml mtaserver.conf vehiclecolors.conf)
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shotname}" == "mom" ]; then
	array_configs+=(DedicatedServerConfig.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pvr" ]; then
	fn_check_cfgdir
	array_configs+=(Game.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "pvkii" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pz" ]; then
	fn_check_cfgdir
	array_configs+=(server.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nec" ]; then
	fn_check_cfgdir
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pc" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pc2" ]; then
	fn_default_config_local
	fn_list_config_locations
elif [ "${shortname}" == "q2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "q3" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_configs
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "q4" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ql" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jk2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "qw" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ricochet" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "rtcw" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "rust" ]; then
	fn_check_cfgdir
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "scpsl" ] || [ "${shortname}" == "scpslsm" ]; then
	array_configs+=(config_gameplay.txt config_localadmin.txt)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sf" ]; then
	array_configs+=(GameUserSettings.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sol" ]; then
	array_configs+=(soldat.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sof2" ]; then
	array_configs+=(server.cfg mapcycle.txt)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sfc" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "squad" ]; then
	array_configs+=(Admins.cfg Bans.cfg License.cfg Server.cfg Rcon.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sb" ]; then
	array_configs+=(starbound_server.config)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "stn" ]; then
	array_configs+=(ServerConfig.txt ServerUsers.txt TpPresets.json UserPermissions.json)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sven" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tf2" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tfc" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ti" ]; then
	array_configs+=(Game.ini Engine.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ts" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ts3" ]; then
	array_configs+=(ts3server.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "tw" ]; then
	array_configs+=(server.cfg ctf.cfg dm.cfg duel.cfg tdm.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "terraria" ]; then
	array_configs+=(serverconfig.txt)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tu" ]; then
	fn_check_cfgdir
	array_configs+=(TowerServer.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut" ]; then
	array_configs+=(Game.ini Engine.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut2k4" ]; then
	array_configs+=(UT2004.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut99" ]; then
	array_configs+=(Default.ini)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "unt" ]; then
	# Config is generated on first run
	:
elif [ "${shortname}" == "vints" ]; then
	# Config is generated on first run
	:
elif [ "${shortname}" == "vs" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wet" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wf" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wmc" ]; then
	array_configs+=(config.yml)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "wurm" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "zmr" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "zps" ]; then
	array_configs+=(server.cfg)
	fn_fetch_default_config
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
fi
