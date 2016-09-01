#!/bin/bash
# LGSM check_deps.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Checks if required dependencies are installed for LGSM.

local commandname="CHECK"



fn_deps_detector(){
	# Checks if dependency is missing
	if [ "${tmuxcheck}" == "1" ]; then
		# Added for users compiling tmux from source to bypass check.
		depstatus=0
		deptocheck="tmux"
		unset tmuxcheck
	elif [ "${javacheck}" == "1" ]; then
		# Added for users using Oracle JRE to bypass check.
		depstatus=0
		deptocheck="${javaversion}"
		unset javacheck
	elif [ -n "$(command -v apt-get)" ]; then
		dpkg-query -W -f='${Status}' ${deptocheck} 2>/dev/null | grep -q -P '^install ok installed$'
		depstatus=$?
	elif [ -n "$(command -v yum)" ]; then
		yum -q list installed ${deptocheck} > /dev/null 2>&1
		depstatus=$?
	fi

	if [ "${depstatus}" == "0" ]; then
		# if dependency is found
		missingdep=0
		if [ "${function_selfname}" == "command_install.sh" ]; then
			echo -e "${green}${deptocheck}${default}"
			sleep 0.5
		fi
	else
		# if dependency is not found
		missingdep=1
		if [ "${function_selfname}" == "command_install.sh" ]; then
			echo -e "${red}${deptocheck}${default}"
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
		sleep 0.5
		fn_print_error_nl "Checking dependencies: missing: ${red}${array_deps_missing[@]}${default}"
		fn_script_log_error "Checking dependencies: missing: ${red}${array_deps_missing[@]}${default}"
		sleep 1
		sudo -v > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			fn_print_information_nl "Automatically installing missing dependencies."
			fn_script_log_info "Automatically installing missing dependencies."
			echo -en ".\r"
			sleep 1
			echo -en "..\r"
			sleep 1
			echo -en "...\r"
			sleep 1
			echo -en "   \r"
			if [ -n "$(command -v dpkg-query)" ]; then
				cmd="sudo dpkg --add-architecture i386; sudo apt-get -y install ${array_deps_missing[@]}"
				eval ${cmd}
			elif [ -n "$(command -v yum)" ]; then
				cmd="sudo yum -y install ${array_deps_missing[@]}"
				eval ${cmd}
			fi
			if [ $? != 0 ]; then
				fn_print_failure_nl "Unable to install dependencies"
				fn_script_log_fatal "Unable to install dependencies"
			else
				fn_print_complete_nl "Install dependencies completed"
				fn_script_log_pass "Install dependencies completed"
			fi
		else
			echo ""
			fn_print_warning_nl "$(whoami) does not have sudo access. Manually install dependencies."
			fn_script_log_warn "$(whoami) does not have sudo access. Manually install dependencies."
			if [ -n "$(command -v dpkg-query)" ]; then
				echo "	sudo dpkg --add-architecture i386; sudo apt-get install ${array_deps_missing[@]}"
			elif [ -n "$(command -v yum)" ]; then
				echo "	sudo yum install ${array_deps_missing[@]}"
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

	# user to be informed of any missing dependencies
	fn_found_missing_deps
}

info_distro.sh

if [ "${function_selfname}" == "command_install.sh" ]; then
	echo ""
	echo "Checking Dependencies"
	echo "================================="
fi

# Check will only run if using apt-get or yum
if [ -n "$(command -v dpkg-query)" ]; then
	# Generate array of missing deps
	array_deps_missing=()

	# LGSM requirements
	array_deps_required=( curl wget ca-certificates file bsdmainutils util-linux python bzip2 gzip )

	# All servers except ts3 require tmux
	if [ "${gamename}" != "TeamSpeak 3" ]; then
		if [ "$(command -v tmux)" ]||[ "$(which tmux 2>/dev/null)" ]||[ -f "/usr/bin/tmux" ]||[ -f "/bin/tmux" ]; then
			tmuxcheck=1 # Added for users compiling tmux from source to bypass check.
		else
			array_deps_required+=( tmux )
		fi
	fi

	# All servers except ts3,mumble and minecraft servers require libstdc++6 and lib32gcc1
	if [ "${gamename}" != "TeamSpeak 3" ]&&[ "${gamename}" != "Mumble" ]&&[ "${engine}" != "lwjgl2" ]; then
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
	# No More Room in Hell, Counter-Strike: Source and Garry's Mod
	elif [ "${gamename}" == "No More Room in Hell" ]||[ "${gamename}" == "Counter-Strike: Source" ]||[ "${gamename}" == "Garry's Mod" ]; then
		if [ "${arch}" == "x86_64" ]; then
			array_deps_required+=( lib32tinfo5 )
		else
			array_deps_required+=( libtinfo5 )
		fi
	# Brainbread 2 and Don't Starve Together
	elif [ "${gamename}" == "Brainbread 2" ]||[ "${gamename}" == "Don't Starve Together" ]; then
		array_deps_required+=( libcurl4-gnutls-dev:i386 )
	# Battlefield: 1942 requies ncurses
	elif [ "${gamename}" == "Battlefield: 1942" ]; then
		array_deps_required+=( libncurses5:i386 )
	# Project Zomboid and Minecraft
	elif [ "${engine}" ==  "projectzomboid" ]||[ "${engine}" == "lwjgl2" ]; then
		javaversion=$(java -version 2>&1 | grep "version")
		if [ -n "${javaversion}" ]; then
			javacheck=1 # Added for users using Oracle JRE to bypass the check.
		else
			array_deps_required+=( default-jre )
		fi
	# GoldenEye: Source
	elif [ "${gamename}" ==  "GoldenEye: Source" ]; then
		array_deps_required+=( zlib1g:i386 )
	# Unreal Engine
	elif [ "${executable}" ==  "./ucc-bin" ]; then
		#UT2K4
		if [ -f "${executabledir}/ut2004-bin" ]; then
			array_deps_required+=( libsdl1.2debian libstdc++5:i386 bzip2 )
		#UT99
		else
			array_deps_required+=( libsdl1.2debian bzip2 )
		fi
	# Unreal Tournament
	elif [ "${gamename}" == "Unreal Tournament" ]; then
		array_deps_required+=( unzip )
	fi
	fn_deps_email
	fn_check_loop

elif [ -n "$(command -v yum)" ]; then
	# Generate array of missing deps
	array_deps_missing=()

	# LGSM requirements
	if [ "${distroversion}" == "6" ]; then
		array_deps_required=( curl wget util-linux-ng python file gzip bzip2 )
	else
		array_deps_required=( curl wget util-linux python file gzip bzip2 )
	fi

	# All servers except ts3 require tmux
	if [ "${gamename}" != "TeamSpeak 3" ]; then
		if [ "$(command -v tmux)" ]||[ "$(which tmux 2>/dev/null)" ]||[ -f "/usr/bin/tmux" ]||[ -f "/bin/tmux" ]; then
			tmuxcheck=1 # Added for users compiling tmux from source to bypass check.
		else
			array_deps_required+=( tmux )
		fi
	fi

	# All servers except ts3,mumble and minecraft servers require glibc.i686 and libstdc++.i686
	if [ "${gamename}" != "TeamSpeak 3" ]&&[ "${gamename}" != "Mumble" ]&&[ "${engine}" != "lwjgl2" ]; then
		array_deps_required+=( glibc.i686 libstdc++.i686 )
	fi

	# Game Specific requirements

	# Spark
	if [ "${engine}" ==  "spark" ]; then
		array_deps_required+=( speex.i686 tbb.i686 )
	# 7 Days to Die
	elif [ "${gamename}" ==  "7 Days To Die" ]; then
		array_deps_required+=( telnet expect )
	# No More Room in Hell, Counter-Strike: Source and Garry's Mod
	elif [ "${gamename}" == "No More Room in Hell" ]||[ "${gamename}" == "Counter-Strike: Source" ]||[ "${gamename}" == "Garry's Mod" ]; then
		array_deps_required+=( ncurses-libs.i686 )
	# Brainbread 2 and Don't Starve Together
	elif [ "${gamename}" == "Brainbread 2" ]||[ "${gamename}" == "Don't Starve Together" ]; then
		array_deps_required+=( libcurl.i686 )
	# Project Zomboid and Minecraft
	elif [ "${engine}" ==  "projectzomboid" ]||[ "${engine}" == "lwjgl2" ]; then
		javaversion=$(java -version 2>&1 | grep "version")
		if [ -n "${javaversion}" ]; then
			javacheck=1 # Added for users using Oracle JRE to bypass the check.
		else
			array_deps_required+=( java-1.8.0-openjdk )
		fi
	# GoldenEye: Source
	elif [ "${gamename}" ==  "GoldenEye: Source" ]; then
		array_deps_required+=( zlib.i686 )
	# Unreal Engine
	elif [ "${executable}" ==  "./ucc-bin" ]; then
		#UT2K4
		if [ -f "${executabledir}/ut2004-bin" ]; then
			array_deps_required+=( compat-libstdc++-33.i686 SDL.i686 bzip2 )
		#UT99
		else
			array_deps_required+=( SDL.i686 bzip2 )
		fi
	# Unreal Tournament
	elif [ "${gamename}" == "Unreal Tournament" ]; then
		array_deps_required+=( unzip )
	fi
	fn_deps_email
	fn_check_loop
fi
