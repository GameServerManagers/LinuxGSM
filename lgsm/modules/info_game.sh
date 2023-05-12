#!/bin/bash
# LinuxGSM info_game.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Gathers various game server information.

# shellcheck disable=SC2317
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Config Type: ini
# Comment: ; or #
# Note: this ini filter does not filter by section. Can cause issues with some games that have multiple sections with the same variable name.
fn_info_game_ini() {
	# sed is used to process the file.
	# -n: Suppresses automatic printing of pattern space.
	# /^\<'"${2}"'\>/: Matches lines starting with the word provided as the second argument ($2), considering it as a whole word.
	# { s/.*= *"\?\([^"]*\)"\?/\1/p;q }: Command block executed for lines that match the pattern.
	#   - s/.*= *"\?\([^"]*\)"\?/\1/: Matches and captures the value after an equals sign (=), possibly surrounded by optional double quotes.
	#     - .*: Matches any characters before the equals sign.
	#     - = *"\?: Matches the equals sign and any optional spaces before an optional double quote.
	#     - \([^"]*\): Captures any characters that are not double quotes.
	#     - "\?: Matches an optional double quote.
	#     - /1: Replaces the entire matched pattern with the captured value.
	#   - p: Prints the modified line.
	#   - q: Quits processing after modifying and printing the line.

	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}=\"$(sed -n '/^\<'"${2}"'\>/ { s/.*= *"\?\([^"]*\)"\?/\1/p;q }' "${servercfgfullpath}" | tr -d '\r')"
	configtype="ini"
}

# Config Type: custom
# Comment: ; or #
# Note: this ini filter does not filter by section. Can cause issues with some games that have multiple sections with the same variable name.
fn_info_game_keyvalue_pairs() {
	# sed is used to process the file.
	# -n: Suppresses automatic printing of pattern space.
	# /^\<'"${2}"'\>/: Matches lines starting with the word provided as the second argument ($2), considering it as a whole word.
	# { s/.*= *"\?\([^"]*\)"\?/\1/p;q }: Command block executed for lines that match the pattern.
	#   - s/.*= *"\?\([^"]*\)"\?/\1/: Matches and captures the value after an equals sign (=), possibly surrounded by optional double quotes.
	#     - .*: Matches any characters before the equals sign.
	#     - = *"\?: Matches the equals sign and any optional spaces before an optional double quote.
	#     - \([^"]*\): Captures any characters that are not double quotes.
	#     - "\?: Matches an optional double quote.
	#     - /1: Replaces the entire matched pattern with the captured value.
	#   - p: Prints the modified line.
	#   - q: Quits processing after modifying and printing the line.

	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}=\"$(sed -n '/^\<'"${2}"'\>/ { s/.*= *"\?\([^"]*\)"\?/\1/p;q }' "${servercfgfullpath}" | tr -d '\r')"
	configtype="keyvalue_pairs"
}

# Config Type: QuakeC
# Comment: // or /* */
fn_info_game_quakec() {
	# -n: Suppresses automatic printing of pattern space.
	# /^[[:space:]]*\<'"${2}"'\>/: Matches lines starting with optional leading whitespace and the word provided as the second argument ($2), considering it as a whole word.
	# { s/.*  *"\?\([^"]*\)"\?/\1/p;q }: Command block executed for lines that match the pattern.
	#   - s/.*  *"\?\([^"]*\)"\?/\1/: Matches and captures the value after any number of spaces, possibly surrounded by optional double quotes.
	#     - .*: Matches any characters before the spaces.
	#     -   *: Matches any number of spaces.
	#     - "\?: Matches an optional double quote.
	#     - \([^"]*\): Captures any characters that are not double quotes.
	#     - "\?: Matches an optional double quote.
	#     - /1: Replaces the entire matched pattern with the captured value.
	#   - p: Prints the modified line.
	#   - q: Quits processing after modifying and printing the line.

	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}"="$(sed -n '/^[[:space:]]*\<'"${2}"'\>/ { s/.*  *"\?\([^"]*\)"\?/\1/p;q }' "${servercfgfullpath}") | tr -d '\r')"
	configtype="quakec"
}

# Config Type: json
# Comment: // or /* */
fn_info_game_json() {
	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}"="$(jq -r '${2}' "${servercfgfullpath}")"
	configtype="json"
}

# Config Type: SQF
# Comment: // or /* */
fn_info_game_sqf() {
	# sed is the command itself, indicating that we want to use the sed utility.
	# -n: Suppresses automatic printing of pattern space.
	# /^\<'"${2}"'\>/: Matches lines starting with the word provided as the second argument ($2), considering it as a whole word.
	# { s/.*= *"\?\([^"]*\)"\?/\1/;s/;$//p;q }: Command block executed for lines that match the pattern.
	#   - s/.*= *"\?\([^"]*\)"\?/\1/: Matches and captures the value after an equals sign (=), possibly surrounded by optional double quotes.
	#     - .*: Matches any characters before the equals sign.
	#     - = *"\?: Matches the equals sign and any optional spaces before an optional double quote.
	#     - \([^"]*\): Captures any characters that are not double quotes.
	#     - "\?: Matches an optional double quote.
	#     - /1: Replaces the entire matched pattern with the captured value.
	#   - s/;$//: Removes a semicolon (;) at the end of the line, if present.
	#   - p: Prints the modified line.
	#   - q: Quits processing after modifying and printing the line.

	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}"="$(sed -n '/^\<'"${2}"'\>/ { s/.*= *"\?\([^"]*\)"\?/\1/;s/;$//p;q }' "${servercfgfullpath}") | tr -d '\r')"
	configtype="sqf"
}

# Config Type: XML
# Comment: <!-- -->
fn_info_game_xml() {
	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}"="$(xmllint --xpath "string(${2})" "${servercfgfullpath}")"
	configtype="xml"
}

# Config Type: Valve KeyValues
# Comment: //
fn_info_game_valve_keyvalues() {
	# sed is used to process the file.
	# -n: Suppresses automatic printing of pattern space.
	# /^[[:space:]]*\<'"${2}"'\>/: Matches lines starting with optional leading whitespace and the word provided as the second argument ($2), considering it as a whole word.
	# { s/.*  *"\?\([^"]*\)"\?/\1/p;q }: Command block executed for lines that match the pattern.
	#   - s/.*  *"\?\([^"]*\)"\?/\1/: Matches and captures the value after any number of spaces, possibly surrounded by optional double quotes.
	#     - .*: Matches any characters before the spaces.
	#     -   *: Matches any number of spaces.
	#     - "\?: Matches an optional double quote.
	#     - \([^"]*\): Captures any characters that are not double quotes.
	#     - "\?: Matches an optional double quote.
	#     - /1: Replaces the entire matched pattern with the captured value.
	#   - p: Prints the modified line.
	#   - q: Quits processing after modifying and printing the line.

	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}"="$(sed -n '/^\<'"${2}"'\>/ { s/.*  *"\?\([^"]*\)"\?/\1/p;q }' "${servercfgfullpath}" | tr -d '\r')"
	configtype="valve_keyvalues"
}

# Config Type: Java properties
# Comment: # or !
fn_info_game_java_properties() {
	# sed is used to process the file.
	# -n: Suppresses automatic printing of pattern space.
	# /^\<'"${2}"'\>/: Matches lines starting with the word provided as the second argument ($2), considering it as a whole word.
	# { s/.*= *"\?\([^"]*\)"\?/\1/p;q }: Command block executed for lines that match the pattern.
	#   - s/.*= *"\?\([^"]*\)"\?/\1/: Matches and captures the value after an equals sign (=), possibly surrounded by optional double quotes.
	#     - .*: Matches any characters before the equals sign.
	#     - = *"\?: Matches the equals sign and any optional spaces before an optional double quote.
	#     - \([^"]*\): Captures any characters that are not double quotes.
	#     - "\?: Matches an optional double quote.
	#     - /1: Replaces the entire matched pattern with the captured value.
	#   - p: Prints the modified line.
	#   - q: Quits processing after modifying and printing the line.

	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}"="$(sed -n '/^\<'"${2}"'\>/ { s/.*= *"\?\([^"]*\)"\?/\1/;s/;$//p;q }' "${servercfgfullpath}") | tr -d '\r')"
	configtype="java"
}

# Config Type: ini
# Comment: ; or #
# Note: this ini filter does not filter by section. Can cause issues with some games that have multiple sections with the same variable name.
fn_info_game_lua() {
	# - The '-n' option suppresses automatic printing of pattern space.
	# - The pattern '/^[[:space:]]*\<'"${2}"'\>/' matches lines that begin with optional whitespace characters,
	#   followed by the exact word specified by the second argument.
	# - If the pattern matches, the following actions are performed within the curly braces:
	#   - 's/.*= *"\?\([^"]*\)"\?/\1/' extracts the value within double quotes after an equal sign (if present),
	#     removing any leading or trailing spaces.
	#   - 's#,.*##' removes everything after the first comma encountered.
	#   - 'p' prints the modified pattern space.
	#   - 'q' quits processing after printing the modified pattern space.

	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}=\"$(sed -n '/^[[:space:]]*\<'"${2}"'\>/ { s/.*= *"\?\([^"]*\)"\?/\1/;s#,.*##;p;q }' "${servercfgfullpath}" | tr -d '\r')"
	configtype="lua"
}

# Config Type: custom (Project Cars)
# Comment: //
fn_info_game_pc_config() {
	# sed is used to process the file.
	# -n: Suppresses automatic printing of pattern space.
	# /^\<'"${2}"'\>/: Matches lines starting with the word provided as the second argument ($2), considering it as a whole word.
	# { s/.*: *"\?\([^"]*\)"\?/\1/p;q }: Command block executed for lines that match the pattern.
	#   - s/.*: *"\?\([^"]*\)"\?/\1/: Matches and captures the value after an equals sign (=), possibly surrounded by optional double quotes.
	#     - .*: Matches any characters before the equals sign.
	#     - : *"\?: Matches the : sign and any optional spaces before an optional double quote.
	#     - \([^"]*\): Captures any characters that are not double quotes.
	#     - "\?: Matches an optional double quote.
	#     - /1: Replaces the entire matched pattern with the captured value.
	#   - p: Prints the modified line.
	#   - q: Quits processing after modifying and printing the line.
	if [ -n "${3}" ]; then
		servercfgfullpath="${3}"
	fi
	eval "${1}=\"$(sed -n '/^\<'"${2}"'\>/ { s/.*: *"\?\([^"]*\)"\?/\1/;s/;$//p;q }' "${servercfgfullpath}" | tr -d '\r')"
	configtype="pc_config"
}

# Config Type: ini
# Parameters: false
# Comment: ; or #
# Example: NAME=SERVERNAME
# Filetype: ini
fn_info_game_ac() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "ADMIN_PASSWORD"
		fn_info_game_ini "httpport" "HTTP_PORT"
		fn_info_game_ini "port" "TCP_PORT"
		fn_info_game_ini "servername" "NAME"
		fn_info_game_ini "serverpassword" "PASSWORD"
	fi
	adminpassword="${adminpassword:-NOT SET}"
	httpport="${httpport:-0}"
	port="${port:-0}"
	queryport="${httpport:-0}"
	servername="${servername:-NOT SET}"
	serverpassword="${serverpassword:-NOT SET}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: SessionName=SERVERNAME
# Filetype: ini
fn_info_game_ark() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "ServerAdminPassword"
		fn_info_game_ini "servername" "SessionName"
		fn_info_game_ini "serverpassword" "ServerPassword"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	rawport="$((port + 1))"
	rconport="${rconport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: SQF
# Parameters: true
# Comment: // or /* */
# Example: serverName = "SERVERNAME";
# Filetype: cfg
fn_info_game_arma3() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_sqf "adminpassword" "passwordAdmin"
		fn_info_game_sqf "maxplayers" "maxPlayers"
		fn_info_game_sqf "servername" "hostname"
		fn_info_game_sqf "serverpassword" "password"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	battleeyeport="$((port + 4))"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steammasterport="$((port + 2))"
	voiceport="${port:-"0"}"
	voiceunusedport="$((port + 3))"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: serverName=SERVERNAME
# Filetype: ini
fn_info_game_av() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "maxPlayers"
		fn_info_game_ini "port" "port"
		fn_info_game_ini "rconport" "rconPort"
		fn_info_game_ini "servername" "name"
		fn_info_game_ini "serverpassword" "password"
		fn_info_game_ini "rconpassword" "rconPassword"
		if [ -n "${rconpassword}" ]; then
			rconenabled="true"
		fi
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	# queryport is port + 3
	# this doesnt respond to any queries, using tcp query on port instead.
	queryport="${port:-"0"}"
	rconenabled="${rconenabled:-"false"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	rconport="${rconport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steammasterport="$((port + 21))"
	steamqueryport="$((port + 20))"
}

# Config Type: ini unknown (Source?)
# Parameters: true
# Comment: # or //
# Example: ServerName=SERVERNAME
# Filetype: txt
fn_info_game_bo() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "port" "ServerPort"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "Password"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_btl() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "servername" "ServerName"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	rconport="$((port + 2))"
	servername="${servername:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_cmw() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "rconport" "RConPort" "${servercfgdir}/DefaultGame.ini"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	rconport="${rconport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: iMaxClanMembers=1024
# Filetype: ini
fn_info_game_dodr() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "iMaxPlayers"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: cluster_name = SERVERNAME
# Filetype: ini
fn_info_game_dst() {
	if [ -f "${clustercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "max_players" "${clustercfgfullpath}"
		fn_info_game_ini "servername" "cluster_name" "${clustercfgfullpath}"
		fn_info_game_ini "serverpassword" "cluster_password" "${clustercfgfullpath}"
		fn_info_game_ini "tickrate" "tick_rate" "${clustercfgfullpath}"
		fn_info_game_ini "masterport" "master_port" "${clustercfgfullpath}"
		fn_info_game_ini "gamemode" "game_mode" "${clustercfgfullpath}"
		fn_info_game_ini "configip" "bind_ip" "${clustercfgfullpath}"
	fi
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "port" "server_port" "${clustercfgfullpath}"
		fn_info_game_ini "steamauthport" "authentication_port" "${clustercfgfullpath}"
		fn_info_game_ini "steammasterport" "master_server_port" "${servercfgfullpath}"
	fi
	cave="${cave:-"NOT SET"}"
	cluster="${cluster:-"NOT SET"}"
	configip="${configip:-"0.0.0.0"}"
	gamemode="${gamemode:-"NOT SET"}"
	master="${master:-"NOT SET"}"
	masterport="${masterport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	shard="${shard:-"NOT SET"}"
	sharding="${sharding:-"NOT SET"}"
	steamauthport="${steamauthport:-"0"}"
	steammasterport="${steammasterport:-"0"}"
	tickrate="${tickrate:-"0"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_kf() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "httpport" "ListenPort"
		fn_info_game_ini "lanport" "LANServerPort"
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "port" "Port"
		fn_info_game_ini "queryportgs" "QueryPort"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "webadminenabled" "bEnabled"
		fn_info_game_ini "webadminpass" "WebAdminPassword"
		fn_info_game_ini "webadminuser" "AdminName"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	lanport="${lanport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	queryportgs="${queryportgs:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steammasterport="28852"
	steamworksport="20560"
	webadminenabled="${webadminenabled:-"NOT SET"}"
	webadminpass="${adminpassword}"
	webadminuser="${webadminuser:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_kf2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "httpport" "ListenPort" "${servercfgdir}/KFWeb.ini"
		fn_info_game_ini "port" "Port"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "webadminenabled" "bEnabled"
		fn_info_game_ini "webadminpass" "WebAdminPassword"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	webadminenabled="${webadminenabled:-"NOT SET"}"
	webadminpass="${webadminpass:-"NOT SET"}"
	webadminuser="Admin"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_mh() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "ServerPassword"
		fn_info_game_ini "rconpassword" "AdminPassword"
		fn_info_game_ini "maxplayers" "MaxSlots"
	fi
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	beaconport="${beaconport:-"0"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName="SERVERNAME"
# Filetype: cfg
fn_info_game_pstbs() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "reservedslots" "NumReservedSlots"
		fn_info_game_ini "serverpassword" "ServerPassword"
	fi
	if [ -f "${servercfgdir}/Rcon.cfg" ]; then
		fn_info_game_ini "rconpassword" "Password" "${servercfgdir}/Rcon.cfg"
		fn_info_game_ini "rconport" "Port" "${servercfgdir}/Rcon.cfg"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	if [ -z "${queryport}" ]; then
		queryport="${port:-"0"}"
	fi
	randommap="${randommap:-"NOT SET"}"
	if [ -z "${rconpassword}" ] || [ "${#rconpassword}" == 1 ]; then
		rconpassword="NOT SET"
	fi
	rconport="${rconport:-"0"}"
	reservedslots="${reservedslots:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	tickrate="${tickrate:-"0"}"
}

# Config Type: ini
# Parameters: false
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: cfg
fn_info_game_pvr() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "maxplayers" "MaxPlayers"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	port401="$((port + 400))"
	queryport="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: PublicName=SERVERNAME
# Filetype: ini
fn_info_game_pz() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "port" "DefaultPort"
		fn_info_game_ini "rconpassword" "RCONPassword"
		fn_info_game_ini "servername" "PublicName"
		fn_info_game_ini "serverpassword" "Password"
		fn_info_game_ini "worldname" "Map"

	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	worldname="${worldname:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: SERVERNAME=SERVERNAME
# Filetype: ini
fn_info_game_st() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "MAXPLAYER"
		fn_info_game_ini "rconpassword" "RCONPASSWORD"
		fn_info_game_ini "servername" "SERVERNAME"
		fn_info_game_ini "serverpassword" "PASSWORD"
	fi
	clearinterval="${clearinterval:-"0"}"
	httpport="${port:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	saveinterval="${saveinterval:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	worldname="${worldname:-"NOT SET"}"
	worldtype="${worldtype:-"NOT SET"}"

}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_stn() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "configip" "ServerIP"
		fn_info_game_ini "port" "ServerPort"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "ServerPassword"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=ServerName
# Filetype: ini
fn_info_game_ti() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "maxplayers" "MaxPlayerCount"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: ini
# Parameters: false
# Comment: ; or #
# Example: default_voice_port=9987
# Filetype: ini
fn_info_game_ts3() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "configip" "voice_ip"
		fn_info_game_ini "dbplugin" "dbplugin"
		fn_info_game_ini "fileport" "filetransfer_port"
		fn_info_game_ini "port" "default_voice_port"
		fn_info_game_ini "queryhttpport" "query_http_port"
		fn_info_game_ini "queryhttpsport" "query_https_port"
		fn_info_game_ini "queryport" "query_port"
		fn_info_game_ini "querysshport" "query_ssh_port"
	fi
	configip="${configip:-"0.0.0.0"}"
	dbplugin="${dbplugin:-"NOT SET"}"
	fileport="${fileport:-"0"}"
	port="${port:-"0"}"
	queryhttpport="${queryhttpport:-"0"}"
	queryhttpsport="${queryhttpsport:-"0"}"
	queryport="${queryport:-"0"}"
	querysshport="${querysshport:-"0"}"
	telnetport="${queryport}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerTitle=SERVERNAME
# Filetype: ini
fn_info_game_tu() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "servername" "ServerTitle"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	steamport="$((port + 1))"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_ut99() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "beaconport" "ServerBeaconPort"
		fn_info_game_ini "port" "Port"
		fn_info_game_ini "queryportgs" "OldQueryPortNumber"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "webadminenabled" "bEnabled"
		fn_info_game_ini "webadminpass" "AdminPassword"
		fn_info_game_ini "httpport" "ListenPort"
		fn_info_game_ini "webadminuser" "AdminUserName"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	beaconport="${beaconport:-"0"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	queryportgs="${queryportgs:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	webadminenabled="${webadminenabled:-"0"}"
	webadminpass="${webadminpass:-"NOT SET"}"
	webadminuser="${webadminuser:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_ut3() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "webadminenabled" "bEnabled"
		fn_info_game_ini "webadminpass" "AdminPassword"
		fn_info_game_ini "httpport" "ListenPort"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	webadminenabled="${webadminenabled:-"0"}"
	webadminpass="${webadminpass:-"NOT SET"}"
	webadminuser="Admin"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_unreal2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "httpport" "ListenPort"
		fn_info_game_ini "port" "Port"
		fn_info_game_ini "queryportgs" "OldQueryPortNumber"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "webadminenabled" "bEnabled"
		fn_info_game_ini "webadminuser" "AdminName"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	queryportgs="${queryportgs:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	webadminenabled="${webadminenabled:-"0"}"
	webadminpass="${adminpassword:-"NOT SET"}"
	webadminuser="${webadminuser:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName="SERVERNAME"
# Filetype: ini
fn_info_game_ut() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "servername" "ServerName"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	gametype="${gametype:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Example: ServerName=SERVERNAME
# Filetype: ini
fn_info_game_ut2k4() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "httpport" "ListenPort"
		fn_info_game_ini "lanport" "LANServerPort"
		fn_info_game_ini "port" "Port"
		fn_info_game_ini "queryportgs" "OldQueryPortNumber"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "webadminenabled" "bEnabled"
		fn_info_game_ini "webadminuser" "AdminName"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	lanport="${lanport:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	queryportgs="${queryportgs:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	webadminenabled="${webadminenabled:-"0"}"
	webadminpass="${adminpassword}"
	webadminuser="${webadminuser:-"NOT SET"}"
}

# Config Type: json
# Parameters: true
# Comment: // or /* */
# Example: "name": "SERVERNAME",
# Filetype: json
fn_info_game_armar() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "adminpassword" ".adminPassword"
		fn_info_game_json "configip" ".gameHostBindAddress"
		fn_info_game_json "maxplayers" ".game.playerCountLimit"
		fn_info_game_json "port" ".gameHostBindPort"
		fn_info_game_json "queryport" ".steamQueryPort"
		fn_info_game_json "servername" ".game.name"
		fn_info_game_json "serverpassword" ".game.password"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	battleeyeport="$((port + 4))"
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: con
# Parameters: true
# Comment: # or //
# Example: game.serverName "SERVERNAME"
# Filetype: con
fn_info_game_bf1942() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_con "configip" "game.serverIp"
		fn_info_game_con "maxplayers" "game.serverMaxPlayers"
		fn_info_game_con "port" "game.serverPort"
		fn_info_game_con "servername" "game.serverName"
		fn_info_game_con "serverpassword" "game.serverPassword"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="22000"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: con
# Parameters: true
# Comment: # or //
# Example: game.serverName "SERVERNAME"
# Filetype: con
fn_info_game_bfv() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_con "configip" "game.serverIp"
		fn_info_game_con "maxplayers" "game.serverMaxPlayers"
		fn_info_game_con "port" "game.serverPort"
		fn_info_game_con "servername" "game.serverName"
		fn_info_game_con "serverpassword" "game.serverPassword"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="22000"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: XML
# Parameters: false
# Comment: <!-- -->
# Example: <serversettings name="SERVERNAME" />
# Filetype: xml
fn_info_game_bt() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_xml "maxplayers" "/serversettings/@MaxPlayers"
		fn_info_game_xml "port" "/serversettings/@port"
		fn_info_game_xml "queryport" "/serversettings/@queryport"
		fn_info_game_xml "servername" "/serversettings/@name"
		fn_info_game_xml "serverpassword" "/serversettings/@password"
		fn_info_game_xml "tickrate" "/serversettings/@TickRate"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	tickrate="${tickrate:-"0"}"
}

# Config Type: json
# Parameters: false
# Comment: // or /* */
# Example: "game_title":"SERVERNAME"
# Filetype: json
fn_info_game_cd() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "maxplayers" ".player_count"
		fn_info_game_json "port" ".game_port"
		fn_info_game_json "rconenabled" ".rcon"
		fn_info_game_json "rconpassword" ".rcon_password"
		fn_info_game_json "rconport" ".rcon_port"
		fn_info_game_json "servername" ".game_title"
		fn_info_game_json "steamport" ".steam_port_messages"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	rconenabled="${rconenabled:-"NOT SET"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	rconport="${rconport:-"0"}"
	servername="${servername:-"NOT SET"}"
	steamport="${steamport:-"0"}"
}

# Config Type: json
# Parameters: true
# Comment: // or /* */
# Example: "worldName":"SERVERNAME"
# Filetype: json
fn_info_game_ck() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "servername" ".worldName"
		fn_info_game_json "maxplayers" ".maxNumberPlayers"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	servername="${servername:-"NOT SET"}"
}

# Config Type: QuakeC
# Parameters: true
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_cod() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: QuakeC
# Parameters: true
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_coduo() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: QuakeC
# Parameters: true
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_cod2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: QuakeC
# Parameters: true
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_cod4() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "rconpassword" "rcon_password"
		fn_info_game_quakec "servername" "sv_hostname"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: QuakeC
# Parameters: true
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_codwaw() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "rconpassword" "rcon_password"
		fn_info_game_quakec "servername" "sv_hostname"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: json
# Parameters: false
# Comment: // or /* */
# Example: "ServerName": "SERVERNAME"
# Filetype: json
fn_info_game_col() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "configip" ".ServerSettings.ServerIP"
		fn_info_game_json "maxplayers" ".ServerSettings.MaxPlayerCount"
		fn_info_game_json "port" ".ServerSettings.ServerGamePort"
		fn_info_game_json "rconpassword" ".ServerSettings.RCONPassword"
		fn_info_game_json "servername" ".ServerSettings.ServerName"
		fn_info_game_json "serverpassword" ".ServerSettings.ServerPassword"
		fn_info_game_json "steamport" ".ServerSettings.ServerSteamPort"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port:-"0"}"
	rcpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steamport="${steamport:-"0"}"
}

# Config Type: SQF
# Parameters: true
# Comment: // or /* */
# Example: serverName = "SERVERNAME";
# Filetype: cfg
fn_info_game_dayz() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_sqf "adminpassword" "passwordAdmin"
		fn_info_game_sqf "maxplayers" "maxPlayers"
		fn_info_game_sqf "queryport" "steamQueryPort"
		fn_info_game_sqf "servername" "hostname"
		fn_info_game_sqf "serverpassword" "password"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	battleeyeport="$((port + 4))"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steammasterport="$((port + 2))"
}

# Config Type: json
# Parameters: false
# Comment: // or /* */
# Example: "Description": "SERVERNAME"
# Filetype: json
fn_info_game_eco() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "configip" ".IPAddress"
		fn_info_game_json "httpport" ".WebServerPort"
		fn_info_game_json "maxplayers" ".MaxConnections"
		fn_info_game_json "port" ".GameServerPort"
		fn_info_game_json "servername" ".Description"
		fn_info_game_json "serverpassword" ".Password"
		fn_info_game_json "tickrate" ".Rate"
	fi
	configip="${configip:-"0.0.0.0"}"
	httpport="${httpport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	tickrate="${tickrate:-"0"}"
}

# Config Type: QuakeC
# Parameters: true
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_etl() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "configip" "net_ip"
		fn_info_game_quakec "maxplayers" "sv_maxclients"
		fn_info_game_quakec "port" "net_port"
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
		fn_info_game_quakec "serverpassword" "g_password"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: json
# Parameters: true
# Comment: // or /* */
# Example: "name": "SERVERNAME"
# Filetype: json
fn_info_game_fctr() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "authtoken" ".token"
		fn_info_game_json "maxplayers" ".max_players"
		fn_info_game_json "savegameinterval" ".autosave_interval"
		fn_info_game_json "servername" ".name"
		fn_info_game_json "serverpassword" ".game_password"
		fn_info_game_json "versioncount" ".autosave_slots"
	fi
	authtoken="${authtoken:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	rconport="${rconport:-"0"}"
	savegameinterval="${savegameinterval:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	versioncount="${versioncount:-"0"}"

	# get server version if installed.
	local factoriobin="${executabledir}${executable:1}"
	if [ -f "${factoriobin}" ]; then
		serverversion="$(${factoriobin} --version | grep "Version:" | awk '{print $2}')"
	fi
}

# Config Type: parameters (json possibly supported)
# Parameters: true
# Comment:
# Example: -serverName="SERVERNAME"
# Filetype: parameters
fn_info_game_hw() {
	servername="${servername:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	creativemode="${creativemode:-"NOT SET"}"
}

# Config Type: parameters
# Parameters: true
# Comment:
# Example: -hostname='SERVERNAME'
# Filetype: parameters
fn_info_game_inss() {
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	rconport="${rconport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	defaultscenario="${defaultscenario:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
}

# Config Type: lua (Custom)
# Parameters: false
# Comment: --
# Example: Name = "SERVERNAME",
# Filetype: lua
fn_info_game_jc2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_lua "configip" "BindIP"
		fn_info_game_lua "maxplayers" "MaxPlayers"
		fn_info_game_lua "port" "BindPort"
		fn_info_game_lua "serverdescription" "Description"
		fn_info_game_lua "servername" "Name"
		fn_info_game_lua "serverpassword" "Password"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	queryport="${port}"
	queryport="${queryport:-"0"}"
	serverdescription="${serverdescription:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: json
# Parameters: false
# Comment: // or /* */
# Example: "name": "SERVERNAME"
# Filetype: json
fn_info_game_jc3() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "configip" ".host"
		fn_info_game_json "httpport" ".httpPort"
		fn_info_game_json "maxplayers" ".maxPlayers"
		fn_info_game_json "port" ".port"
		fn_info_game_json "queryport" ".queryPort"
		fn_info_game_json "serverdescription" ".description"
		fn_info_game_json "servername" ".name"
		fn_info_game_json "serverpassword" ".password"
		fn_info_game_json "steamport" ".steamPort"
		fn_info_game_json "tickrate" ".maxTickRate"
	fi
	configip="${configip:-"0.0.0.0"}"
	httpport="${httpport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	serverdescription="${serverdescription:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steamport="${steamport:-"0"}"
	tickrate="${tickrate:-"0"}"
}

# Config Type: QuakeC
# Parameters: true
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_jk2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "maxplayers" "sv_maxclients"
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
		fn_info_game_quakec "serverpassword" "g_password"
		fn_info_game_quakec "serverversion" "mv_serverversion"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	serverversion="${serverversion:-"NOT SET"}"
}

# Config Type: unknown
fn_info_game_lo() {
	servername="${servername:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	maxplayers="${slots:-"0"}"
}

# Config Type: Java properties
# Comment: # or !
# Example: motd=SERVERNAME
# Filetype: properties
fn_info_game_mc() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_java_properties "configip" "server-ip"
		fn_info_game_java_properties "gamemode" "gamemode"
		fn_info_game_java_properties "maxplayers" "max-players"
		fn_info_game_java_properties "port" "server-port"
		fn_info_game_java_properties "queryenabled" "enable-query"
		fn_info_game_java_properties "queryport" "query.port"
		fn_info_game_java_properties "rconpassword" "rcon.password"
		fn_info_game_java_properties "rconport" "rcon.port"
		fn_info_game_java_properties "servername" "motd"
		fn_info_game_java_properties "worldname" "level-name"
	fi
	servername="${servername:-"NOT SET"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	rconport="${rconport:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"NOT SET"}"
	queryport="${queryport:-"NOT SET"}"
	queryenabled="${queryenabled:-"NOT SET"}"
	gamemode="${gamemode:-"NOT SET"}"
	worldname="${worldname:-"NOT SET"}"
	configip="${configip:-"0.0.0.0"}"
	if [ -z "${queryport}" ]; then
		queryport="${port}"
	fi
}

# Config Type: Java properties
# Comment: # or !
# Example: server-name=SERVERNAME
# Filetype: properties
fn_info_game_mcb() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_java_properties "servername" "server-name"
		fn_info_game_java_properties "maxplayers" "max-players"
		fn_info_game_java_properties "port" "server-port"
		fn_info_game_java_properties "portv6" "server-portv6"
		fn_info_game_java_properties "gamemode" "gamemode"
		fn_info_game_java_properties "worldname" "level-name"
	fi
	servername="${servername:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	queryport="${port}"
	portipv6="${portipv6:-"NOT SET"}"
	queryport="${queryport:-"NOT SET"}"
	gamemode="${gamemode:-"NOT SET"}"
	worldname="${worldname:-"NOT SET"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_mohaa() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "maxplayers" "sv_maxclients"
		fn_info_game_quakec "rconpassword" "rconPassword"
		fn_info_game_quakec "servername" "sv_hostname"
		fn_info_game_quakec "serverpassword" "g_password"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: json
# Parameters: true
# Comment: // or /* */
fn_info_game_mom() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "defaultmap" ".MapName"
		fn_info_game_json "maxplayers" ".maxPlayers"
		fn_info_game_json "servername" ".serverName"
		fn_info_game_json "serverpassword" ".serverPassword"
	fi
	beaconport="${beaconport:-"0"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: xml
# Comment: <!-- -->
# Example: <servername>Default MTA Server</servername>
# Filetype: conf
fn_info_game_mta() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_xml "port" "/config/@port"
		fn_info_game_xml "httpport" "/config/@httpport"
		fn_info_game_xml "servername" "/config/@servername"
		fn_info_game_xml "maxplayers" "/config/@maxplayers"
		fn_info_game_xml "ase" "/config/@ase"
	fi
	if [ "${ase}" == "1" ]; then
		ase="Enabled"
	else
		ase="Disabled"
	fi
	port="${port:-"0"}"
	queryport="$((port + 123))"
	httpport="${httpport:-"0"}"
	ase="${ase:-"Disabled"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
}

# Config Type: custom
# Comment: //
# Example: port = 14159,
# Filetype: cfg
fn_info_game_nec() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_lua "maxplayers" "slots"
		fn_info_game_lua "port" "port"
		fn_info_game_lua "serverpassword" "password"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	servername="Necesse Port ${port}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: json
# Parameters: false
# Comment: // or /* */
fn_info_game_onset() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "maxplayers" ".maxplayers"
		fn_info_game_json "port" ".port"
		fn_info_game_json "servername" ".servername_short"
		fn_info_game_json "serverpassword" ".password"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	httpport="$((port - 2))"
	queryport="$((port - 1))"
	servername="${servername:-"NOT SET"}"
}

# Config Type: custom
# Parameters: false
# Comment: //
# Filetype: cfg
fn_info_game_pc() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_pc_config "servername" "name"
		fn_info_game_pc_config "serverpassword" "password"
		fn_info_game_pc_config "maxplayers" "MaxPlayers"
		fn_info_game_pc_config "port" "hostPort"
		fn_info_game_pc_config "queryport" "queryPort"
		fn_info_game_pc_config "steamport" "steamPort"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steamport="${steamport:-"0"}"
}

fn_info_game_pc2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_pc_config "servername" "name"
		fn_info_game_pc_config "serverpassword" "password"
		fn_info_game_pc_config "maxplayers" "MaxPlayers"
		fn_info_game_pc_config "port" "hostPort"
		fn_info_game_pc_config "queryport" "queryPort"
		fn_info_game_pc_config "steamport" "steamPort"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steamport="${steamport:-"0"}"
}

# Config Type: SiiNunit
# Comment: //
# Example: lobby_name: "SERVERNAME"
# Filetype: ssi
fn_info_game_prism3d() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		maxplayers="${unavailable}"
		port="${zero}"
		queryport="${zero}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
	else
		maxplayers=$(sed -nr 's/^\s*max_players\s*:\s*([0-9]+)/\1/p' "${servercfgfullpath}")
		port=$(sed -nr 's/^\s*connection_dedicated_port\s*:\s*([0-9]+)/\1/p' "${servercfgfullpath}")
		queryport=$(sed -nr 's/^\s*query_dedicated_port\s*:\s*([0-9]+)/\1/p' "${servercfgfullpath}")
		servername=$(sed -nr 's/^\s*lobby_name\s*:\s*"?([^"\r\n]+)"?/\1/p' "${servercfgfullpath}")
		serverpassword=$(sed -nr 's/^\s*password\s*:\s*"(.*)"/\1/p' "${servercfgfullpath}")

		# Not set
		maxplayers=${maxplayers:-"0"}
		port=${port:-"27015"}
		queryport=${queryport:-"27016"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
	fi
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_q2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "maxplayers" "maxclients"
		fn_info_game_quakec "rconpassword" "rcon_password"
		fn_info_game_quakec "servername" "hostname"
	fi
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_q3() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "maxplayers" "sv_maxclients"
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
	fi
	maxplayers="${maxplayers:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${port}"
	defaultmap="${defaultmap:-"NOT SET"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_ql() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "configip" "net_ip"
		fn_info_game_quakec "maxplayers" "sv_maxClients"
		fn_info_game_quakec "port" "net_port"
		fn_info_game_quakec "rconpassword" "zmq_rcon_password"
		fn_info_game_quakec "rconport" "zmq_rcon_port"
		fn_info_game_quakec "servername" "sv_hostname"
		fn_info_game_quakec "serverpassword" "g_password"
		fn_info_game_quakec "statsport" "zmq_stats_port"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	rconport="${rconport:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	statsport="${statsport:-"0"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_qw() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "maxplayers" "maxclients"
		fn_info_game_quakec "rconpassword" "rcon_password"
		fn_info_game_quakec "servername" "hostname"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

fn_info_game_ro() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_ini "adminpassword" "AdminPassword"
		fn_info_game_ini "httpport" "ListenPort"
		fn_info_game_ini "lanport" "LANServerPort"
		fn_info_game_ini "maxplayers" "MaxPlayers"
		fn_info_game_ini "port" "Port"
		fn_info_game_ini "queryportgs" "QueryPort"
		fn_info_game_ini "servername" "ServerName"
		fn_info_game_ini "serverpassword" "GamePassword"
		fn_info_game_ini "webadminenabled" "bEnabled"
		fn_info_game_ini "webadminpass" "WebAdminPassword"
		fn_info_game_ini "webadminuser" "AdminName"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	lanport="${lanport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	queryportgs="${queryportgs:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	steamport="20610"
	steammasterport="28902"
	webadminenabled="${webadminenabled:-"NOT SET"}"
	webadminpass="${adminpassword}"
	webadminuser="${webadminuser:-"NOT SET"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_rtcw() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
		fn_info_game_quakec "serverpassword" "g_password"
		fn_info_game_quakec "maxplayers" "sv_maxclients"
	fi
	rconpassword=${rconpassword:-"NOT SET"}
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	port=${port:-"0"}
	queryport=${port:-"0"}
	defaultmap=${defaultmap:-"NOT SET"}
}

# Config Type: Parameters (mostly)
fn_info_game_rust() {
	# Parameters
	servername=${servername:-"NOT SET"}
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	appport=${appport:-"0"}
	rconport=${rconport:-"0"}
	gamemode=${gamemode:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
	rconpassword=${rconpassword:-"NOT SET"}
	rconweb=${rconweb:-"NOT SET"}
	tickrate=${tickrate:-"0"}
	saveinterval=${saveinterval:-"0"}
	serverlevel=${serverlevel:-"NOT SET"}
	customlevelurl=${customlevelurl:-"NOT SET"}
	worldsize=${worldsize:-"0"}
	if [ -n "${seed}" ]; then
		seed=${seed:-"0"}
	elif [ -f "${datadir}/${selfname}-seed.txt" ]; then
		seed=$(cat "${datadir}/${selfname}-seed.txt")
	fi
	salt=${salt:-"0"}
}

fn_info_game_rw() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		serverpassword="${unavailable}"
		rconpassword="${unavailable}"
		rconport="${zero}"
		maxplayers="${zero}"
		port="${zero}"
		port2="${zero}"
		port3="${zero}"
		port4="${zero}"
		queryport="${zero}"
		gamemode="${unavailable}"
		worldname="${unavailable}"
	else
		servername=$(grep "server_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "server_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconport=$(grep "rcon_port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		maxplayers=$(grep "settings_max_players" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		port=$(grep "server_port" "${servercfgfullpath}" | grep -v "database_mysql_server_port" | grep -v "#" | tr -cd '[:digit:]')
		port2=$((port + 1))
		port3=$((port + 2))
		port4=$((port + 3))
		queryport="${port}"
		httpqueryport=$((port - 1))
		gamemode=$(grep "settings_default_gamemode=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/settings_default_gamemode//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		worldname=$(grep "server_world_name" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/server_world_name//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		configip=$(grep "server_ip" "${servercfgfullpath}" | grep -v "database_mysql_server_ip" | sed -e 's/^[ \t]*//g' -e '/^--/d' -e 's/server_ip//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		rconport=${rconport:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		port=${port:-"0"}
		port2=${port2:-"0"}
		port3=${port3:-"0"}
		port4=${port4:-"0"}
		queryport=${queryport:-"0"}
		httpqueryport=${httpport:-"0"}
		gamemode=${gamemode:-"NOT SET"}
		worldname=${worldname:-"NOT SET"}
		configip=${configip:-"0.0.0.0"}
	fi
}

# Config Type: custom
# Comment: // or /* */
# example: hostname "SERVERNAME"
# filetypes: cfg
fn_info_game_samp() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="unnamed server"
		rconpassword="${unavailable}"
		port="7777"
		rconport="${port}"
		maxplayers="50"
	else
		servername=$(grep "hostname" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/hostname//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rcon_password" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/^rcon_password//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "port" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryport=${port}
		rconport=${port}
		maxplayers=$(grep "maxplayers" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"7777"}
		queryport=${port:-"7777"}
		rconport=${rconport:-"7777"}
		maxplayers=${maxplayers:-"12"}
	fi
}

fn_info_game_sb() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		queryenabled="${unavailable}"
		rconenabled="${unavailable}"
		rconpassword="${unavailable}"
		port="21025"
		queryport="21025"
		rconport="21026"
		maxplayers="8"
	else
		servername=$(grep "serverName" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/serverName//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		queryenabled=$(grep "runQueryServer" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/runQueryServer//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconenabled=$(grep "runRconServer" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/runRconServer//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		rconpassword=$(grep "rconServerPassword" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e 's/rconServerPassword//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		port=$(grep "gameServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		queryport=$(grep "queryServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		rconport=$(grep "rconServerPort" "${servercfgfullpath}" | tr -cd '[:digit:]')
		maxplayers=$(grep "maxPlayers" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		queryenabled=${queryenabled:-"NOT SET"}
		rconenabled=${rconenabled:-"NOT SET"}
		rconpassword=${rconpassword:-"NOT SET"}
		port=${port:-"21025"}
		queryport=${queryport:-"21025"}
		rconport=${rconport:-"21026"}
		maxplayers=${maxplayers:-"8"}
	fi
}

fn_info_game_sbots() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${unavailable}"
	else
		servername=$(grep "ServerName=" "${servercfgfullpath}" | sed -e 's/^[ \t]//g' -e '/^#/d' -e 's/ServerName//g' | tr -d '=";,:' | sed -e 's/^[ \t]//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MaxPlayers=" "${servercfgfullpath}" | tr -cd '[:digit:]')

		# Not set
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${queryport:-"0"}
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	defaultmap=${defaultmap:-"NOT SET"}
	maxplayers=${maxplayers:-"0"}
}

# Config Type: custom (possibly YAML)
# Comment: #
# Example: server_name: SERVERNAME
# Filetype: txt
fn_info_game_scpsl() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		servername=${servername:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
		configip=${configip:-"0.0.0.0"}
		tickrate=${tickrate:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
	else
		servername=$(sed -nr 's/^server_name: (.*)$/\1/p' "${servercfgfullpath}")
		maxplayers=$(sed -nr 's/^max_players: (.*)$/\1/p' "${servercfgfullpath}")
		configip=$(sed -nr 's/^ipv4_bind_ip: (.*)$/\1/p' "${servercfgfullpath}")
		tickrate=$(sed -nr 's/^server_tickrate: (.*)$/\1/p' "${servercfgfullpath}")
		adminpassword=$(sed -nr 's/^administrator_query_password: (.*)$/\1/p' "${servercfgfullpath}")
	fi

	# Parameters
	port=${port:-"0"}
	queryport=${port}
}

# Config Type: xml
# Comment: <!-- -->
# Example: <property name="ServerName" 				value="My Game Host"/>
# Filetype: xml
fn_info_game_sdtd() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_xml "gamemode" "ServerSettings/@GameMode"
		fn_info_game_xml "maxplayers" "ServerSettings/@MaxPlayers"
		fn_info_game_xml "servername" "ServerSettings/@ServerName"
		fn_info_game_xml "serverpassword" "ServerSettings/@ServerPassword"
		fn_info_game_xml "serverport" "ServerSettings/@ServerPort"
		fn_info_game_xml "telnetenabled" "ServerSettings/@TelnetEnabled"
		fn_info_game_xml "telnetpass" "ServerSettings/@TelnetPassword"
		fn_info_game_xml "telnetport" "ServerSettings/@TelnetPort"
		fn_info_game_xml "webadminenabled" "ServerSettings/@ControlPanelEnabled"
		fn_info_game_xml "webadminpass" "ServerSettings/@ControlPanelPassword"
		fn_info_game_xml "httpport" "ServerSettings/@ControlPanelPort"
		fn_info_game_xml "worldname" "ServerSettings/@GameWorld"

	fi
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	webadminenabled="${webadminenabled:-"NOT SET"}"
	httpport="${httpport:-"0"}"
	webadminpass="${webadminpass:-"NOT SET"}"
	telnetenabled="${telnetenabled:-"NOT SET"}"
	telnetport="${telnetport:-"0"}"
	telnetpass="${telnetpass:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	gamemode="${gamemode:-"NOT SET"}"
	worldname="${worldname:-"NOT SET"}"
	# Telnet IP will be localhost if no password is set
	# check_ip will set the IP first. This will overwrite it.
	if [ -z "${telnetpass}" ]; then
		telnetip="127.0.0.1"
	fi
}

# Config Type: Parameters (with an ini)
fn_info_game_sf() {
	# Parameters
	servername="${selfname:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	beaconport="${beaconport:-"0"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_sof2() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "rconpassword" "rconpassword"
		fn_info_game_quakec "servername" "sv_hostname"
		fn_info_game_quakec "serverpassword" "g_password"
		fn_info_game_quakec "maxplayers" "sv_maxclients"
	fi
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port}"
	defaultmap="${defaultmap:-"NOT SET"}"
}

# Config Type: ini
# Parameters: true
# Comment: ; or #
# Server_Name=SERVERNAME
# Filetype: ini
fn_info_game_sol() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_config_ini "adminpassword" "Admin_Password"
		fn_info_config_ini "maxplayers" "Max_Players"
		fn_info_config_ini "port" "Port"
		fn_info_config_ini "servername" "Server_Name"
		fn_info_config_ini "serverpassword" "Game_Password"
	fi
	adminpassword="${adminpassword:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	filesport="$((port + 10))"
	queryport="${port}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: Valve KeyValues
# Comment: //
# Example: hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_source() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_valve_keyvalues "rconpassword" "rcon_password"
		fn_info_game_valve_keyvalues "servername" "hostname"
		fn_info_game_valve_keyvalues "serverpassword" "sv_password"
	fi
	# Steamport can be between 26901-26910 and is normally automatically set.
	# Some servers might support -steamport parameter to set
	if [ "${steamport}" == "0" ] || [ -v "${steamport}" ]; then
		steamport="$(echo "${ssinfo}" | grep "${srcdslinuxpid}" | awk '{print $5}' | grep ":269" | cut -d ":" -f2)"
	fi
	clientport="${clientport:-"0"}"
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	rconport="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	# steamport="${steamport:-"0"}" Steamport is optional so we dont want it to show as not set.
}

fn_info_game_spark() {
	defaultmap="${defaultmap:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="$((port + 1))"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	webadminuser="${webadminuser:-"NOT SET"}"
	webadminpass="${webadminpass:-"NOT SET"}"
	httpport="${httpport:-"0"}"
}

# Config Type: Custom (key-value pairs)
# Parameters: true
# Comment: # or //
# Example: ServerName="SERVERNAME"
# Filetype: cfg
fn_info_game_squad() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_keyvalue_pairs "servername" "ServerName"
		fn_info_game_keyvalue_pairs "maxplayers" "MaxPlayers"
	fi
	if [ -f "${servercfgdir}/Rcon.cfg" ]; then
		fn_info_game_keyvalue_pairs "rconport" "Port"
		fn_info_game_keyvalue_pairs "rconpassword" "Password"
	fi
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	rconport="${rconport:-"0"}"
	servername="${servername:-"NOT SET"}"
	if [ -z "${rconpassword}" ] || [ ${#rconpassword} == 1 ]; then
		rconpassword="NOT SET"
	fi
}

# Config Type: Custom (key-value pairs)
# Comment: # or //
# Example: ServerName="SERVERNAME"
# Filetype: cfg
fn_info_game_terraria() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_keyvalue_pairs "maxplayers" "maxplayers"
		fn_info_game_keyvalue_pairs "port" "port"
		fn_info_game_keyvalue_pairs "servername" "worldname"
		fn_info_game_keyvalue_pairs "worldname" "world"
	fi
	queryport="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	worldname="${worldname:-"NOT SET"}"
	maxplayers="${maxplayers:-"0"}"
}

# Config Type: QuakeC (custom)
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_tw() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "servername" "sv_name"
		fn_info_game_quakec "serverpassword" "password"
		fn_info_game_quakec "rconpassword" "sv_rcon_password"
		fn_info_game_quakec "port" "sv_port"
		fn_info_game_quakec "maxplayers" "sv_max_clients"
	fi
	queryport="${port}"
	servername=${servername:-"NOT SET"}
	serverpassword=${serverpassword:-"NOT SET"}
	rconpassword=${rconpassword:-"NOT SET"}
	port=${port:-"0"}
	maxplayers=${maxplayers:-"0"}
}

# Config Type: Parameters
fn_info_game_unt() {
	servername="${selfname:-"NOT SET"}"
	port="${port:-"0"}"
	queryport="${port}"
	steamport="$((port + 1))"
}

# Config Type: Parameters
fn_info_game_vh() {
	port="${port:-"0"}"
	# Query port only enabled if public server
	if [ "${public}" != "0" ]; then
		queryport="$((port + 1))"
	else
		querymode="1"
	fi
	worldname="${worldname:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: json
# Parameters: false
# Comment: // or /* */
fn_info_game_vints() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_json "configip" "select(.Ip != null) | .Ip"
		fn_info_game_json "maxplayers" ".MaxClients"
		fn_info_game_json "port" ".Port"
		fn_info_game_json "servername" ".ServerName"
		fn_info_game_json "serverpassword" "select(.Password != null) | .Password"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: Java properties
# Comment: # or !
# Example: motd=SERVERNAME
# Filetype: properties
fn_info_game_vpmc() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_java_properties "servername" "motd"
		fn_info_game_java_properties "bindaddress" "bind"
	fi
	configip="$(echo "${bindaddress}" | cut -d ':' -f 1)"
	port="$(echo "${bindaddress}" | cut -d ':' -f 2)"
	queryport="${port:-"0"}"
	servername="${servername:-"NOT SET"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_wet() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "configip" "net_ip"
		fn_info_game_quakec "maxplayers" "sv_maxclients"
		fn_info_game_quakec "port" "net_port"
		fn_info_game_quakec "rconpassword" "zmq_rcon_password"
		fn_info_game_quakec "servername" "sv_hostname"
		fn_info_game_quakec "serverpassword" "g_password"
	fi
	configip="${configip:-"0.0.0.0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${queryport:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
	serverpassword="${serverpassword:-"NOT SET"}"
}

# Config Type: QuakeC
# Comment: // or /* */
# Example: set sv_hostname "SERVERNAME"
# Filetype: cfg
fn_info_game_wf() {
	if [ -f "${servercfgfullpath}" ]; then
		fn_info_game_quakec "maxplayers" "sv_maxclients"
		fn_info_game_quakec "rconpassword" "rcon_password"
		fn_info_game_quakec "servername" "sv_hostname"
	fi
	httpport="${httpport:-"0"}"
	maxplayers="${maxplayers:-"0"}"
	port="${port:-"0"}"
	queryport="${port:-"0"}"
	rconpassword="${rconpassword:-"NOT SET"}"
	servername="${servername:-"NOT SET"}"
}

fn_info_game_wmc() {
	if [ ! -f "${servercfgfullpath}" ]; then
		servername="${unavailable}"
		maxplayers="${zero}"
		port="${zero}"
		queryport="${zero}"
		queryenabled="${unavailable}"
	else
		servername=$(sed -e '/^listeners:/,/^[a-z]/!d' "${servercfgfullpath}" | sed -nr 's/^[ ]+motd: (.*)$/\1/p' | tr -d "'" | sed 's/&1//')
		queryport=$(sed -nr 's/^[ -]+query_port: ([0-9]+)/\1/p' "${servercfgfullpath}")
		queryenabled=$(sed -nr 's/^[ ]+query_enabled: (.*)$/\1/p' "${servercfgfullpath}")
		port=$(sed -nr 's/^[ ]+host: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:([0-9]+)/\1/p' "${servercfgfullpath}")
		# the normal max_players does only show in on the client side and has no effect how many players can connect.
		maxplayers=$(sed -nr 's/^player_limit: ([-]*[0-9])/\1/p' "${servercfgfullpath}")
		configip=$(sed -nr 's/^[ ]+host: ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):[0-9]+/\1/p' "${servercfgfullpath}")

		if [ "${maxplayers}" == "-1" ] || [ "${maxplayers}" == "0" ]; then
			maxplayers="UNLIMITED"
		fi

		# Not set
		servername=${servername:-"NOT SET"}
		queryport=${queryport:-"25577"}
		maxplayers=${maxplayers:-"0"}
		configip=${configip:-"0.0.0.0"}
	fi
}

# Config Type: custom (key-value)
# Comment: #
# Example: SERVERNAME=SERVERNAME
fn_info_game_wurm() {
	# Config
	if [ ! -f "${servercfgfullpath}" ]; then
		port="${zero}"
		queryport="${zero}"
		rconpassword="${unavailable}"
		servername="${unavailable}"
		serverpassword="${unavailable}"
		adminpassword="${unavailable}"
		maxplayers="${zero}"
	else
		port=$(grep "EXTERNALPORT=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		queryport=$(grep "QUERYPORT=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		servername=$(grep "SERVERNAME=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/SERVERNAME//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		serverpassword=$(grep "SERVERPASSWORD=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/SERVERPASSWORD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		adminpassword=$(grep "ADMINPWD=" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^\//d' -e 's/ADMINPWD//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')
		maxplayers=$(grep "MAXPLAYERS=" "${servercfgfullpath}" | grep -v "#" | tr -cd '[:digit:]')
		configip=$(grep "IP" "${servercfgfullpath}" | sed -e 's/^[ \t]*//g' -e '/^#/d' -e 's/IP//g' | tr -d '=\";,:' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

		# Not set
		port=${port:-"3724"}
		queryport=${queryport:-"27017"}
		servername=${servername:-"NOT SET"}
		serverpassword=${serverpassword:-"NOT SET"}
		adminpassword=${adminpassword:-"NOT SET"}
		maxplayers=${maxplayers:-"0"}
	fi
}

unavailable="${red}UNAVAILABLE${default}"
zero="${red}0${default}"

if [ "${shortname}" == "ac" ]; then
	fn_info_game_ac
elif [ "${shortname}" == "ark" ]; then
	fn_info_game_ark
elif [ "${shortname}" == "arma3" ]; then
	fn_info_game_arma3
elif [ "${shortname}" == "armar" ]; then
	fn_info_game_armar
elif [ "${shortname}" == "av" ]; then
	fn_info_game_av
elif [ "${shortname}" == "bf1942" ]; then
	fn_info_game_bf1942
elif [ "${shortname}" == "bfv" ]; then
	fn_info_game_bfv
elif [ "${shortname}" == "bo" ]; then
	fn_info_game_bo
elif [ "${shortname}" == "bt" ]; then
	fn_info_game_bt
elif [ "${shortname}" == "btl" ]; then
	fn_info_game_btl
elif [ "${shortname}" == "cd" ]; then
	fn_info_game_cd
elif [ "${shortname}" == "ck" ]; then
	fn_info_game_ck
elif [ "${shortname}" == "cmw" ]; then
	fn_info_game_cmw
elif [ "${shortname}" == "cod" ]; then
	fn_info_game_cod
elif [ "${shortname}" == "coduo" ]; then
	fn_info_game_cod
elif [ "${shortname}" == "cod2" ]; then
	fn_info_game_cod2
elif [ "${shortname}" == "cod4" ]; then
	fn_info_game_cod4
elif [ "${shortname}" == "codwaw" ]; then
	fn_info_game_codwaw
elif [ "${shortname}" == "col" ]; then
	fn_info_game_col
elif [ "${shortname}" == "dayz" ]; then
	fn_info_game_dayz
elif [ "${shortname}" == "dodr" ]; then
	fn_info_game_dodr
elif [ "${shortname}" == "dst" ]; then
	fn_info_game_dst
elif [ "${shortname}" == "eco" ]; then
	fn_info_game_eco
elif [ "${shortname}" == "etl" ]; then
	fn_info_game_etl
elif [ "${shortname}" == "fctr" ]; then
	fn_info_game_fctr
elif [ "${shortname}" == "hw" ]; then
	fn_info_game_hw
elif [ "${shortname}" == "inss" ]; then
	fn_info_game_inss
elif [ "${shortname}" == "jc2" ]; then
	fn_info_game_jc2
elif [ "${shortname}" == "jc3" ]; then
	fn_info_game_jc3
elif [ "${shortname}" == "jk2" ]; then
	fn_info_game_jk2
elif [ "${shortname}" == "kf" ]; then
	fn_info_game_kf
elif [ "${shortname}" == "kf2" ]; then
	fn_info_game_kf2
elif [ "${shortname}" == "lo" ]; then
	fn_info_game_lo
elif [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ]; then
	fn_info_game_mc
elif [ "${shortname}" == "mcb" ]; then
	fn_info_game_mcb
elif [ "${shortname}" == "mh" ]; then
	fn_info_game_mh
elif [ "${shortname}" == "mohaa" ]; then
	fn_info_game_mohaa
elif [ "${shortname}" == "mom" ]; then
	fn_info_game_mom
elif [ "${shortname}" == "mta" ]; then
	fn_info_game_mta
elif [ "${shortname}" == "nec" ]; then
	fn_info_game_nec
elif [ "${shortname}" == "onset" ]; then
	fn_info_game_onset
elif [ "${shortname}" == "pc" ]; then
	fn_info_game_pc
elif [ "${shortname}" == "pc2" ]; then
	fn_info_game_pc2
elif [ "${shortname}" == "pstbs" ]; then
	fn_info_game_pstbs
elif [ "${shortname}" == "pvr" ]; then
	fn_info_game_pvr
elif [ "${shortname}" == "pz" ]; then
	fn_info_game_pz
elif [ "${shortname}" == "q2" ]; then
	fn_info_game_q2
elif [ "${shortname}" == "q3" ]; then
	fn_info_game_q3
elif [ "${shortname}" == "ql" ]; then
	fn_info_game_ql
elif [ "${shortname}" == "qw" ]; then
	fn_info_game_qw
elif [ "${shortname}" == "ro" ]; then
	fn_info_game_ro
elif [ "${shortname}" == "rtcw" ]; then
	fn_info_game_rtcw
elif [ "${shortname}" == "rust" ]; then
	fn_info_game_rust
elif [ "${shortname}" == "rw" ]; then
	fn_info_game_rw
elif [ "${shortname}" == "samp" ]; then
	fn_info_game_samp
elif [ "${shortname}" == "sb" ]; then
	fn_info_game_sb
elif [ "${shortname}" == "sbots" ]; then
	fn_info_game_sbots
elif [ "${shortname}" == "scpsl" ] || [ "${shortname}" == "scpslsm" ]; then
	fn_info_game_scpsl
elif [ "${shortname}" == "sdtd" ]; then
	fn_info_game_sdtd
elif [ "${shortname}" == "sf" ]; then
	fn_info_game_sf
elif [ "${shortname}" == "sof2" ]; then
	fn_info_game_sof2
elif [ "${shortname}" == "sol" ]; then
	fn_info_game_sol
elif [ "${engine}" == "spark" ]; then
	fn_info_game_spark
elif [ "${shortname}" == "squad" ]; then
	fn_info_game_squad
elif [ "${shortname}" == "st" ]; then
	fn_info_game_st
elif [ "${shortname}" == "stn" ]; then
	fn_info_game_stn
elif [ "${shortname}" == "terraria" ]; then
	fn_info_game_terraria
elif [ "${shortname}" == "ti" ]; then
	fn_info_game_ti
elif [ "${shortname}" == "ts3" ]; then
	fn_info_game_ts3
elif [ "${shortname}" == "tu" ]; then
	fn_info_game_tu
elif [ "${shortname}" == "tw" ]; then
	fn_info_game_tw
elif [ "${shortname}" == "unt" ]; then
	fn_info_game_unt
elif [ "${shortname}" == "ut" ]; then
	fn_info_game_ut
elif [ "${shortname}" == "ut2k4" ]; then
	fn_info_game_ut2k4
elif [ "${shortname}" == "ut3" ]; then
	fn_info_game_ut3
elif [ "${shortname}" == "ut99" ]; then
	fn_info_game_ut99
elif [ "${shortname}" == "vh" ]; then
	fn_info_game_vh
elif [ "${shortname}" == "vints" ]; then
	fn_info_game_vints
elif [ "${shortname}" == "vpmc" ]; then
	fn_info_game_vpmc
elif [ "${shortname}" == "wet" ]; then
	fn_info_game_wet
elif [ "${shortname}" == "wf" ]; then
	fn_info_game_wf
elif [ "${shortname}" == "wmc" ]; then
	fn_info_game_wmc
elif [ "${shortname}" == "wurm" ]; then
	fn_info_game_wurm
elif [ "${engine}" == "prism3d" ]; then
	fn_info_game_prism3d
elif [ "${engine}" == "source" ] || [ "${engine}" == "goldsrc" ]; then
	fn_info_game_source
elif [ "${engine}" == "unreal2" ]; then
	fn_info_game_unreal2
fi

# External IP address
# Cache external IP address for 24 hours
if [ -f "${tmpdir}/extip.txt" ]; then
	if [ "$(find "${tmpdir}/extip.txt" -mmin +1440)" ]; then
		rm -f "${tmpdir:?}/extip.txt"
	fi
fi

if [ ! -f "${tmpdir}/extip.txt" ]; then
	extip="$(curl --connect-timeout 10 -s https://api.ipify.org 2> /dev/null)"
	exitcode=$?
	# if curl passes add extip to externalip.txt
	if [ "${exitcode}" == "0" ]; then
		echo "${extip}" > "${tmpdir}/extip.txt"
	else
		echo "Unable to get external IP address"
	fi
else
	extip="$(cat "${tmpdir}/extip.txt")"
fi

# Alert IP address
if [ "${displayip}" ]; then
	alertip="${displayip}"
elif [ "${extip}" ]; then
	alertip="${extip}"
else
	alertip="${ip}"
fi

# Steam Master Server - checks if detected by master server.
# Checked after config init, as the queryport is needed
if [ -z "${displaymasterserver}" ]; then
	if [ "$(command -v jq 2> /dev/null)" ]; then
		if [ -n "${ip}" ] && [ -n "${port}" ]; then
			if [ "${steammaster}" == "true" ] || [ "${commandname}" == "DEV-QUERY-RAW" ]; then
				# Will query server IP addresses first.
				for queryip in "${queryips[@]}"; do
					masterserver="$(curl --connect-timeout 10 -m 3 -s "https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=${queryip}&format=json" | jq --arg port "${port}" --arg queryport "${queryport}" 'if .response.servers != null then .response.servers[] | select((.gameport == ($port|tonumber) or .gameport == ($queryport|tonumber))) | .addr else empty end' | wc -l 2> /dev/null)"
				done
				# Should that not work it will try the external IP.
				if [ "${masterserver}" == "0" ]; then
					masterserver="$(curl --connect-timeout 10 -m 3 -s "https://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=${extip}&format=json" | jq --arg port "${port}" --arg queryport "${queryport}" 'if .response.servers != null then .response.servers[] | select((.gameport == ($port|tonumber) or .gameport == ($queryport|tonumber))) | .addr else empty end' | wc -l 2> /dev/null)"
				fi
				if [ "${masterserver}" == "0" ]; then
					displaymasterserver="false"
				else
					displaymasterserver="true"
				fi
			fi
		fi
	fi
fi
