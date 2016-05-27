#!/bin/bash
# LGSM check_deps.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="270516"

# Description: Checks that the requires dependencies are installed for LGSM.


fn_deps_detector(){
	# Checks if dependency is missing
	if [ -n "$(command -v dpkg-query)" ]; then
		dpkg-query -W -f='${Status}' ${deptocheck} 2>/dev/null| grep -q -P '^install ok installed$'
		depstatus=$?
	elif [ -n "$(command -v yum)" ]; then
		yum -q list installed ${deptocheck} > /dev/null 2>&1
		depstatus=$?
	fi	
	if [ "${depstatus}" == "0" ]; then
		missingdep=0
		if [ "${function_selfname}" == "command_install.sh" ]; then
			echo -e "\e[0;32m${deptocheck}\e[0m"
			sleep 0.5
		fi
	else
		# if missing dependency is found
		missingdep=1
		if [ "${function_selfname}" == "command_install.sh" ]; then
			echo -e "\e[0;31m${deptocheck}\e[0m"
			sleep 0.5
		fi	
	fi

	# Missing dependencies are added to array_deps_missing
	if [ "${missingdep}" == "1" ]; then
		array_deps_missing+=("${deptocheck}")
	fi
}

fn_deps_email(){
	# Adds postfix to required dependencies if email alert is enabled
	if [ "${emailalert}" == "on" ]; then
		if [ -f /usr/bin/mailx ]; then
			if [ -d /etc/exim4 ]; then
				array_deps_required+=( exim4 )
			elif [ -d /etc/sendmail ]; then
				array_deps_required+=( sendmail )
			elif [ -n "$(command -v dpkg-query)" ]; then
				array_deps_required+=( mailutils postfix )
			elif [ -n "$(command -v yum)" ]; then
				array_deps_required+=( mailx postfix )
			fi	
		else 
			if [ -n "$(command -v dpkg-query)" ]; then
				array_deps_required+=( mailutils postfix )
			elif [ -n "$(command -v yum)" ]; then
				array_deps_required+=( mailx postfix )
			fi
		fi
	fi
}

fn_found_missing_deps(){
	if [ "${#array_deps_missing[@]}" != "0" ]; then
		fn_print_dots "Checking dependencies"
		sleep 2
		fn_print_warn "Checking dependencies: missing: \e[0;31m${array_deps_missing[@]}\e[0m"
		fn_scriptlog "Checking dependencies: missing: \e[0;31m${array_deps_missing[@]}\e[0m"
		sleep 1
		echo -e ""
		sudo -n true > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			fn_print_info_nl "Attempting to install missing dependencies automatically"
			echo -en ".\r"
			sleep 1
			echo -en "..\r"
			sleep 1
			echo -en "...\r"
			sleep 1
			echo -en "   \r"	
			if [ -n "$(command -v dpkg-query)" ]; then
				echo "sudo dpkg --add-architecture i386; sudo apt-get install ${array_deps_missing[@]}"
			elif [ -n "$(command -v yum)" ]; then
				echo "yum install ${array_deps_missing[@]}"
			fi	
		else
			echo ""
			fn_print_infomation_nl "$(whoami) does not have sudo access. Please manually install dependencies"
			fn_scriptlog "$(whoami) does not have sudo access. Please manually install dependencies"
			echo ""
			if [ -n "$(command -v dpkg-query)" ]; then
				echo "sudo dpkg --add-architecture i386; sudo apt-get install ${array_deps_missing[@]}"
			elif [ -n "$(command -v yum)" ]; then
				echo "yum install ${array_deps_missing[@]}"
			fi	
			echo ""
		fi
		if [ "${function_selfname}" == "command_install.sh" ]; then
			sleep 5
		fi
	fi	
}

fn_check_loop(){
	# Loop though required depenencies
	for deptocheck in "${array_deps_required[@]}"
	do
		fn_deps_detector
	done

	# user to be informaed of any missing dependecies 
	fn_found_missing_deps
}

info_distro.sh

if [ "${function_selfname}" == "command_install.sh" ]; then
	echo ""
	echo "Checking Dependecies"
	echo "================================="
fi

# Check will only run if using apt-get or yum
if [ -n "$(command -v dpkg-query)" ]; then
	# Generate array of missing deps
	array_deps_missing=()

	# LGSM requirement for curl
	array_deps_required=( curl ca-certificates file )

	# All servers except ts3 require tmux
	if [ "${executable}" != "./ts3server_startscript.sh" ]; then
		array_deps_required+=( tmux )
	fi

	# All servers except ts3 & mumble require libstdc++6, lib32gcc1
	if [ "${executable}" != "./ts3server_startscript.sh" ]||[ "${executable}" != "./murmur.x86" ]; then
		if [ "${arch}" == "x86_64" ]; then
			array_deps_required+=( lib32gcc1 libstdc++6:i386 )
		else
			array_deps_required+=( libstdc++6:i386 )
		fi	
	fi

	# Game Specific requirements

	# Spark
	if [ "${engine}" ==  "spark" ]; then
		array_deps_required+=( speex:i386 libtbb2 )
	# 7 Days to Die	
	elif [ "${gamename}" ==  "7 Days To Die" ]; then
		array_deps_required+=( telnet expect )
	# No More Room in Hell	
	elif [ "${gamename}" == "No More Room in Hell" ]; then
		array_deps_required+=( lib32tinfo5 )
	# Brainbread 2 and Don't Starve Together
	elif [ "${gamename}" == "Brainbread 2" ]||[ "${gamename}" == "Don't Starve Together" ]; then
		array_deps_required+=( libcurl4-gnutls-dev:i386 )
	elif [ "${engine}" ==  "projectzomboid" ]; then
		array_deps_required+=( openjdk-7-jre )
	# Unreal engine
	elif [ "${executable}" ==  "./ucc-bin" ]; then
		#UT2K4
		if [ -f "${executabledir}/ut2004-bin" ]; then
			array_deps_required+=( libsdl1.2debian libstdc++5:i386 bzip2 )
		#UT99
		else
			array_deps_required+=( libsdl1.2debian bzip2 )
		fi	
	fi
	fn_deps_email
	fn_check_loop

elif [ -n "$(command -v yum)" ]; then
	# Generate array of missing deps
	array_deps_missing=()

	# LGSM requirement for curl
	array_deps_required=( curl )

	# All servers except ts3 require tmux
	if [ "${executable}" != "./ts3server_startscript.sh" ]; then
		array_deps_required+=( tmux )
	fi

	# All servers excelts ts3 & mumble require glibc.i686 libstdc++.i686
	if [ "${executable}" != "./ts3server_startscript.sh" ]||[ "${executable}" != "./murmur.x86" ]; then
		array_deps_required+=( glibc.i686 libstdc++.i686 )
	fi

	# Game Specific requirements

	# Spark
	if [ "${engine}" ==  "spark" ]; then
		array_deps_required+=( speex.i686 tbb.i686 )
	# 7 Days to Die	
	elif [ "${gamename}" ==  "7 Days To Die" ]; then
		array_deps_required+=( telnet expect )
	# No More Room in Hell	
	elif [ "${gamename}" == "No More Room in Hell" ]; then
		array_deps_required+=( ncurses-libs.i686 )
	# Brainbread 2 and Don't Starve Together
	elif [ "${gamename}" == "Brainbread 2" ]||[ "${gamename}" == "Don't Starve Together" ]; then
		array_deps_required+=( libcurl.i686 )
	elif [ "${engine}" ==  "projectzomboid" ]; then
		array_deps_required+=( java-1.7.0-openjdk )
	# Unreal engine
	elif [ "${executable}" ==  "./ucc-bin" ]; then
		#UT2K4
		if [ -f "${executabledir}/ut2004-bin" ]; then
			array_deps_required+=( compat-libstdc++-33.i686 SDL.i686 bzip2 )
		#UT99
		else
			array_deps_required+=( SDL.i686 bzip2 )
		fi	
	fi
	fn_deps_email
	fn_check_loop
fi