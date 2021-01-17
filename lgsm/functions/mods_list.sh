#!/bin/bash
# LinuxGSM mods_list.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Lists and defines available mods for LinuxGSM supported servers; works along with mods_core.sh.
# Usage: To add a mod, you need to add an array variable following the guide to set proper values;
# Usage: Then add this array to the mods_global_array.
# Usage: If needed, you can scrape the download URL first.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Get a proper URL for mods that don't provide a good one (optional)
fn_script_log_info "Retrieving latest mods URLs"

# Metamod (Half-life 1 Classic Engine)
metamodversion="1.21.1-am"
metamodlatestfile="metamod-${metamodversion}.zip"
metamoddownloadurl="https://www.amxmodx.org/release/${metamodlatestfile}"
metamodurl="${metamoddownloadurl}"
# AMX Mod X: Base
amxxbaseversion="1.8.2"
amxxbasemod="base"
amxxbaselatestfile="amxmodx-${amxxbaseversion}-${amxxbasemod}-linux.tar.gz"
amxxbasedownloadurl="https://www.amxmodx.org/release/${amxxbaselatestfile}"
amxxbaseurl="${amxxbasedownloadurl}"
# AMX Mod X: Counter-Strike
amxxcsversion="1.8.2"
amxxcsmod="cstrike"
amxxcslatestfile="amxmodx-${amxxbaseversion}-${amxxcsmod}-linux.tar.gz"
amxxcsdownloadurl="https://www.amxmodx.org/release/${amxxcslatestfile}"
amxxcsurl="${amxxcsdownloadurl}"
# AMX Mod X: Day of Defeat
amxxdodversion="1.8.2"
amxxdodmod="dod"
amxxdodlatestfile="amxmodx-${amxxdodversion}-${amxxdodmod}-linux.tar.gz"
amxxdoddownloadurl="https://www.amxmodx.org/release/${amxxdodlatestfile}"
amxxdodurl="${amxxdoddownloadurl}"
# AMX Mod X: Team Fortress Classic
amxxtfcversion="1.8.2"
amxxtfcmod="tfc"
amxxtfclatestfile="amxmodx-${amxxtfcversion}-${amxxtfcmod}-linux.tar.gz"
amxxtfcdownloadurl="https://www.amxmodx.org/release/${amxxtfclatestfile}"
amxxtfcurl="${amxxtfcdownloadurl}"
# AMX Mod X: Natural Selection
amxxnsversion="1.8.2"
amxxnsmod="ns"
amxxnslatestfile="amxmodx-${amxxnsversion}-${amxxnsmod}-linux.tar.gz"
amxxnsdownloadurl="https://www.amxmodx.org/release/${amxxnslatestfile}"
amxxnsurl="${amxxnsdownloadurl}"
# AMX Mod X: The Specialists
amxxtsversion="1.8.2"
amxxtsmod="ts"
amxxtslatestfile="amxmodx-${amxxtsversion}-${amxxtsmod}-linux.tar.gz"
amxxtsdownloadurl="https://www.amxmodx.org/release/${amxxtslatestfile}"
amxxtsurl="${amxxtsdownloadurl}"
# Metamod:Source
metamodsourceversion="1.10"
metamodsourcescrapeurl="https://mms.alliedmods.net/mmsdrop/${metamodsourceversion}/mmsource-latest-linux"
metamodsourcelatestfile=$(wget "${metamodsourcescrapeurl}" -q -O -)
metamodsourcedownloadurl="https://www.metamodsource.net/latest.php?os=linux&version=${metamodsourceversion}"
metamodsourceurl="${metamodsourcedownloadurl}"
# Sourcemod
sourcemodversion="1.10"
sourcemodscrapeurl="https://sm.alliedmods.net/smdrop/${sourcemodversion}/sourcemod-latest-linux"
sourcemodlatestfile=$(wget "${sourcemodscrapeurl}" -q -O -)
sourcemoddownloadurl="https://www.sourcemod.net/latest.php?os=linux&version=${sourcemodversion}"
sourcemodurl="${sourcemoddownloadurl}"
# Steamworks
steamworksscrapeurl="https://users.alliedmods.net/~kyles/builds/SteamWorks"
steamworkslatestfile=$(curl --connect-timeout 10 -sL ${steamworksscrapeurl} | grep -m 1 linux | cut -d '"' -f 4)
steamworksdownloadurl="${steamworksscrapeurl}/${steamworkslatestfile}"
steamworksurl="${steamworksdownloadurl}"
# CS:GO Mods
get5lastbuild=$(curl --connect-timeout 10 -sL https://ci.splewis.net/job/get5/lastSuccessfulBuild/api/json | jq -r '.artifacts[]')
get5latestfile=$(echo -e "${get5lastbuild}" | jq -r '.fileName')
get5latestfilepath=$(echo -e "${get5lastbuild}" | jq -r '.relativePath')
get5url="https://ci.splewis.net/job/get5/lastSuccessfulBuild/artifact/${get5latestfilepath}"
csgopuglatest=$(curl --connect-timeout 10 -sL https://api.github.com/repos/splewis/csgo-pug-setup/releases/latest | jq '.assets[]')
csgopuglatestfile=$(echo -e "${csgopuglatest}" | jq -r '.name')
csgopuglatestlink=$(echo -e "${csgopuglatest}" | jq -r '.browser_download_url')
# Oxide
oxiderustlatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/OxideMod/Oxide.Rust/releases/latest | jq -r '.assets[]|select(.browser_download_url | contains("linux")) | .browser_download_url')
oxidehurtworldlatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/OxideMod/Oxide.Hurtworld/releases/latest | jq -r '.assets[].browser_download_url')
oxidesdtdlatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/OxideMod/Oxide.SevenDaysToDie/releases/latest | jq -r '.assets[]|select(.browser_download_url | contains("linux")) | .browser_download_url' )

# Define mods information (required)

# Separator name
modseparator="MOD"

# REQUIRED: mod_info_name=( MOD "modcommand" "Pretty Name" "URL" "filename" "modsubdirs" "LowercaseOn/Off" "/files/to/keep;" "/install/path" "ENGINES" "GAMES" "NOTGAMES" "AUTHOR_URL" "Short Description" )
# Example 1) Well made mod: mod_info_name=( MOD "awesomemod" "This is an Awesome Mod" "https://awesomemod.com/latest.zip" "awesomemod.zip" "0" "LowercaseOff" "OVERWRITE" "${systemdir}/addons" "source;unity3d;" "GAMES" "NOTGAMES" "https://awesomemod.com/" "This mod knows that 42 is the answer" )
# Example 2) Poorly made mod: mod_info_name=( MOD "stupidmod" "This is a stupid mod" "${crappymodurl}" "StupidMod.zip" "2" "LowercaseOn" "cfg;data/crappymod;" "${systemdir}" "source;" "GAMES" "Garry's mod;Counter-Strike: Source;" "This mod is dumber than dumb" )
# None of those values can be empty
# index | Usage
# [0] 	| MOD: separator, all mods must begin with it
# [1] 	| "modcommand": the LGSM name and command to install the mod (must be unique and lowercase)
# [2] 	| "Pretty Name": the common name people use to call the mod that will be displayed to the user
# [3] 	| "URL": link to the mod archive file; can be a variable previously defined while scraping a URL
# [4] 	| "filename": the output filename
# [5]	| "modsubdirs": in how many subdirectories is the mod (none is 0) (not used at release, but could be in the future)
# [6]	| "LowercaseOn/Off": LowercaseOff or LowercaseOn: enable/disable converting extracted files and directories to lowercase (some games require it)
# [7] 	| "modinstalldir": the directory in which to install the mode (use LGSM dir variables such as ${systemdir})
# [8]	| "/files/to/keep;", files & directories that should not be overwritten upon update, separated and ended with a semicolon; you can also use "OVERWRITE" value to ignore the value or "NOUPDATE" to disallow updating; for files to keep upon uninstall, see fn_mod_tidy_files_list from mods_core.sh
# [9] 	| "Supported Engines;": list them according to LGSM ${engine} variables, separated and ended with a semicolon, or use ENGINES to ignore the value
# [10] 	| "Supported Games;": list them according to LGSM ${gamename} variables, separated and ended with a semicolon, or use GAMES to ignore the value
# [11]	| "Unsupported Games;": list them according to LGSM ${gamename} variables, separated and ended with a semicolon, or use NOTGAMES to ignore the value (useful to exclude a game when using Supported Engines)
# [12]	| "AUTHOR_URL" is the author's website, displayed to the user when chosing mods to install
# [13]	| "Short Description" a description showed to the user upon installation/removal

# Half-life 1 Engine Mods
mod_info_metamod=( MOD "metamod" "Metamod" "${metamodurl}" "${metamodlatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/metamod/plugins.ini;" "ENGINES" "Counter-Strike 1.6;Day of Defeat;Team Fortress Classic;Natural Selection;The Specialists;Half-Life: Deathmatch;" "NOTGAMES" "https://github.com/alliedmodders/metamod-hl1" "Plugins Framework" )
mod_info_base_amxx=( MOD "amxmodx" "AMX Mod X: Base" "${amxxbaseurl}" "${amxxbaselatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Counter-Strike 1.6;Day of Defeat;Team Fortress Classic;Natural Selection;The Specialists;Half-Life: Deathmatch;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod)" )

# CS 1.6 (HL1) Engine Mods
mod_info_cs_amxx=( MOD "amxmodxcs" "AMX Mod X: Counter-Strike" "${amxxcsurl}" "${amxxcslatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Counter-Strike 1.6;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)" )

# DOD (HL1) Engine Mods
mod_info_dod_amxx=( MOD "amxmodxdod" "AMX Mod X: Day of Defeat" "${amxxdodurl}" "${amxxdodlatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Day of Defeat;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)" )

# TFC (HL1) Engine Mods
mod_info_tfc_amxx=( MOD "amxmodxtfc" "AMX Mod X: Team Fortress Classic" "${amxxtfcurl}" "${amxxtfclatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Team Fortress Classic;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)" )

# NS (Natural Selection) (HL1) Engine Mods
mod_info_ns_amxx=( MOD "amxmodxns" "AMX Mod X: Natural Selection" "${amxxnsurl}" "${amxxnslatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Natural Selection;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)" )

# TS (The Specialists) (HL1) Engine Mods
mod_info_ts_amxx=( MOD "amxmodxts" "AMX Mod X: The Specialists" "${amxxtsurl}" "${amxxtslatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "The Specialists;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)" )

# Source mods
mod_info_metamodsource=( MOD "metamodsource" "Metamod: Source" "${metamodsourceurl}" "${metamodsourcelatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/metamod/metaplugins.ini;" "source;" "GAMES" "NOTGAMES" "https://www.sourcemm.net" "Plugins Framework" )
mod_info_sourcemod=( MOD "sourcemod" "SourceMod" "${sourcemodurl}" "${sourcemodlatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "source;" "GAMES" "NOTGAMES" "http://www.sourcemod.net" "Admin Features (requires Metamod: Source)" )
mod_info_steamworks=( MOD "steamworks" "SteamWorks" "${steamworksurl}" "${steamworkslatestfile}" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/KyleSanderson/SteamWorks" "Exposing SteamWorks functions to SourcePawn" )
mod_info_stripper=( MOD "stripper" "Stripper Source" "http://www.bailopan.net/stripper/snapshots/1.2/stripper-1.2.2-git129-linux.tar.gz" "stripper-1.2.2-git129-linux.tar.gz" "0" "LowercaseOff" "${systemdir}" "addons/stripper/maps;" "ENGINES" "Counter-Strike: Global Offensive;Counter-Strike: Source;Day of Defeat: Source;Half Life: Deathmatch;Half Life 2: Deathmatch;Insurgency;Left 4 Dead;Left 4 Dead 2;Nuclear Dawn;Team Fortress 2;" "NOTGAMES" "http://www.bailopan.net/stripper/" "Add or remove objects from map (requires MetaMod)")

# CS:GO Mods
mod_info_gokz=( MOD "gokz" "GOKZ" "https://bitbucket.org/kztimerglobalteam/gokz/downloads/GOKZ-latest.zip" "gokz-latest.zip" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://bitbucket.org/kztimerglobalteam/gokz/src/master/" "Implements the KZ game mode (requires SourceMod and MetaMod)" )
mod_info_ttt=( MOD "ttt" "Trouble in Terrorist Town" "https://csgottt.com/downloads/ttt-latest-dev-${sourcemodversion}.zip" "ttt-latest.zip" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/Bara/TroubleinTerroristTown" "Implements the TTT game mode (requires SourceMod and MetaMod)" )
mod_info_get5=( MOD "get5" "Get 5" "${get5url}" "${get5latestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/splewis/get5" "Plugin for competitive matches/scrims (requires SourceMod and MetaMod)" )
mod_info_pug=( MOD "pug" "PUG" "${csgopuglatestlink}" "${csgopuglatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/splewis/csgo-pug-setup" "plugin for setting up private pug/10man games" )

# Garry's Mod Addons
mod_info_ulib=( MOD "ulib" "ULib" "https://codeload.github.com/TeamUlysses/ulib/zip/master" "ulib-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Complete Framework" )
mod_info_ulx=( MOD "ulx" "ULX" "https://codeload.github.com/TeamUlysses/ulx/zip/master" "ulx-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Admin Panel (requires ULib)" )
mod_info_utime=( MOD "utime" "UTime" "https://github.com/TeamUlysses/utime/archive/master.zip" "utime-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Keep track of players play time" )
mod_info_uclip=( MOD "uclip" "UClip" "https://github.com/TeamUlysses/uclip/archive/master.zip" "uclip-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "An alternative to noclip" )
mod_info_acf=( MOD "acf" "Armoured Combat Framework" "https://github.com/nrlulz/ACF/archive/master.zip" "acf-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "acf-master/lua/acf/shared/guns;" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/nrlulz/ACF" "Realistic Wepons & Engines" )
mod_info_acf_missiles=( MOD "acfmissiles" "ACF Missiles" "https://github.com/Bubbus/ACF-Missiles/archive/master.zip" "acf-missiles-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/Bubbus/ACF-Missiles" "More missiles for ACF" )
mod_info_advdupe2=( MOD "advdupe2" "Advanced Duplicator 2" "https://github.com/wiremod/advdupe2/archive/master.zip" "advdupe2-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://www.wiremod.com" "Save your constructions" )
mod_info_pac3=( MOD "pac3" "PAC3" "https://github.com/CapsAdmin/pac3/archive/master.zip" "pac3-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/CapsAdmin/pac3" "Advanced player model customization" )
mod_info_wiremod=( MOD "wiremod" "Wiremod" "https://github.com/wiremod/wire/archive/master.zip" "wire-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/wiremod/wire" "Base Wiremod Addon")
mod_info_wiremodextras=( MOD "wiremod-extras" "Wiremod Extras" "https://github.com/wiremod/wire-extras/archive/master.zip" "wire-extras-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/wiremod/wire-extras/" "Addition to Wiremod, Extra Content")
mod_info_darkrp=( MOD "darkrp" "DarkRP" "https://github.com/FPtje/DarkRP/archive/master.zip" "darkrp-master.zip" "0" "LowercaseOn" "${systemdir}/gamemodes" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://darkrp.com" "Most popular gamemode" )
mod_info_darkrpmodification=( MOD "darkrpmodification" "DarkRP Modification" "https://github.com/FPtje/darkrpmodification/archive/master.zip" "darkrpmodification-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "NOUPDATE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://darkrp.com" "Customize DarkRP settings" )

# Oxidemod
mod_info_rustoxide=( MOD "rustoxide" "Oxide for Rust" "${oxiderustlatestlink}" "Oxide.Rust-linux.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Rust;" "NOTGAMES" "https://umod.org/games/rust" "Allows for the use of plugins" )
mod_info_hwoxide=( MOD "hwoxide" "Oxide for Hurtworld" "${oxidehurtworldlatestlink}" "Oxide.Hurtworld.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Hurtworld;" "NOTGAMES" "https://umod.org/games/hurtworld" "Allows for the use of plugins" )
mod_info_sdtdoxide=( MOD "sdtdoxide" "Oxide for 7 Days To Die" "${oxidesdtdlatestlink}" "Oxide.SevenDaysToDie.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "7 Days To Die;" "NOTGAMES" "https://umod.org/games/7-days-to-die" "Allows for the use of plugins" )

# REQUIRED: Set all mods info into the global array
mods_global_array=( "${mod_info_metamod[@]}" "${mod_info_base_amxx[@]}" "${mod_info_cs_amxx[@]}" "${mod_info_dod_amxx[@]}" "${mod_info_tfc_amxx[@]}" "${mod_info_ns_amxx[@]}" "${mod_info_ts_amxx[@]}" "${mod_info_metamodsource[@]}" "${mod_info_sourcemod[@]}" "${mod_info_steamworks[@]}" "${mod_info_gokz[@]}" "${mod_info_ttt[@]}" "${mod_info_get5[@]}" "${mod_info_pug[@]}" "${mod_info_ulib[@]}" "${mod_info_ulx[@]}" "${mod_info_utime[@]}" "${mod_info_uclip[@]}" "${mod_info_acf[@]}" "${mod_info_acf_missiles[@]}" "${mod_info_acf_sweps[@]}" "${mod_info_advdupe2[@]}" "${mod_info_pac3[@]}" "${mod_info_wiremod[@]}" "${mod_info_wiremodextras[@]}" "${mod_info_darkrp[@]}" "${mod_info_darkrpmodification[@]}" "${mod_info_rustoxide[@]}" "${mod_info_hwoxide[@]}" "${mod_info_sdtdoxide[@]}" )
