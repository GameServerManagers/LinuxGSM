#!/bin/bash
# LGSM install_config.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates default server configs.

local commandname="INSTALL"
local commandaction="Install"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_defaultconfig(){
	echo "creating ${servercfg} config file."
	fn_script_log_info "creating ${servercfg} config file."
	cp -v "${servercfgdefault}" "${servercfgfullpath}"
	sleep 1
}

fn_userinputconfig(){
	# allow user to input server name and password
	if [ -z "${autoinstall}" ]; then
		echo ""
		echo "Configuring ${gamename} Server"
		echo "================================="
		sleep 1
		read -p "Enter server name: " servername
		read -p "Enter rcon password: " rconpass
	else
		servername="${servicename}"
		rconpass="rconpassword"
	fi
	echo "changing hostname."
	fn_script_log_info "changing hostname."
	sed -i "s/\"<hostname>\"/\"${servername}\"/g" "${servercfgfullpath}"
	sleep 1
	echo "changing rconpassword."
	fn_script_log_info "changing rconpassword."
	sed -i "s/\"<rconpassword>\"/\"${rconpass}\"/g" "${servercfgfullpath}"
	sleep 1
}

fn_arma3config(){
	fn_defaultconfig
	echo "creating ${networkcfg} config file."
	fn_script_log_info "creating ${networkcfg} config file."
	cp -v "${networkcfgdefault}" "${networkcfgfullpath}"
	sleep 1
	echo ""
}

fn_goldsourceconfig(){
	fn_defaultconfig

	# server.cfg redirects to ${servercfg} for added security
	echo "creating server.cfg."
	fn_script_log_info "creating server.cfg."
	touch "server.cfg"
	sleep 1
	echo "creating redirect."
	fn_script_log_info "creating redirect."
	echo "server.cfg > ${servercfg}."
	echo "exec ${servercfg}" > "server.cfg"
	sleep 1

	# creating other files required
	echo "creating listip.cfg."
	fn_script_log_info "creating listip.cfg."
	touch "${systemdir}/listip.cfg"
	sleep 1
	echo "creating banned.cfg."
	fn_script_log_info "creating banned.cfg."
	touch "${systemdir}/banned.cfg"
	sleep 1

	fn_userinputconfig
	echo ""
}

fn_serious3config(){
	fn_defaultconfig
	echo ""
	echo "To edit ${gamename} server config use SS3 Server GUI 3 tool"
	echo "http://mrag.nl/sgui3/"
	fn_script_log_info "To edit ${gamename} server config use SS3 Server GUI 3 tool"
	fn_script_log_info "http://mrag.nl/sgui3/"
	sleep 1
	echo ""
}

fn_sourceconfig(){
	fn_defaultconfig

	# server.cfg redirects to ${servercfg} for added security
	echo "creating server.cfg."
	fn_script_log_info "creating server.cfg."
	touch "server.cfg"
	sleep 1
	echo "creating redirect."
	fn_script_log_info "creating redirect."
	echo "server.cfg > ${servercfg}."
	echo "exec ${servercfg}" > "server.cfg"
	sleep 1

	fn_userinputconfig
	echo ""
}

fn_teeworldsconfig(){
	fn_defaultconfig

	echo "adding logfile location to config."
	fn_script_log_info "adding logfile location to config."
	sed -i "s@\"<logfile>\"@\"${gamelog}\"@g" "${servercfgfullpath}"
	sleep 1
	echo "removing password holder."
	fn_script_log_info "removing password holder."
	sed -i "s/<password>//" "${servercfgfullpath}"
	sleep 1

	fn_userinputconfig
	echo ""
}

fn_ut99config(){
	echo "creating ${servercfg} config file."
	fn_script_log_info "creating ${servercfg} config file."
	echo "${servercfgdefault} > ${servercfgfullpath}"
	tr -d '\r' < "${servercfgdefault}" > "${servercfgfullpath}"
	sleep 1
	echo ""
	echo "Configuring ${gamename} Server"
	echo "================================="
	sleep 1
	echo "enabling WebAdmin."
	fn_script_log_info "enabling WebAdmin."
	sed -i 's/bEnabled=False/bEnabled=True/g' "${servercfgfullpath}"
	sleep 1
	echo "setting WebAdmin port to 8076."
	fn_script_log_info "setting WebAdmin port to 8076."
	sed -i '467i\ListenPort=8076' "${servercfgfullpath}"
	sleep 1
	echo ""
}

fn_unreal2config(){
	fn_defaultconfig
	echo ""
	echo "Configuring ${gamename} Server"
	echo "================================="
	sleep 1
	echo "setting WebAdmin username and password."
	fn_script_log_info "setting WebAdmin username and password."
	sed -i 's/AdminName=/AdminName=admin/g' "${servercfgfullpath}"
	sed -i 's/AdminPassword=/AdminPassword=admin/g' "${servercfgfullpath}"
	sleep 1
	echo "enabling WebAdmin."
	fn_script_log_info "enabling WebAdmin."
	sed -i 's/bEnabled=False/bEnabled=True/g' "${servercfgfullpath}"
	if [ "${gamename}" == "Unreal Tournament 2004" ]; then
		sleep 1
		echo "setting WebAdmin port to 8075."
		fn_script_log_info "setting WebAdmin port to 8075."
		sed -i 's/ListenPort=80/ListenPort=8075/g' "${servercfgfullpath}"
	fi
	sleep 1
	echo ""
}

fn_ut3config(){
	echo ""
	echo "Configuring ${gamename} Server"
	echo "================================="
	sleep 1
	echo "setting ServerName to 'LinuxGSM UT3 Server'."
	fn_script_log_info "setting ServerName to 'LinuxGSM UT3 Server'."
	sleep 1
	sed -i 's/ServerName=/ServerName=LinuxGSM UT3 Server/g' "${servercfgdir}/DefaultGame.ini"
	echo "setting WebAdmin password to admin."
	fn_script_log_info "setting WebAdmin password to admin."
	echo '[Engine.AccessControl]' >> "${servercfgdir}/DefaultGame.ini"
	echo 'AdminPassword=admin' >> "${servercfgdir}/DefaultGame.ini"
	sleep 1
	echo "enabling WebAdmin."
	fn_script_log_info "enabling WebAdmin."
	sed -i 's/bEnabled=false/bEnabled=True/g' "${servercfgdir}/DefaultWeb.ini"
	if [ "${gamename}" == "Unreal Tournament 3" ]; then
		sleep 1
		echo "setting WebAdmin port to 8081."
		fn_script_log_info "setting WebAdmin port to 8081."
		sed -i 's/ListenPort=80/ListenPort=8081/g' "${servercfgdir}/DefaultWeb.ini"
	fi
	sleep 1
	echo ""
}

fn_unrealtournament(){
	# allow user to input server name and password
	if [ -z "${autoinstall}" ]; then
		echo ""
		echo "Configuring ${gamename} Server"
		echo "================================="
		sleep 1
		read -p "Enter server name: " servername
		read -p "Enter rcon password: " rconpass
	else
		servername="${servicename}"
		rconpass="rconpassword"
	fi
	echo "changing hostname."
	fn_script_log_info "changing hostname."
	sed -i "s/\"<hostname>\"/\"${servername}\"/g" "${servercfgdir}/Game.ini"
	sleep 1
	echo "changing rconpassword."
	fn_script_log_info "changing rconpassword."
	sed -i "s/\"<rconpassword>\"/\"${rconpass}\"/g" "${servercfgdir}/Engine.ini"
	sleep 1

}

echo ""
if [ "${gamename}" != "Hurtworld" ]; then
echo "Creating Configs"
echo "================================="
sleep 1
	mkdir -pv "${servercfgdir}"
	cd "${servercfgdir}"
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}"
fi

if [ "${gamename}" == "7 Days To Die" ]; then
	fn_defaultconfig
elif [ "${gamename}" == "ARK: Survivial Evolved" ]; then
	wget -N /dev/null ${githuburl}/ARKSurvivalEvolved/cfg/lgsm-default.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	echo -e "downloading lgsm-default.ini...\c"
	fn_defaultconfig
elif [ "${gamename}" == "ARMA 3" ]; then
	echo -e "downloading lgsm-default.server.cfg...\c"
	wget -N /dev/null ${githuburl}/Arma3/cfg/lgsm-default.server.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	echo -e "downloading lgsm-default.network.cfg...\c"
	wget -N /dev/null ${githuburl}/Arma3/cfg/lgsm-default.network.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_arma3config
elif [ "${gamename}" == "BrainBread 2" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/BrainBread2/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Black Mesa: Deathmatch" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/BlackMesa/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Blade Symphony" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/BladeSymphony/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_goldsourceconfig
elif [ "${gamename}" == "Codename CURE" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/CodenameCURE/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Counter-Strike 1.6" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/CounterStrike/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_goldsourceconfig
elif [ "${gamename}" == "Counter-Strike: Condition Zero" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/CounterStrikeConditionZero/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_goldsourceconfig
elif [ "${gamename}" == "Counter-Strike: Global Offensive" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/CounterStrikeGlobalOffensive/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Counter-Strike: Source" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/CounterStrikeSource/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Day of Defeat" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/DayOfDefeat/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_goldsourceconfig
elif [ "${gamename}" == "Day of Defeat: Source" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/DayOfDefeatSource/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Day of Infamy" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/DayOfInfamy/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Don't Starve Together" ]; then
	echo -e "downloading lgsm-default.ini...\c"
	wget -N /dev/null ${githuburl}/DontStarveTogether/cfg/lgsm-default.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
elif [ "${gamename}" == "Double Action: Boogaloo" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/DoubleActionBoogaloo/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Empires Mod" ]; then
	fn_defaultconfig
elif [ "${gamename}" == "Enemy Territory" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/EnemyTerritory/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
	fn_userinputconfig
	echo ""
elif [ "${gamename}" == "Fistful of Frags" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/FistfulOfFrags/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Garry's Mod" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/GarrysMod/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "GoldenEye: Source" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/GoldenEyeSource/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Half Life 2: Deathmatch" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/HalfLife2Deathmatch/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Half Life: Deathmatch" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/HalfLifeDeathmatch/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_goldsourceconfig
elif [ "${gamename}" == "Insurgency" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/Insurgency/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Just Cause 2" ]; then
	fn_defaultconfig
elif [ "${gamename}" == "Killing Floor" ]; then
	fn_unreal2config
elif [ "${gamename}" == "Left 4 Dead" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/Left4Dead/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Left 4 Dead 2" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/Left4Dead2/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Minecraft" ]; then
	echo -e "downloading lgsm-default.ini...\c"
	wget -N /dev/null ${githuburl}/Minecraft/cfg/lgsm-default.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
elif [ "${gamename}" == "No More Room in Hell" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/NoMoreRoomInHell/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Natural Selection 2" ]; then
	echo -e "no configs required."
	sleep 1
	echo ""
elif [ "${gamename}" == "Pirates, Vikings, and Knights II" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/PiratesVikingandKnightsII/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Project Zomboid" ]; then
	echo -e "downloading lgsm-default.ini...\c"
	wget -N /dev/null ${githuburl}/ProjectZomboid/cfg/lgsm-default.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
elif [ "${gamename}" == "Quake Live" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/QuakeLive/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
	fn_userinputconfig
elif [ "${gamename}" == "Red Orchestra: Ostfront 41-45" ]; then
	fn_unreal2config
elif [ "${gamename}" == "Serious Sam 3: BFE" ]; then
	echo -e "downloading lgsm-default.ini...\c"
	wget -N /dev/null ${githuburl}/SeriousSam3BFE/cfg/lgsm-default.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_serious3config
elif [ "${gamename}" == "Rust" ]; then
	echo -e "downloading server.cfg...\c"
	wget -N /dev/null  ${githuburl}/Rust/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
elif [ "${gamename}" == "Sven Co-op" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/SvenCoop/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_goldsourceconfig
elif [ "${gamename}" == "Starbound" ]; then
	echo -e "downloading lgsm-default.config...\c"
	wget -N /dev/null ${githuburl}/Starbound/cfg/lgsm-default.config 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
	fn_userinputconfig
elif [ "${gamename}" == "TeamSpeak 3" ]; then
	echo -e "downloading lgsm-default.ini...\c"
	wget -N /dev/null ${githuburl}/TeamSpeak3/cfg/lgsm-default.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
elif [ "${gamename}" == "Team Fortress 2" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/TeamFortress2/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_sourceconfig
elif [ "${gamename}" == "Team Fortress Classic" ]; then
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/TeamFortressClassic/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_goldsourceconfig
elif [ "${gamename}" == "Teeworlds" ]; then
	echo -e "downloading ctf.cfg...\c"
	wget -N /dev/null ${githuburl}/Teeworlds/cfg/ctf.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	echo -e "downloading dm.cfg...\c"
	wget -N /dev/null ${githuburl}/Teeworlds/cfg/dm.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	echo -e "downloading duel.cfg...\c"
	wget -N /dev/null ${githuburl}/Teeworlds/cfg/duel.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	echo -e "downloading tdm.cfg...\c"
	wget -N /dev/null ${githuburl}/Teeworlds/cfg/tdm.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	echo -e "downloading lgsm-default.cfg...\c"
	wget -N /dev/null ${githuburl}/Teeworlds/cfg/lgsm-default.cfg 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_teeworldsconfig
elif [ "${gamename}" == "Terraria" ]; then
	echo -e "downloading lgsm-default.txt...\c"
	wget -N /dev/null ${githuburl}/Terraria/cfg/lgsm-default.txt 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_defaultconfig
elif [ "${gamename}" == "Unreal Tournament" ]; then
	echo -e "downloading Engine.ini...\c"
	wget -N /dev/null ${githuburl}/UnrealTournament/cfg/Engine.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	echo -e "downloading Game.ini...\c"
	wget -N /dev/null ${githuburl}/UnrealTournament/cfg/Game.ini 2>&1 | grep -F HTTP | cut -c45- | uniq
	sleep 1
	fn_unrealtournament
elif [ "${gamename}" == "Unreal Tournament 3" ]; then
	fn_ut3config
elif [ "${gamename}" == "Unreal Tournament 2004" ]; then
	fn_unreal2config
elif [ "${gamename}" == "Unreal Tournament 99" ]; then
	fn_ut99config
fi
