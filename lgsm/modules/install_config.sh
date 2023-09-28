#!/bin/bash
# LinuxGSM install_config.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates default server configs.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Checks if server cfg dir exists, creates it if it doesn't.
fn_check_cfgdir() {

	if [ "${shortname}" == "dst" ]; then
		echo -en "creating ${clustercfgfullpath} config directory"
		mkdir -p "${clustercfgfullpath}"
	elif [ "${shortname}" == "arma3" ]; then
		echo -en "creating ${networkcfgfullpath} config directory"
		mkdir -p "${networkcfgfullpath}"
	else
		echo -en "creating ${servercfgdir} config directory"
		mkdir -p "${servercfgdir}"
	fi
	if [ "$?" -ne 0 ]; then # shellcheck disable=SC2181
		fn_print_fail_eol
		fn_script_log_fatal "creating ${servercfgdir} config directory"
		core_exit.sh
	else
		fn_print_ok_eol
		fn_script_log_pass "creating ${servercfgdir} config directory"
	fi
}

# Copys default configs from Game-Server-Configs repo to server config location.
# Downloads default configs from Game-Server-Configs repo to lgsm/config-default.
fn_default_config_remote() {
	echo -e ""
	echo -e "${bold}${lightyellow}Downloading ${gamename} Configs${default}"
	echo -e "${bold}=================================${default}"
	echo -e "Default configs are downloaded from:"
	echo -e ""
	echo -e "${italic}https://github.com/GameServerManagers/Game-Server-Configs${default}"
	echo -e ""
	fn_sleep_time
	githuburl="https://raw.githubusercontent.com/GameServerManagers/Game-Server-Configs/main"
	for config in "${array_configs[@]}"; do
		if [ ! -f "${lgsmdir}/config-default/config-game/${config}" ]; then
			fn_fetch_file "${githuburl}/${shortname}/${config}" "${remote_fileurl_backup}" "GitHub" "Bitbucket" "${lgsmdir}/config-default/config-game" "${config}" "nochmodx" "norun" "forcedl" "nohash"

			fn_check_cfgdir

			changes=""
			if [ "${config}" == "${servercfgdefault}" ]; then
				echo -en "copying config file [ ${italic}${servercfgfullpath}${default} ]"
				changes+=$(cp -n "${lgsmdir}/config-default/config-game/${config}" "${servercfgfullpath}")
			elif [ "${shortname}" == "arma3" ] && [ "${config}" == "${networkcfgdefault}" ]; then
				echo -en "copying config file [ ${italic}${networkcfgfullpath}${default} ]"
				changes+=$(cp -n "${lgsmdir}/config-default/config-game/${config}" "${networkcfgfullpath}")
			elif [ "${shortname}" == "dst" ] && [ "${config}" == "${clustercfgdefault}" ]; then
				echo -en "copying config file [ ${italic}${clustercfgdefault}${default} ]"
				changes+=$(cp -n "${lgsmdir}/config-default/config-game/${clustercfgdefault}" "${clustercfgfullpath}")
			else
				echo -en "copying config file [ ${italic}${servercfgdir}/${config}${default} ]"
				changes+=$(cp -n "${lgsmdir}/config-default/config-game/${config}" "${servercfgdir}/${config}")
			fi
			if [ "$?" -ne 0 ]; then # shellcheck disable=SC2181
				fn_print_failure_eol_nl
				fn_script_log_fatal "copying config file ${servercfgfullpath}"
			elif [ "${changes}" != "" ]; then
				fn_print_ok_eol_nl
				fn_script_log_pass "copying config file ${servercfgfullpath}"
			else
				fn_print_skip_eol_nl
			fi

		fi
	done
}

# Copys local default config to server config location.
fn_default_config_local() {
	fn_check_cfgdir
	echo -en "copying config file [ ${italic}${servercfgdefault}${default} ]"
	cp -n "${servercfgdir}/${servercfgdefault}" "${servercfgfullpath}"
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol
		fn_script_log_fatal "copying config file [ ${servercfgdefault} ]"
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
		servername="LinuxGSM"
		echo -en "changing server name"
		changes=""
		# prevents the variable SERVERNAME from being overwritten with the $servername.
		if grep -q "SERVERNAME=SERVERNAME" "${lgsmdir}/config-default/config-game/${config}" 2> /dev/null; then
			changes+=$(sed -i "s/SERVERNAME=SERVERNAME/SERVERNAME=${servername}/g w /dev/stdout" "${servercfgfullpath}")
		elif grep -q "SERVERNAME=\"SERVERNAME\"" "${lgsmdir}/config-default/config-game/${config}" 2> /dev/null; then
			changes+=$(sed -i "s/SERVERNAME=\"SERVERNAME\"/SERVERNAME=\"${servername}\"/g w /dev/stdout" "${servercfgfullpath}")
		else
			changes+=$(sed -i "s/SERVERNAME/${servername}/g w /dev/stdout" "${servercfgfullpath}")
		fi
		if [ "$?" -ne 0 ]; then # shellcheck disable=SC2181
			fn_print_fail_eol
			fn_script_log_fatal "changing server name"
		elif [ "${changes}" != "" ]; then
			fn_print_ok_eol_nl
			fn_script_log_pass "changing server name"
		else
			fn_print_skip_eol_nl
		fi
		unset changes

		randomstring=$(tr -dc 'A-Za-z0-9_' < /dev/urandom 2> /dev/null | head -c 8 | xargs)
		rconpass="admin${randomstring}"
		echo -en "generating rcon/admin password"
		changes=""
		if [ "${shortname}" == "squad" ]; then
			changes+=$(sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgdir}/Rcon.cfg")
		else
			changes+=$(sed -i "s/ADMINPASSWORD/${rconpass}/g" "${servercfgfullpath}")
		fi
		if [ "$?" -ne 0 ]; then # shellcheck disable=SC2181
			fn_print_fail_eol
			fn_script_log_fatal "generating rcon/admin password"
		elif [ "${changes}" != "" ]; then
			fn_print_ok_eol_nl
			fn_script_log_pass "generating rcon/admin password"
		else
			fn_print_skip_eol_nl
		fi
		unset changes
	fi
}

# Changes some variables within the default Don't Starve Together configs.
fn_set_dst_config_vars() {
	servername="LinuxGSM"
	echo -en "changing cluster name"
	changes=""
	changes+=$(sed -i "s/SERVERNAME/${servername}/g" "${clustercfgfullpath}")
	if [ "$?" -ne 0 ]; then # shellcheck disable=SC2181
		fn_print_fail_eol
		fn_script_log_fatal "changing cluster name"
	elif [ "${changes}" != "" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "changing cluster name"
	else
		fn_print_skip_eol_nl
	fi
	unset changes

	randomstring=$(tr -dc A-Za-z0-9 < /dev/urandom 2> /dev/null | head -c 16 | xargs)
	echo -en "generating cluster key"
	changes=""
	changes+=$(sed -i "s/CLUSTERKEY/${randomstring}/g" "${clustercfgfullpath}")
	if [ "$?" -ne 0 ]; then # shellcheck disable=SC2181
		fn_print_fail_eol
		fn_script_log_fatal "generating cluster key"
	elif [ "${changes}" != "" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "generating cluster key"
	else
		fn_print_skip_eol_nl
	fi
	unset changes
}

# Lists local config locations
fn_list_config_locations() {
	echo -e ""
	echo -e "${bold}${lightyellow}Config Locations${default}"
	echo -e "${bold}=================================${default}"
	if [ -n "${servercfgfullpath}" ]; then
		if [ -f "${servercfgfullpath}" ]; then
			echo -e "${gamename} config file: ${italic}${servercfgfullpath}${default}"
		elif [ -d "${servercfgfullpath}" ]; then
			echo -e "${gamename} config directory: ${italic}${servercfgfullpath}"
		else
			echo -e "${gamename} config: ${italic}${red}${servercfgfullpath}${default} (${red}CONFIG IS MISSING${default})"
		fi
	fi
	echo -e "LinuxGSM config: ${italic}${lgsmdir}/config-lgsm/${gameservername}${default}"
	echo -e "Config documentation: ${italic}https://docs.linuxgsm.com/configuration${default}"
}

if [ "${shortname}" == "sdtd" ]; then
	fn_default_config_local
	fn_list_config_locations
elif [ "${shortname}" == "ac" ]; then
	array_configs+=(server_cfg.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ahl" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ahl2" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ark" ]; then
	array_configs+=(GameUserSettings.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "arma3" ]; then
	array_configs+=(server.cfg network.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "armar" ]; then
	array_configs+=(server.json)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ats" ]; then
	array_configs+=(server_config.sii)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bo" ]; then
	array_configs+=(config.txt)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bd" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bt" ]; then
	array_configs+=(serversettings.xml)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "btl" ]; then
	array_configs+=(DefaultGame.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bf1942" ]; then
	array_configs+=(serversettings.con)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bfv" ]; then
	array_configs+=(serversettings.con)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bs" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bb" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bb2" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "bmdm" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cd" ]; then
	array_configs+=(properties.json)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ck" ]; then
	array_configs+=(ServerConfig.json)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "coduo" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod2" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cod4" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "codwaw" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cc" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "col" ]; then
	array_configs+=(colserver.json)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cs" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "cscz" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "csgo" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "css" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ct" ]; then
	array_configs+=(ServerSetting.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dayz" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dod" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dodr" ]; then
	array_configs+=(Game.ini)
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "dods" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "doi" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dmc" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dst" ]; then
	array_configs+=(cluster.ini server.ini)
	fn_default_config_remote
	fn_set_dst_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dab" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "dys" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "eco" ]; then
	array_configs+=(Network.eco)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "em" ]; then
	fn_default_config_local
	fn_list_config_locations
elif [ "${shortname}" == "etl" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ets2" ]; then
	array_configs+=(server_config.sii)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "fctr" ]; then
	array_configs+=(server-settings.json)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "fof" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "gmod" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hldm" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hldms" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ohd" ]; then
	array_configs+=(Game.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "opfor" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "hl2dm" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ins" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ios" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jc2" ]; then
	array_configs+=(config.lua)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jc3" ]; then
	array_configs+=(config.json)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "kf" ]; then
	array_configs+=(Default.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "l4d" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "l4d2" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ]; then
	array_configs+=(server.properties)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mcb" ]; then
	array_configs+=(server.properties)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mohaa" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mh" ]; then
	array_configs+=(Game.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ns" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nmrih" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nd" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "mta" ]; then
	array_configs+=(acl.xml mtaserver.conf vehiclecolors.conf)
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shotname}" == "mom" ]; then
	array_configs+=(DedicatedServerConfig.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pvr" ]; then
	array_configs+=(Game.ini)
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "pvkii" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pz" ]; then
	array_configs+=(server.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "nec" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pc" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "pc2" ]; then
	fn_default_config_local
	fn_list_config_locations
elif [ "${shortname}" == "q2" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "q3" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ql" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "jk2" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "qw" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ricochet" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "rtcw" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "rust" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "scpsl" ] || [ "${shortname}" == "scpslsm" ]; then
	array_configs+=(config_gameplay.txt config_localadmin.txt)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sf" ]; then
	array_configs+=(GameUserSettings.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sol" ]; then
	array_configs+=(soldat.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sof2" ]; then
	array_configs+=(server.cfg mapcycle.txt)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sfc" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "squad" ]; then
	array_configs+=(Admins.cfg Bans.cfg License.cfg Server.cfg Rcon.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sb" ]; then
	array_configs+=(starbound_server.config)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "stn" ]; then
	array_configs+=(ServerConfig.txt ServerUsers.txt TpPresets.json UserPermissions.json)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "sven" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tf2" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tfc" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ti" ]; then
	array_configs+=(Game.ini Engine.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ts" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ts3" ]; then
	array_configs+=(ts3server.ini)
	fn_default_config_remote
	fn_list_config_locations
elif [ "${shortname}" == "tw" ]; then
	array_configs+=(server.cfg ctf.cfg dm.cfg duel.cfg tdm.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "terraria" ]; then
	array_configs+=(serverconfig.txt)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "tu" ]; then
	array_configs+=(TowerServer.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut" ]; then
	array_configs+=(Game.ini Engine.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut2k4" ]; then
	array_configs+=(UT2004.ini)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "ut99" ]; then
	array_configs+=(Default.ini)
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
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wet" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wf" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "wmc" ]; then
	array_configs+=(config.yml)
	fn_default_config_remote
	fn_set_config_vars
elif [ "${shortname}" == "wurm" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "zmr" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
elif [ "${shortname}" == "zps" ]; then
	array_configs+=(server.cfg)
	fn_default_config_remote
	fn_set_config_vars
	fn_list_config_locations
fi
