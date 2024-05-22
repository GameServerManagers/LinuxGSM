#!/bin/bash
# LinuxGSM mods_list.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Lists and defines available mods for LinuxGSM supported servers; works along with mods_core.sh.
# Usage: To add a mod, you need to add an array variable following the guide to set proper values;
# Usage: Then add this array to the mods_global_array.
# Usage: If needed, you can scrape the download URL first.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

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
metamodsourceversion="1.11"
metamodsourcescrapeurl="https://mms.alliedmods.net/mmsdrop/${metamodsourceversion}/mmsource-latest-linux"
metamodsourcelatestfile=$(wget "${metamodsourcescrapeurl}" -q -O -)
metamodsourcedownloadurl="https://www.metamodsource.net/latest.php?os=linux&version=${metamodsourceversion}"
metamodsourceurl="${metamodsourcedownloadurl}"
# Sourcemod
sourcemodversion="1.11"
sourcemodscrapeurl="https://sm.alliedmods.net/smdrop/${sourcemodversion}/sourcemod-latest-linux"
sourcemodlatestfile=$(wget "${sourcemodscrapeurl}" -q -O -)
sourcemoddownloadurl="https://www.sourcemod.net/latest.php?os=linux&version=${sourcemodversion}"
sourcemodurl="${sourcemoddownloadurl}"
# Steamworks
steamworksscrapeurl="https://users.alliedmods.net/~kyles/builds/SteamWorks"
steamworkslatestfile=$(curl --connect-timeout 10 -sL ${steamworksscrapeurl} | grep -m 1 linux | cut -d '"' -f 4)
steamworksdownloadurl="${steamworksscrapeurl}/${steamworkslatestfile}"
steamworksurl="${steamworksdownloadurl}"
# Stripper:Source
stripperversion="1.2.2-git141"
stripperlatestfile="stripper-${stripperversion}-linux.tar.gz"
stripperdownloadurl="http://www.bailopan.net/stripper/snapshots/1.2/${stripperlatestfile}"
stripperurl="${stripperdownloadurl}"

# CS:GO Mods
get5lastbuild=$(curl --connect-timeout 10 -sL https://api.github.com/repos/splewis/get5/releases/latest | jq '.assets[] |select(.browser_download_url | endswith(".tar.gz"))')
get5latestfile=$(echo -e "${get5lastbuild}" | jq -r '.name')
get5latestfilelink=$(echo -e "${get5lastbuild}" | jq -r '.browser_download_url')
csgopracticelatest=$(curl --connect-timeout 10 -sL https://api.github.com/repos/splewis/csgo-practice-mode/releases/latest | jq '.assets[]')
csgopracticelatestfile=$(echo -e "${csgopracticelatest}" | jq -r '.name')
csgopracticelatestlink=$(echo -e "${csgopracticelatest}" | jq -r '.browser_download_url')
csgopuglatest=$(curl --connect-timeout 10 -sL https://api.github.com/repos/splewis/csgo-pug-setup/releases/latest | jq '.assets[]')
csgopuglatestfile=$(echo -e "${csgopuglatest}" | jq -r '.name')
csgopuglatestlink=$(echo -e "${csgopuglatest}" | jq -r '.browser_download_url')
gokzlatestversion=$(curl --connect-timeout 10 -s https://api.github.com/repos/KZGlobalTeam/gokz/releases/latest | grep "tag_name" | cut -d : -f 2,3 | sed -E 's/.*"([^"]+)".*/\1/')
gokzlatestfile="GOKZ-v${gokzlatestversion}.zip"
gokzlatestlink="https://github.com/KZGlobalTeam/gokz/releases/download/${gokzlatestversion}/${gokzlatestfile}"
movementapilatestversion=$(curl --connect-timeout 10 -s https://api.github.com/repos/danzayau/MovementAPI/releases/latest | grep "tag_name" | cut -d : -f 2,3 | sed -E 's/.*"([^"]+)".*/\1/')
movementapilatestfile="MovementAPI-v${movementapilatestversion}.zip"
movementapilatestlink="https://github.com/danzayau/MovementAPI/releases/download/${movementapilatestversion}/${movementapilatestfile}"

# Rust
carbonrustapilatestfile="Carbon.Linux.Release.tar.gz"
carbonrustlatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/CarbonCommunity/Carbon.Core/releases/tags/production_build | jq -r '.assets[]|select(.name == "Carbon.Linux.Release.tar.gz") | .browser_download_url')

# Oxide
oxiderustlatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/OxideMod/Oxide.Rust/releases/latest | jq -r '.assets[]|select(.browser_download_url | contains("linux")) | .browser_download_url')
oxidehurtworldlatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/OxideMod/Oxide.Hurtworld/releases/latest | jq -r '.assets[].browser_download_url')
oxidesdtdlatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/OxideMod/Oxide.SevenDaysToDie/releases/latest | jq -r '.assets[]|select(.browser_download_url | contains("linux")) | .browser_download_url')
# Valheim Plus
valheimpluslatestlink=$(curl --connect-timeout 10 -sL https://api.github.com/repos/Grantapher/ValheimPlus/releases/latest | jq -r '.assets[]|select(.browser_download_url | contains("UnixServer.tar.gz")) | .browser_download_url')
# Valheim BepInEx
bepinexvhlatestlink=$(curl --connect-timeout 10 -sL "https://thunderstore.io/api/experimental/package/denikson/BepInExPack_Valheim/" -H "accept: application/json" | jq -r '.latest.download_url')

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
mod_info_metamod=(MOD "metamod" "Metamod" "${metamodurl}" "${metamodlatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/metamod/plugins.ini;" "ENGINES" "Counter-Strike 1.6;Day of Defeat;Team Fortress Classic;Natural Selection;The Specialists;Half-Life: Deathmatch;" "NOTGAMES" "https://github.com/alliedmodders/metamod-hl1" "Plugins Framework")
mod_info_base_amxx=(MOD "amxmodx" "AMX Mod X: Base" "${amxxbaseurl}" "${amxxbaselatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Counter-Strike 1.6;Day of Defeat;Team Fortress Classic;Natural Selection;The Specialists;Half-Life: Deathmatch;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod)")

# CS 1.6 (HL1) Engine Mods
mod_info_cs_amxx=(MOD "amxmodxcs" "AMX Mod X: Counter-Strike" "${amxxcsurl}" "${amxxcslatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Counter-Strike 1.6;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)")

# DOD (HL1) Engine Mods
mod_info_dod_amxx=(MOD "amxmodxdod" "AMX Mod X: Day of Defeat" "${amxxdodurl}" "${amxxdodlatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Day of Defeat;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)")

# TFC (HL1) Engine Mods
mod_info_tfc_amxx=(MOD "amxmodxtfc" "AMX Mod X: Team Fortress Classic" "${amxxtfcurl}" "${amxxtfclatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Team Fortress Classic;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)")

# NS (Natural Selection) (HL1) Engine Mods
mod_info_ns_amxx=(MOD "amxmodxns" "AMX Mod X: Natural Selection" "${amxxnsurl}" "${amxxnslatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "Natural Selection;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)")

# TS (The Specialists) (HL1) Engine Mods
mod_info_ts_amxx=(MOD "amxmodxts" "AMX Mod X: The Specialists" "${amxxtsurl}" "${amxxtslatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/amxmodx/configs;" "ENGINES" "The Specialists;" "NOTGAMES" "https://www.amxmodx.org" "Admin Features (requires Metamod & AMX Mod X: Base)")

# Source mods
mod_info_metamodsource=(MOD "metamodsource" "Metamod: Source" "${metamodsourceurl}" "${metamodsourcelatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/metamod/metaplugins.ini;" "source;" "GAMES" "NOTGAMES" "https://www.sourcemm.net" "Plugins Framework")
mod_info_sourcemod=(MOD "sourcemod" "SourceMod" "${sourcemodurl}" "${sourcemodlatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "source;" "GAMES" "NOTGAMES" "http://www.sourcemod.net" "Admin Features (requires Metamod: Source)")
mod_info_steamworks=(MOD "steamworks" "SteamWorks" "${steamworksurl}" "${steamworkslatestfile}" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/KyleSanderson/SteamWorks" "Exposing SteamWorks functions to SourcePawn")
mod_info_stripper=(MOD "stripper" "Stripper Source" "${stripperurl}" "${stripperlatestfile}" "0" "LowercaseOff" "${systemdir}" "addons/stripper/maps;" "ENGINES" "Counter-Strike: Global Offensive;Counter-Strike: Source;Day of Defeat: Source;Half Life: Deathmatch;Half Life 2: Deathmatch;Insurgency;Left 4 Dead;Left 4 Dead 2;Nuclear Dawn;Team Fortress 2;" "NOTGAMES" "http://www.bailopan.net/stripper/" "Add or remove objects from map (requires MetaMod)")

# CS:GO Mods
mod_info_gokz=(MOD "gokz" "GOKZ" "${gokzlatestlink}" "${gokzlatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/KZGlobalTeam/gokz" "GOKZ ${gokzlatestversion} - Implements the KZ game mode (requires SourceMod and MetaMod)")
mod_info_ttt=(MOD "ttt" "Trouble in Terrorist Town" "https://csgottt.com/downloads/ttt-latest-dev-${sourcemodversion}.zip" "ttt-latest.zip" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/Bara/TroubleinTerroristTown" "Implements the TTT game mode (requires SourceMod and MetaMod)")
mod_info_get5=(MOD "get5" "Get 5" "${get5latestfilelink}" "${get5latestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/splewis/get5" "Plugin for competitive matches/scrims (requires SourceMod and MetaMod)")
mod_info_prac=(MOD "prac" "csgo practice mode" "${csgopracticelatestlink}" "${csgopracticelatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/splewis/csgo-practice-mode" "Practice Mode is a sourcemod plugin for helping players/teams run practices.")
mod_info_pug=(MOD "pug" "PUG" "${csgopuglatestlink}" "${csgopuglatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/splewis/csgo-pug-setup" "plugin for setting up private pug/10man games")
mod_info_dhook=(MOD "dhook" "dhook" "https://forums.alliedmods.net/attachment.php?attachmentid=190123&d=1625050030" "dhooks-2.2.0d17.zip" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://forums.alliedmods.net/showpost.php?p=2588686&postcount=589" "DHooks 2.2.0 - Required for GOKZ")
mod_info_movement=(MOD "movementapi" "movementapi" "${movementapilatestlink}" "${movementapilatestfile}" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/danzayau/MovementAPI" "Movement API ${movementapilatestversion} - Required for GOKZ")
mod_info_cleaner=(MOD "cleaner" "cleaner" "https://github.com/e54385991/console-cleaner/archive/refs/heads/master.zip" "console-cleaner.zip" "0" "LowercaseOff" "${systemdir}" "cfg;addons/sourcemod/configs;" "ENGINES" "Counter-Strike: Global Offensive;" "NOTGAMES" "https://github.com/e54385991/console-cleaner" "Console Cleaner - Optional for GOKZ")

# Garry's Mod Addons
mod_info_ulib=(MOD "ulib" "ULib" "https://codeload.github.com/TeamUlysses/ulib/zip/master" "ulib-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Complete Framework")
mod_info_ulx=(MOD "ulx" "ULX" "https://codeload.github.com/TeamUlysses/ulx/zip/master" "ulx-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Admin Panel (requires ULib)")
mod_info_utime=(MOD "utime" "UTime" "https://github.com/TeamUlysses/utime/archive/master.zip" "utime-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "Keep track of players play time")
mod_info_uclip=(MOD "uclip" "UClip" "https://github.com/TeamUlysses/uclip/archive/master.zip" "uclip-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://ulyssesmod.net" "An alternative to noclip")
mod_info_acf=(MOD "acf" "Armoured Combat Framework" "https://github.com/nrlulz/ACF/archive/master.zip" "acf-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "acf-master/lua/acf/shared/guns;" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/nrlulz/ACF" "Realistic Wepons & Engines")
mod_info_acf_missiles=(MOD "acfmissiles" "ACF Missiles" "https://github.com/Bubbus/ACF-Missiles/archive/master.zip" "acf-missiles-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/Bubbus/ACF-Missiles" "More missiles for ACF")
mod_info_advdupe2=(MOD "advdupe2" "Advanced Duplicator 2" "https://github.com/wiremod/advdupe2/archive/master.zip" "advdupe2-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://www.wiremod.com" "Save your constructions. Second version")
mod_info_pac3=(MOD "pac3" "PAC3" "https://github.com/CapsAdmin/pac3/archive/master.zip" "pac3-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/CapsAdmin/pac3" "Advanced player model customization")
mod_info_wiremod=(MOD "wiremod" "Wiremod" "https://github.com/wiremod/wire/archive/master.zip" "wire-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/wiremod/wire" "Base Wiremod Addon")
mod_info_wiremodextras=(MOD "wiremod-extras" "Wiremod Extras" "https://github.com/wiremod/wire-extras/archive/master.zip" "wire-extras-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/wiremod/wire-extras/" "Addition to Wiremod, Extra Content")
mod_info_advduplicator=(MOD "advdupe1" "Advanced Duplicator 1" "https://github.com/wiremod/advduplicator/archive/master.zip" "advduplicator-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/wiremod/advduplicator" "Save your constructions. First version")
mod_info_trackassemblytool=(MOD "trackassemblytool" "Track Assembly Tool" "https://github.com/dvdvideo1234/trackassemblytool/archive/master.zip" "trackassemblytool-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/TrackAssemblyTool" "Assembles segmented track. Supports wire")
mod_info_physpropertiesadv=(MOD "physpropertiesadv" "Phys Properties Adv" "https://github.com/dvdvideo1234/physpropertiesadv/archive/master.zip" "physpropertiesadv-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/PhysPropertiesAdv" "Advanced configurable properties")
mod_info_controlsystemse2=(MOD "controlsystemse2" "Control Systems E2" "https://github.com/dvdvideo1234/controlsystemse2/archive/master.zip" "controlsystemse2-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/ControlSystemsE2" "PID controllers and fast traces for E2. Minor included in wire-extas")
mod_info_e2pistontiming=(MOD "e2pistontiming" "E2 Piston Timing" "https://github.com/dvdvideo1234/e2pistontiming/archive/master.zip" "e2pistontiming-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/E2PistonTiming" "Routine driven piston engine timings for E2")
mod_info_propcannontool=(MOD "propcannontool" "Prop Cannon Tool" "https://github.com/dvdvideo1234/propcannontool/archive/master.zip" "propcannontool-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/PropCannonTool" "Cannon entity that can fire props. Supports wire")
mod_info_gearassemblytool=(MOD "gearassemblytool" "Gear Assembly Tool" "https://github.com/dvdvideo1234/gearassemblytool/archive/master.zip" "gearassemblytool-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/GearAssemblyTool" "Assembles segmented gearbox")
mod_info_spinnertool=(MOD "spinnertool" "Spinner Tool" "https://github.com/dvdvideo1234/spinnertool/archive/master.zip" "spinnertool-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/SpinnerTool" "Torque lever controlled spinner. Supports wire")
mod_info_surfacefrictiontool=(MOD "surfacefrictiontool" "Surface Friction Tool" "https://github.com/dvdvideo1234/surfacefrictiontool/archive/master.zip" "surfacefrictiontool-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/SurfaceFrictionTool" "Controls the surface friction of a prop")
mod_info_magneticdipole=(MOD "magneticdipole" "Magnetic Dipole" "https://github.com/dvdvideo1234/magneticdipole/archive/master.zip" "magneticdipole-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/MagneticDipole" "Magnet entity that runs forces on its poles. Supports wire")
mod_info_environmentorganizer=(MOD "environmentorganizer" "Environment Organizer" "https://github.com/dvdvideo1234/environmentorganizer/archive/master.zip" "environmentorganizer-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/EnvironmentOrganizer" "Installs routines designed for server settings adjustment")
mod_info_precision_alignment=(MOD "precision-alignment" "Precision Alignment" "https://github.com/Mista-Tea/precision-alignment/archive/master.zip" "precision-alignment-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/Mista-Tea/precision-alignment" "Creates precise constraints and aligments")
mod_info_improved_stacker=(MOD "improved-stacker" "Improved Stacker" "https://github.com/Mista-Tea/improved-stacker/archive/master.zip" "improved-stacker-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/Mista-Tea/improved-stacker" "Stacks entities in the direction chosen")
mod_info_improved_weight=(MOD "improved-weight" "Improved Weight" "https://github.com/Mista-Tea/improved-weight/archive/master.zip" "improved-weight-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/Mista-Tea/improved-weight" "Weight tool but with more features")
mod_info_improved_antinoclip=(MOD "improved-antinoclip" "Improved Antinoclip" "https://github.com/Mista-Tea/improved-antinoclip/archive/master.zip" "improved-antinoclip-master.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/Mista-Tea/improved-antinoclip" "Controls clipping trough an object")
mod_info_darkrp=(MOD "darkrp" "DarkRP" "https://github.com/FPtje/DarkRP/archive/master.zip" "darkrp-master.zip" "0" "LowercaseOn" "${systemdir}/gamemodes" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://darkrp.com" "Most popular gamemode")
mod_info_darkrpmodification=(MOD "darkrpmodification" "DarkRP Modification" "https://github.com/FPtje/darkrpmodification/archive/master.zip" "darkrpmodification-master.zip" "0" "LowercaseOff" "${systemdir}/addons" "NOUPDATE" "ENGINES" "Garry's Mod;" "NOTGAMES" "http://darkrp.com" "Customize DarkRP settings")
mod_info_laserstool=(MOD "laserstool" "Laser STool" "https://github.com/dvdvideo1234/laserstool/archive/main.zip" "laserstool-main.zip" "0" "LowercaseOn" "${systemdir}/addons" "OVERWRITE" "ENGINES" "Garry's Mod;" "NOTGAMES" "https://github.com/dvdvideo1234/LaserSTool" "Scripted tool that spawns laser entities, simulates light rays and even kill players")

# Rust
mod_info_rustcarbon=(MOD "rustcarbon" "Carbon for Rust" "${carbonrustlatestlink}" "Carbon.Linux.Release.tar.gz" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Rust;" "NOTGAMES" "carbonmod.gg" "Allows for the use of both plugins and harmony mods")

# Oxidemod
mod_info_rustoxide=(MOD "rustoxide" "Oxide for Rust" "${oxiderustlatestlink}" "Oxide.Rust-linux.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Rust;" "NOTGAMES" "https://umod.org/games/rust" "Allows for the use of plugins")
mod_info_hwoxide=(MOD "hwoxide" "Oxide for Hurtworld" "${oxidehurtworldlatestlink}" "Oxide.Hurtworld.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Hurtworld;" "NOTGAMES" "https://umod.org/games/hurtworld" "Allows for the use of plugins")
mod_info_sdtdoxide=(MOD "sdtdoxide" "Oxide for 7 Days To Die" "${oxidesdtdlatestlink}" "Oxide.SevenDaysToDie.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "7 Days To Die;" "NOTGAMES" "https://umod.org/games/7-days-to-die" "Allows for the use of plugins")

# ValheimPlus
mod_info_valheimplus=(MOD "valheimplus" "Valheim PLUS" "${valheimpluslatestlink}" "ValheimPlus.tar.gz" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Valheim;" "NOTGAMES" "https://github.com/Grantapher/ValheimPlus.git" "Mod to improve Valheim gameplay")

# BepInEx Valheim
mod_info_bepinexvh=(MOD "bepinexvh" "BepInEx Valheim" "${bepinexvhlatestlink}" "denikson-BepInExPack_Valheim.zip" "0" "LowercaseOff" "${systemdir}" "OVERWRITE" "ENGINES" "Valheim;" "NOTGAMES" "https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/" "Unity / XNA game patcher and plugin framework")

# REQUIRED: Set all mods info into the global array
mods_global_array=("${mod_info_metamod[@]}" "${mod_info_base_amxx[@]}" "${mod_info_cs_amxx[@]}" "${mod_info_dod_amxx[@]}" "${mod_info_tfc_amxx[@]}" "${mod_info_ns_amxx[@]}" "${mod_info_ts_amxx[@]}" "${mod_info_metamodsource[@]}" "${mod_info_sourcemod[@]}" "${mod_info_steamworks[@]}" "${mod_info_gokz[@]}" "${mod_info_ttt[@]}" "${mod_info_get5[@]}" "${mod_info_prac[@]}" "${mod_info_pug[@]}" "${mod_info_dhook[@]}" "${mod_info_movement[@]}" "${mod_info_cleaner[@]}" "${mod_info_ulib[@]}" "${mod_info_ulx[@]}" "${mod_info_utime[@]}" "${mod_info_uclip[@]}" "${mod_info_acf[@]}" "${mod_info_acf_missiles[@]}" "${mod_info_acf_sweps[@]}" "${mod_info_advdupe2[@]}" "${mod_info_pac3[@]}" "${mod_info_wiremod[@]}" "${mod_info_wiremodextras[@]}" "${mod_info_darkrp[@]}" "${mod_info_darkrpmodification[@]}" "${mod_info_rustcarbon[@]}" "${mod_info_rustoxide[@]}" "${mod_info_hwoxide[@]}" "${mod_info_sdtdoxide[@]}" "${mod_info_advduplicator[@]}" "${mod_info_trackassemblytool[@]}" "${mod_info_physpropertiesadv[@]}" "${mod_info_controlsystemse2[@]}" "${mod_info_e2pistontiming[@]}" "${mod_info_propcannontool[@]}" "${mod_info_gearassemblytool[@]}" "${mod_info_spinnertool[@]}" "${mod_info_surfacefrictiontool[@]}" "${mod_info_magneticdipole[@]}" "${mod_info_environmentorganizer[@]}" "${mod_info_precision_alignment[@]}" "${mod_info_improved_stacker[@]}" "${mod_info_improved_weight[@]}" "${mod_info_improved_antinoclip[@]}" "${mod_info_laserstool[@]}" "${mod_info_valheimplus[@]}" "${mod_info_bepinexvh[@]}")
