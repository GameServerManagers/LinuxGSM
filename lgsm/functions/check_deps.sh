#!/bin/bash
# LinuxGSM check_deps.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if required dependencies are installed for LinuxGSM.

local commandname="CHECK"

fn_add_mono_repo(){
	# TODO: Detect correct distro and version for source url
	if [ "${monostatus}" != "0" ]; then
		fn_print_dots_nl "Adding Mono repository"
		sleep 0.5
		sudo -v > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			fn_print_information_nl "Automatically adding repository."
			fn_script_log_info "Automatically adding repository."
			echo -en ".\r"
			sleep 1
			echo -en "..\r"
			sleep 1
			echo -en "...\r"
			sleep 1
			echo -en "   \r"
			if [ -n "$(command -v dpkg-query 2>/dev/null)" ]; then
				cmd="sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && echo 'deb http://download.mono-project.com/repo/ubuntu stable-xenial main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list && sudo apt-get update"
				eval ${cmd}
			elif [ -n "$(command -v yum 2>/dev/null)" ]; then
				cmd="rpm --import 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF' && su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'"
				eval ${cmd}
			fi
			if [ $? != 0 ]; then
				fn_print_failure_nl "Unable to add Mono repository"
				fn_script_log_fatal "Unable to add Mono repository"
				exit 1
			else
				fn_print_complete_nl "Add Mono repository completed"
				fn_script_log_pass "Add Mono repository completed"
			fi
		else
			echo ""
			fn_print_warning_nl "$(whoami) does not have sudo access. Manually add Mono repository."
			fn_script_log_warn "$(whoami) does not have sudo access. Manually add Mono repository."
			if [ -n "$(command -v dpkg-query 2>/dev/null)" ]; then
				echo "	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && echo 'deb http://download.mono-project.com/repo/ubuntu stable-xenial main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list && sudo apt-get update"
			elif [ -n "$(command -v yum 2>/dev/null)" ]; then
				echo "	rpm --import 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF' && su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'"
			fi
			echo ""
			exit 1
		fi
	fi
}

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
	elif [ "${deptocheck}" == "mono-complete" ]; then
		if [ "$(command -v mono 2>/dev/null)" && "$(mono --version 2>&1 | grep -Po '(?<=version )\d')" -ge 5 ]; then
			# Mono >= 5.0.0 already installed
			depstatus=0
		else
			# Mono not installed or installed Mono < 5.0.0
			depstatus=1
			monostatus=1
		fi
	elif [ -n "$(command -v apt 2>/dev/null)" ]; then
		dpkg-query -W -f='${Status}' "${deptocheck}" 2>/dev/null | grep -q -P '^install ok installed'
		depstatus=$?
	elif [ -n "$(command -v rpm 2>/dev/null)" ]; then
		rpm -q "${deptocheck}" > /dev/null 2>&1
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
			elif [ -n "$(command -v dpkg-query 2>/dev/null)" ]; then
				array_deps_required+=( mailutils postfix )
			elif [ -n "$(command -v rpm 2>/dev/null)" ]; then
				array_deps_required+=( mailx postfix )
			fi
		else
			if [ -n "$(command -v dpkg-query 2>/dev/null)" ]; then
				array_deps_required+=( mailutils postfix )
			elif [ -n "$(command -v rpm 2>/dev/null)" ]; then
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
		fn_script_log_error "Checking dependencies: missing: ${array_deps_missing[@]}"
		sleep 0.5
		if [ -n "${monostatus}" ]; then
			fn_add_mono_repo
		fi
		sleep 0.5
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
			if [ -n "$(command -v dpkg-query 2>/dev/null)" ]; then
				cmd="sudo dpkg --add-architecture i386; sudo apt update; sudo apt -y install ${array_deps_missing[@]}"
				eval "${cmd}"
			elif [ -n "$(command -v dnf 2>/dev/null)" ]; then
				cmd="sudo dnf -y install ${array_deps_missing[@]}"
				eval "${cmd}"
			elif [ -n "$(command -v yum 2>/dev/null)" ]; then
				cmd="sudo yum -y install ${array_deps_missing[@]}"
				eval "${cmd}"
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
			if [ -n "$(command -v dpkg-query 2>/dev/null)" ]; then
				echo "	sudo dpkg --add-architecture i386; sudo apt update; sudo apt install ${array_deps_missing[@]}"
			elif [ -n "$(command -v dnf 2>/dev/null)" ]; then
				echo "	sudo dnf install ${array_deps_missing[@]}"
			elif [ -n "$(command -v yum 2>/dev/null)" ]; then
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

# Check will only run if using apt dnf or yum
if [ -n "$(command -v dpkg-query 2>/dev/null)" ]; then
	# Generate array of missing deps
	array_deps_missing=()

	# LinuxGSM requirements
	array_deps_required=( curl wget ca-certificates file bsdmainutils util-linux python bzip2 gzip unzip binutils bc )

	# All servers except ts3 require tmux
	if [ "${gamename}" != "TeamSpeak 3" ]; then
		if [ "$(command -v tmux 2>/dev/null)" ]; then
			tmuxcheck=1 # Added for users compiling tmux from source to bypass check.
		else
			array_deps_required+=( tmux )
		fi
	fi

	# All servers except ts3,mumble,multitheftauto and minecraft servers require libstdc++6 and lib32gcc1
	if [ "${gamename}" != "TeamSpeak 3" ]&&[ "${gamename}" != "Mumble" ]&&[ "${engine}" != "lwjgl2" ]&&[ "${engine}" != "renderware" ]; then
		if [ "${arch}" == "x86_64" ]; then
			array_deps_required+=( lib32gcc1 libstdc++6:i386 )
		else
			array_deps_required+=( libstdc++6:i386 )
		fi
	fi

	# Game Specific requirements

	# Natural Selection 2
	if [ "${gamename}" == "Natural Selection 2" ]; then
		array_deps_required+=( speex libtbb2 )
	# NS2: Combat
	elif [ "${gamename}" == "NS2: Combat" ]; then
		array_deps_required+=( speex:i386 libtbb2 )
	# 7 Days to Die
	elif [ "${gamename}" == "7 Days To Die" ]; then
		array_deps_required+=( telnet expect )
	# No More Room in Hell, Counter-Strike: Source and Garry's Mod
	elif [ "${gamename}" == "No More Room in Hell" ]||[ "${gamename}" == "Counter-Strike: Source" ]||[ "${gamename}" == "Garry's Mod" ]||[ "${gamename}" == "Zombie Panic! Source" ]; then
		if [ "${arch}" == "x86_64" ]; then
			array_deps_required+=( lib32tinfo5 )
		else
			array_deps_required+=( libtinfo5 )
		fi
	# Brainbread 2 ,Don't Starve Together & Team Fortress 2
	elif [ "${gamename}" == "Brainbread 2" ]||[ "${gamename}" == "Don't Starve Together" ]||[ "${gamename}" == "Team Fortress 2" ]; then
		array_deps_required+=( libcurl4-gnutls-dev:i386 )
		if [ "${gamename}" == "Team Fortress 2" ]; then
			array_deps_required+=( libtcmalloc-minimal4:i386 )
		fi
	# Battlefield: 1942
	elif [ "${gamename}" == "Battlefield: 1942" ]; then
		array_deps_required+=( libncurses5:i386 )
	# Call of Duty
	elif [ "${gamename}" == "Call of Duty" ]||[ "${gamename}" == "Call of Duty: United Offensive" ]||[ "${gamename}" == "Call of Duty 2" ]; then
		array_deps_required+=( libstdc++5:i386 )
	# Factorio
	elif [ "${gamename}" == "Factorio" ]; then
		array_deps_required+=( xz-utils )
	# Hurtword/Rust
	elif [ "${gamename}" == "Hurtword" ]||[ "${gamename}" == "Rust" ]; then
		array_deps_required+=( lib32z1 )
	# Minecraft
	elif [ "${shortname}" == "mc" ]; then
		javaversion=$(java -version 2>&1 | grep "version")
		if [ -n "${javaversion}" ]; then
			javacheck=1 # Added for users using Oracle JRE to bypass the check.
		else
			array_deps_required+=( default-jre )
		fi
	# Project Zomboid
	elif [ "${engine}" ==  "projectzomboid" ]; then
		javaversion=$(java -version 2>&1 | grep "version")
		if [ -n "${javaversion}" ]; then
			javacheck=1 # Added for users using Oracle JRE to bypass the check.
			array_deps_required+=( rng-tools )
		else
			array_deps_required+=( default-jre rng-tools )
		fi
	# GoldenEye: Source
	elif [ "${gamename}" ==  "GoldenEye: Source" ]; then
		array_deps_required+=( zlib1g:i386 libldap-2.4-2:i386 )
	# Serious Sam 3: BFE
	elif [ "${gamename}" ==  "Serious Sam 3: BFE" ]; then
		array_deps_required+=( libxrandr2:i386 libglu1-mesa:i386 libxtst6:i386 libusb-1.0-0-dev:i386 libxxf86vm1:i386 libopenal1:i386 libssl1.0.0:i386 libgtk2.0-0:i386 libdbus-glib-1-2:i386 libnm-glib-dev:i386 )
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
	# Eco
	elif [ "${gamename}" == "Eco" ]; then
		array_deps_required+=( mono-complete )
	fi
	fn_deps_email
	fn_check_loop

elif [ -n "$(command -v yum 2>/dev/null)" ]||[ -n "$(command -v dnf 2>/dev/null)" ]; then
	# Generate array of missing deps
	array_deps_missing=()

	# LinuxGSM requirements
	if [ "${distroversion}" == "6" ]; then
		array_deps_required=( curl wget util-linux-ng python file gzip bzip2 unzip binutils bc )
	elif [ "${distroname}" == *"Amazon Linux AMI"* ]; then
        	array_deps_required=( curl wget util-linux python27 file gzip bzip2 unzip binutils bc )
	else
		array_deps_required=( curl wget util-linux python file gzip bzip2 unzip binutils bc )
	fi

	# All servers except ts3 require tmux
	if [ "${gamename}" != "TeamSpeak 3" ]; then
		if [ "$(command -v tmux 2>/dev/null)" ]; then
			tmuxcheck=1 # Added for users compiling tmux from source to bypass check.
		else
			array_deps_required+=( tmux )
		fi
	fi

	# All servers except ts3,mumble,multitheftauto and minecraft servers require glibc.i686 and libstdc++.i686
	if [ "${gamename}" != "TeamSpeak 3" ]&&[ "${gamename}" != "Mumble" ]&&[ "${engine}" != "lwjgl2" ]&&[ "${engine}" != "renderware" ]; then
		if [[ "${distroname}" == *"Amazon Linux AMI"* ]]; then
            		array_deps_required+=( glibc.i686 libstdc++64.i686 )
        	else
			array_deps_required+=( glibc.i686 libstdc++.i686 )
		fi
	fi

	# Game Specific requirements

	# Natural Selection 2
	if [ "${gamename}" == "Natural Selection 2" ]; then
		array_deps_required+=( speex tbb )
	# NS2: Combat
	elif [ "${gamename}" == "NS2: Combat" ]; then
		array_deps_required+=( speex.i686 tbb.i686 )
	# 7 Days to Die
	elif [ "${gamename}" == "7 Days To Die" ]; then
		array_deps_required+=( telnet expect )
	# No More Room in Hell, Counter-Strike: Source and Garry's Mod
	elif [ "${gamename}" == "No More Room in Hell" ]||[ "${gamename}" == "Counter-Strike: Source" ]||[ "${gamename}" == "Garry's Mod" ]||[ "${gamename}" == "Zombie Panic! Source" ]; then
		array_deps_required+=( ncurses-libs.i686 )
	# Brainbread 2, Don't Starve Together & Team Fortress 2
	elif [ "${gamename}" == "Brainbread 2" ]||[ "${gamename}" == "Don't Starve Together" ]||[ "${gamename}" == "Team Fortress 2" ]; then
		array_deps_required+=( libcurl.i686 )
		if [ "${gamename}" == "Team Fortress 2" ]; then
			array_deps_required+=( gperftools-libs.i686 )
		fi
	# Battlefield: 1942
	elif [ "${gamename}" == "Battlefield: 1942" ]; then
		array_deps_required+=( ncurses-libs.i686 )
	# Call of Duty
	elif [ "${gamename}" == "Call of Duty" ]||[ "${gamename}" == "Call of Duty: United Offensive" ]||[ "${gamename}" == "Call of Duty 2" ]; then
		array_deps_required+=( compat-libstdc++-33.i686 )
	# Factorio
	elif [ "${gamename}" == "Factorio" ]; then
		array_deps_required+=( xz )
	elif [ "${gamename}" == "Hurtword" ]||[ "${gamename}" == "Rust" ]; then
		array_deps_required+=( zlib-devel )
	# Minecraft
	elif [ "${shortname}" == "mc" ]; then
		javaversion=$(java -version 2>&1 | grep "version")
		if [ -n "${javaversion}" ]; then
			javacheck=1 # Added for users using Oracle JRE to bypass the check.
			array_deps_required+=( java-1.8.0-openjdk )
		else
			array_deps_required+=( java-1.8.0-openjdk rng-tools )
		fi
	# Project Zomboid
	elif [ "${engine}" ==  "projectzomboid" ]||[ "${engine}" == "lwjgl2" ]; then
		javaversion=$(java -version 2>&1 | grep "version")
		if [ -n "${javaversion}" ]; then
			javacheck=1 # Added for users using Oracle JRE to bypass the check.
		else
			array_deps_required+=( java-1.8.0-openjdk rng-tools )
		fi
	# GoldenEye: Source
	elif [ "${gamename}" ==  "GoldenEye: Source" ]; then
		array_deps_required+=( zlib.i686 openldap.i686 )
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
	# Eco
	elif [ "${gamename}" == "Eco" ]; then
		array_deps_required+=( mono-complete )
	fi
	fn_deps_email
	fn_check_loop
fi
