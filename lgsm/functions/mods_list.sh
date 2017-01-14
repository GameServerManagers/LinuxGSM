#!/bin/bash
# LGSM mods_list.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Lists and defines available mods for LGSM supported servers.
# Usage: To add a mod, you just need to add an array variable into fn_mods_info following the guide to set proper values. 
# Usage: Then add this array to the mods_global_array.
# Usage: If needed, you can scrape to define the download URL inside the fn_mods_scrape_urls function.

local commandname="MODS"
local commandaction="List Mods"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh

## Useful variables
# Files and Directories
modstmpdir="${tmpdir}/mods"
modsdatadir="${lgsmdir}/data/mods"
modslockfile="installed-mods-listing"
modslockfilefullpath="${modsdatadir}/${modslockfile}"
# Separator name
modseparator="MOD"

# Define mods information (required)
fn_mods_info(){
	# REQUIRED: mod_info_name=( MOD "modcommand" "Pretty Name" "URL" "filename" "modsubfolders" "LowercaseOn/Off" "/files/to/keep;" "/install/path" "ENGINES" "GAMES" "NOTGAMES" "AUTHOR_URL" "Short Description" )
	# Example 1) Well made mod: mod_info_name=( MOD "awesomemod" "This is an Awesome Mod" "https://awesomemod.com/latest.zip" "awesomemod.zip" "0" "LowercaseOff" "OVERWRITE" "${systemdir}/addons" "source;unity3d;" "GAMES" "NOTGAMES" "https://awesomemod.com/" "This mod knows that 42 is the answer" )
	# Example 2) Poorly made mod: mod_info_name=( MOD "stupidmod" "This is a stupid mod" "${crappymodurl}" "StupidMod.zip" "2" "LowercaseOn" "cfg;data/crappymod;" "${systemdir}" "source;" "GAMES" "Garry's mod;Counter-Strike: Source;" "This mod is dumber than dumb" )
	# None of those values can be empty
	# [index]	| Usage
	# [0] 	| MOD: separator, all mods must begin with it
	# [1] 	| "modcommand": the LGSM name and command to install the mod (must be unique and lowercase)
	# [2] 	| "Pretty Name": the common name people use to call the mod that will be displayed to the user
	# [3] 	| "URL": link to the file; can be a variable defined in fn_mods_nasty_urls (make sure curl can download it)
	# [4] 	| "filename": the output filename
	# [5]	| "modsubfolders": in how many subfolders is the mod (none is 1)
	# [6]	| "LowercaseOn/Off": LowercaseOff or LowercaseOn: enable/disable converting extracted files and directories to lowercase (some games require it)
	# [7] 	| "modinstalldir": the directory in which to install the mode ( use LGSM dir variables such as ${systemdir})
	# [8]	| "/files/to/keep;", files & directories that should not be overwritten upon update, separated and ended with a semicolon; you can also use "OVERWRITE" to ignore the value or "NOUPDATE" to disallow updating
	# [9] 	| "Supported Engines;": list them according to LGSM ${engine} variables, separated and ended with a semicolon, or use ENGINES to ignore the value
	# [10] 	| "Supported Games;": list them according to LGSM ${gamename} variables, separated and ended with a semicolon, or use GAMES to ignore the value 
	# [11]	| "Unsupported Games;": list them according to LGSM ${gamename} variables, separated and ended with a semicolon, or use NOTGAMES to ignore the value (useful to exclude a game when using Supported Engines)
	# [12]	| "AUTHOR_URL" is the author's website, displayed to the user when chosing mods to install
	# [13]	| "Short Description" a description showed to the user upon installation

	# Source mods
	mod_info_metamod=( MOD "metamod" "MetaMod" "${metamodurl}" "${metamodlatestfile}" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "source;" "GAMES" "Garry's Mod;" "https://www.sourcemm.net" "Plugins Framework" )
	mod_info_sourcemod=( MOD "sourcemod" "SourceMod" "${sourcemodurl}" "${sourcemodlatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;" "source;" "GAMES" "Garry's Mod;" "http://www.sourcemod.net" "Admin Features (requires MetaMod)" )
	# Garry's Mod Addons
	mod_info_ulib=( MOD "ulib" "ULib" "https://codeload.github.com/TeamUlysses/ulib/zip/master" "ulib-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Complete Framework" )
	mod_info_ulx=( MOD "ulx" "ULX" "https://codeload.github.com/TeamUlysses/ulx/zip/master" "ulx-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Admin Panel (requires ULib)" )
	mod_info_utime=( MOD "utime" "UTime" "https://github.com/TeamUlysses/utime/archive/master.zip" "utime-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Keep track of players play time" )
	mod_info_uclip=( MOD "uclip" "UClib" "https://github.com/TeamUlysses/uclip/archive/master.zip" "uclip-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "An alternative to noclip" )
	mod_info_acf=( MOD "acf" "Armoured Combat Framework" "https://github.com/nrlulz/ACF/archive/master.zip" "acf-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/nrlulz/ACF" "Realistic Wepons & Engines" )
	mod_info_acf_missiles=( MOD "acfmissiles" "ACF Missiles" "https://github.com/Bubbus/ACF-Missiles/archive/master.zip" "acf-missiles-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/Bubbus/ACF-Missiles" "More missiles for ACF" )
	mod_info_acf_advdupe2=( MOD "advdupe2" "Advanced Duplicator 2" "https://github.com/wiremod/advdupe2/archive/master.zip" "advdupe2-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://www.wiremod.com" "Save your constructions" )
	mod_info_darkrp=( MOD "darkrp" "DarkRP" "https://github.com/FPtje/DarkRP/archive/master.zip" "darkrp-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://darkrp.com" "Most popular gamemode" )
	mod_info_darkrpmodification=( MOD "darkrpmodification" "DarkRP Modification" "https://github.com/FPtje/darkrpmodification/archive/master.zip" "darkrpmodification-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "NOUPDATE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://darkrp.com" "Customize DarkRP settings" )
	# Oxidemod
	mod_info_rustoxide=( MOD "rustoxide" "Oxide for Rust" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Rust.zip" "Oxide-Rust_Linux.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Rust;" "NOTGAMES" "http://oxidemod.org/downloads/oxide-for-rust.1659" "Allows for the use of plugins" )
	mod_info_hwoxide=( MOD "hwoxide" "Oxide for Hurtworld" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-Hurtworld.zip" "Oxide-Hurtworld_Linux.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Hurtworld;" "NOTGAMES" "http://oxidemod.org/downloads/oxide-for-hurtworld.1332" "Allows for the use of plugins" )
	mod_info_sdtdoxide=( MOD "sdtdoxide" "Oxide for 7 Days To Die" "https://raw.githubusercontent.com/OxideMod/Snapshots/master/Oxide-7DaysToDie.zip" "Oxide-7DaysToDie_Linux.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "7 Days To Die;" "NOTGAMES" "http://oxidemod.org/downloads/oxide-for-7-days-to-die.813" "Allows for the use of plugins" )

	# REQUIRED: Set all mods info into one array for convenience
	mods_global_array=( "${mod_info_metamod[@]}" "${mod_info_sourcemod[@]}" "${mod_info_ulib[@]}" "${mod_info_ulx[@]}" "${mod_info_utime[@]}" "${mod_info_uclip[@]}" "${mod_info_acf[@]}" "${mod_info_acf_missiles[@]}" "${mod_info_acf_sweps[@]}" "${mod_info_advdupe2[@]}" "${mod_info_darkrp[@]}" "${mod_info_darkrpmodification[@]}" "${mod_info_rustoxide[@]}" "${mod_info_hwoxide[@]}" "${mod_info_sdtdoxide[@]}" )
}

# Get a proper URL for mods that don't provide a good one (optional)
fn_mods_scrape_urls(){
	# Metamod
	metamodscrapeurl="http://www.gsptalk.com/mirror/sourcemod"
	metamodlatestfile="$(wget "${metamodscrapeurl}/?MD" -q -O -| grep "mmsource" | grep "\-linux" | head -n1 | awk -F '>' '{ print $3 }' | awk -F '<' '{ print $1}')"
	metamodfasterurl="http://cdn.probablyaserver.com/sourcemod/"
	metamodurl="${metamodfasterurl}/${metamodlatestfile}"
	# Sourcemod
	sourcemodmversion="1.8"
	sourcemodscrapeurl="http://www.gsptalk.com/mirror/sourcemod"
	sourcemodlatestfile="$(wget "${sourcemodscrapeurl}/?MD" -q -O -| grep "sourcemod-" | grep "\-linux" | head -n1 | awk -F '>' '{ print $3 }' | awk -F '<' '{ print $1}')"
	sourcemodfasterurl="http://cdn.probablyaserver.com/sourcemod/"
	sourcemodurl="${sourcemodfasterurl}/${sourcemodlatestfile}"
}

# Sets some gsm requirements
fn_gsm_requirements(){
	# If tmpdir variable doesn't exist, LGSM is too old
	if [ -z "${tmpdir}" ]||[ -z "${lgsmdir}" ]; then
		fn_print_fail "Your LGSM version is too old."
		echo " * Please do a full update, including ${selfname} script."
		core_exit.sh
	fi
}

# Define all variables from a mod at once when index is set to a separator
fn_mod_info(){
# If for some reason no index is set, none of this can work
if [ -z "$index" ]; then
	fn_print_error "index variable not set. Please report an issue to LGSM Team."
	echo "* https://github.com/GameServerManagers/LinuxGSM/issues"
	core_exit.sh
fi
	modcommand="${mods_global_array[index+1]}"
	modprettyname="${mods_global_array[index+2]}"
	modurl="${mods_global_array[index+3]}"
	modfilename="${mods_global_array[index+4]}"
	modsubfolders="${mods_global_array[index+5]}"
	modlowercase="${mods_global_array[index+6]}"
	modinstalldir="${mods_global_array[index+7]}"
	modkeepfiles="${mods_global_array[index+8]}"
	modengines="${mods_global_array[index+9]}"
	modgames="${mods_global_array[index+10]}"
	modexcludegames="${mods_global_array[index+11]}"
	modsite="${mods_global_array[index+12]}"
	moddescription="${mods_global_array[index+13]}"
}


# Find out if a game is compatible with a mod from a modgames (list of games supported by a mod) variable
fn_compatible_mod_games(){
	# Reset test value
	modcompatiblegame="0"
	# If value is set to GAMES (ignore)
	if [ "${modgames}" != "GAMES" ]; then
		# How many games we need to test
		gamesamount="$(echo "${modgames}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modgames" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${gamesamount}; gamevarindex++)); do
			# Put current game name into modtest variable
			gamemodtest="$( echo "${modgames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If game name matches
			if [ "${gamemodtest}" == "${gamename}" ]; then
				# Mod is compatible !
				modcompatiblegame="1"
			fi
		done
	fi
}

# Find out if an engine is compatible with a mod from a modengines (list of engines supported by a mod) variable
fn_compatible_mod_engines(){
	# Reset test value
	modcompatibleengine="0"
	# If value is set to ENGINES (ignore)
	if [ "${modengines}" != "ENGINES" ]; then
		# How many engines we need to test
		enginesamount="$(echo "${modengines}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modengines" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${enginesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable
			enginemodtest="$( echo "${modengines}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches
			if [ "${enginemodtest}" == "${engine}" ]; then
				# Mod is compatible !
				modcompatibleengine="1"
			fi
		done
	fi
}

# Find out if a game is not compatible with a mod from a modnotgames (list of games not supported by a mod) variable
fn_not_compatible_mod_games(){
	# Reset test value
	modeincompatiblegame="0"
	# If value is set to NOTGAMES (ignore)
	if [ "${modexcludegames}" != "NOTGAMES" ]; then
		# How many engines we need to test
		excludegamesamount="$(echo "${modexcludegames}" | awk -F ';' '{ print NF }')"
		# Test all subvalue of "modexcludegames" using the ";" separator
		for ((gamevarindex=1; gamevarindex < ${excludegamesamount}; gamevarindex++)); do
			# Put current engine name into modtest variable
			excludegamemodtest="$( echo "${modexcludegames}" | awk -F ';' -v x=${gamevarindex} '{ print $x }' )"
			# If engine name matches
			if [ "${excludegamemodtest}" == "${gamename}" ]; then
				# Mod is compatible !
				modeincompatiblegame="1"
			fi
		done
	fi
}

# Sums up if a mod is compatible or not with modcompatibility=0/1
fn_mod_compatible_test(){
	# Test game and engine compatibility
	fn_compatible_mod_games
	fn_compatible_mod_engines
	fn_not_compatible_mod_games
	if [ "${modeincompatiblegame}" == "1" ]; then
		modcompatibility="0"
	elif [ "${modcompatibleengine}" == "1" ]||[ "${modcompatiblegame}" == "1" ]; then
		modcompatibility="1"
	else
		modcompatibility="0"
	fi
}

# Checks if a mod is compatibile for installation
# Provides available mods for installation
# Provides commands for mods installation
fn_mods_available(){
	# First, reset variables
	compatiblemodslist=()
	availablemodscommands=()
	modprettynamemaxlength="0"
	modsitemaxlength="0"
	moddescriptionmaxlength="0"
	modcommandmaxlength="0"
	# Find compatible games
	# Find separators through the global array
	for ((index="0"; index <= ${#mods_global_array[@]}; index++)); do
		# If current value is a separator; then
		if [ "${mods_global_array[index]}" == "${modseparator}" ]; then
			# Set mod variables
			fn_mod_info
			# Test if game is compatible
			fn_mod_compatible_test
			# If game is compatible
			if [ "${modcompatibility}" == "1" ]; then
				# Put it into the list to display to the user
				compatiblemodslist+=( "${modprettyname}" "${modcommand}" "${modsite}" "${moddescription}" )
				# Keep available commands in an array
				availablemodscommands+=( "${modcommand}" )
			fi
		fi
	done
}

# Output available mods in a nice way to the user
fn_mods_show_available(){
	# Set and reset vars
	compatiblemodslistindex=0
	spaces=" "
	# As long as we're within index values
	while [ "${compatiblemodslistindex}" -lt "${#compatiblemodslist[@]}" ]; do
		# Set values for convenience
		displayedmodname="${compatiblemodslist[compatiblemodslistindex]}"
		displayedmodcommand="${compatiblemodslist[compatiblemodslistindex+1]}"
		displayedmodsite="${compatiblemodslist[compatiblemodslistindex+2]}"
		displayedmoddescription="${compatiblemodslist[compatiblemodslistindex+3]}"
		# Output mods to the user
		echo -e "\e[36m${displayedmodcommand}\e[0m - \e[1m${displayedmodname}\e[0m"
		echo -e " * ${displayedmoddescription} - ${displayedmodsite}"
		# Increment index from the amount of values we just displayed
		let "compatiblemodslistindex+=4"
	done
	# If no mods are found
	if [ -z "${compatiblemodslist}" ]; then
		fn_print_fail "No mods are currently available for ${gamename}."
		core_exit.sh
	fi
}

# Get details of a mod any (relevant and unique, such as full mod name or install command) value
fn_mod_get_info_from_command(){
	# Variable to know when job is done
	modinfocommand="0"
	# Find entry in global array
	for ((index=0; index <= ${#mods_global_array[@]}; index++)); do
		# When entry is found
		if [ "${mods_global_array[index]}" == "${currentmod}" ]; then
			# Go back to the previous "MOD" separator
			for ((index=index; index <= ${#mods_global_array[@]}; index--)); do
				# When "MOD" is found
				if [ "${mods_global_array[index]}" == "MOD" ]; then
					# Get info
					fn_mod_info
					modinfocommand="1"
					break
				fi
			done
		fi
		# Exit the loop if job is done
		if [ "${modinfocommand}" == "1" ]; then
			break
		fi
	done
}

fn_gsm_requirements
fn_mods_scrape_urls
fn_mods_info
fn_mods_available
