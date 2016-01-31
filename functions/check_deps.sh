#!/bin/bash
# LGSM check_deps.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="310116"

# Description: Checks that the require dependencies are installed for LGSM


fn_deps_detector(){
# Checks is dependency is missing
if [ -n "$(command -v dpkg-query)" ]; then
	dpkg-query -W -f='${Status}' ${deptocheck} 2>/dev/null| grep -q -P '^install ok installed$'
	depstatus=$?
	if [ "${depstatus}" == "0" ]; then
		missingdep=0
	else
		# if missing dependency is flagged
		missingdep=1
	fi
fi

# Add missing dependencies are added to array_deps_missing array
if [ "${missingdep}" == "1" ]; then
	array_deps_missing+=("${deptocheck}")
fi
}

fn_deps_email(){
# Adds postfix to required dependencies if email notification is enabled
if [ "${emailnotification}" == "on" ]; then
	array_deps_required+=( mailutils postfix )
fi
}

fn_found_missing_deps(){
if [ "${#array_deps_missing[@]}" != "0" ]; then
	fn_printdots "Checking dependencies"
	sleep 2
	fn_printwarn "Checking dependencies: Dependency missing: \e[0;31m${array_deps_missing[@]}\e[0m"
	sleep 1
	echo -e ""
	sudo -n true > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		fn_printinfonl "Attempting to install missing dependencies automatically"
		echo -en ".\r"
		sleep 1
		echo -en "..\r"
		sleep 1
		echo -en "...\r"
		sleep 1
		echo -en "   \r"	
		sudo apt-get install ${array_deps_missing[@]}
		exit 1
	else
		echo ""
		fn_printinfomationnl "$(whoami) does not have sudo access. manually install dependencies"
		echo ""
		echo "sudo apt-get install ${array_deps_missing[@]}"
		echo ""
		exit 1
	fi
fi	
}



# Check will only run if using apt-get or yum
if [ -n "$(command -v dpkg-query)" ]; then
	# Generate array of missing deps
	array_deps_missing=()
	fn_printdots "Checking dependencies"

	# LGSM requirement for curl
	local array_deps_required=( curl )

	# All servers except ts3 require tmux
	if [ "${executable}" != "./ts3server_startscript.sh" ]; then
		local array_deps_required+=( tmux )
	fi

	# All servers excelts ts3 & mumble require libstdc++6,lib32gcc1
	if [ "${executable}" != "./ts3server_startscript.sh" ]||[ "${executable}" != "./murmur.x86" ]; then
		local array_deps_required+=( lib32gcc1 libstdc++6:i386 )
	fi

# Game Specific requirements

	# Spark
	if [ "${engine}" ==  "spark" ]; then
		local array_deps_required+=( speex:i386 libtbb2 )
	# 7 Days to Die	
	elif [ "${executable}" ==  "./7DaysToDie.sh" ]; then
		local array_deps_required+=( telnet expect )
	# Brainbread 2 and Don't Starve Together
	elif [ "${gamename}" == "Brainbread 2" ]||[ "${gamename}" == "Don't Starve Together" ]; then
		local array_deps_required+=( libcurl4-gnutls-dev:i386 )
	if [ "${engine}" ==  "projectzomboid" ]; then
		local array_deps_required+=( openjdk-7-jre )
	# Unreal engine
	elif [ "${executable}" ==  "./ucc-bin" ]; then
		#UT2K4
		if [ -f "${executabledir}/ut2004-bin" ]; then
			local array_deps_required+=( libsdl1.2debian libstdc++5:i386 bzip2 unzip )
		#UT99
		else
			local array_deps_required+=( libsdl1.2debian bzip2 )
		fi
	else
		fn_printfail "Unknown executable"
		exit	
	fi
	fn_deps_email

	# Loop though required depenencies
	for deptocheck in "${array_deps_required[@]}"
	do
		fn_deps_detector
	done

	# user to be informaed of any missing dependecies 
	fn_found_missing_deps
fi