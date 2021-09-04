#!/bin/bash
# LinuxGSM check_deps.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if required dependencies are installed for LinuxGSM.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_mono_repo(){
	if [ "${monostatus}" != "0" ]; then
		fn_print_dots "Adding Mono repository"
		if [ "${autoinstall}" == "1" ]; then
			sudo -n true > /dev/null 2>&1
		else
			sudo -v > /dev/null 2>&1
		fi
		if [ $? -eq 0 ]; then
			fn_print_info_nl "Automatically adding Mono repository."
			fn_script_log_info "Automatically adding Mono repository."
			echo -en ".\r"
			sleep 1
			echo -en "..\r"
			sleep 1
			echo -en "...\r"
			sleep 1
			echo -en "   \r"
			if [ "${distroid}" == "ubuntu" ]; then
				if [ "${distroversion}" == "18.04" ]; then
					cmd="sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/ubuntu stable-bionic main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt-get update"
					eval "${cmd}"
				elif [ "${distroversion}" == "16.04" ]; then
					cmd="sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;sudo apt-get install apt-transport-https;echo 'deb https://download.mono-project.com/repo/ubuntu stable-xenial main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt-get update"
					eval "${cmd}"
				elif [ "${distroversion}" == "14.04" ]; then
					cmd="sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;sudo apt-get install apt-transport-https;echo 'deb https://download.mono-project.com/repo/ubuntu stable-trusty main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt-get update"
					eval "${cmd}"
				else
					fn_print_warn_nl "Installing Mono repository."
					echo -e "Mono auto install not available for ${distroname}"
					echo -e "	Follow instructions on mono site to install the latest version of Mono."
					echo -e "	https://www.mono-project.com/download/stable/#download-lin"
					monoautoinstall="1"
				fi
			elif [ "${distroid}" == "debian" ]; then
				if [ "${distroversion}" == "10" ]; then
					cmd="sudo apt-get install apt-transport-https dirmngr;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/debian stable-buster main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt-get update"
					eval "${cmd}"
				elif [ "${distroversion}" == "9" ]; then
					cmd="sudo apt-get install apt-transport-https dirmngr;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/debian stable-stretch main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt-get update"
					eval "${cmd}"
				elif [ "${distroversion}" == "8" ]; then
					cmd="sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;sudo apt-get install apt-transport-https;echo 'deb https://download.mono-project.com/repo/debian stable-jessie main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt-get update"
					eval "${cmd}"
				else
					echo -e "Mono auto install not available for ${distroname}"
					echo -e "	Follow instructions on mono site to install the latest version of Mono."
					echo -e "	https://www.mono-project.com/download/stable/#download-lin"
					monoautoinstall="1"
				fi
			elif [ "${distroid}" == "centos" ]; then
				if [ "${distroversion}" == "8" ]; then
					cmd="rpm --import 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF';su -c 'curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo'"
					eval "${cmd}"
				elif [ "${distroversion}" == "7" ]; then
					cmd="rpm --import 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF';su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'"
					eval "${cmd}"
				else
					echo -e "Mono auto install not available for ${distroname}"
					echo -e "	Follow instructions on mono site to install the latest version of Mono."
					echo -e "	https://www.mono-project.com/download/stable/#download-lin"
					monoautoinstall="1"
				fi
			elif [ "${distroid}" == "fedora" ]; then
				cmd="rpm --import 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF'; su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'; dnf update"
				eval "${cmd}"
			else
				echo -e "Mono auto install not available for ${distroname}"
				echo -e "	Follow instructions on mono site to install the latest version of Mono."
				echo -e "	https://www.mono-project.com/download/stable/#download-lin"
				monoautoinstall="1"
			fi
			if [ "${monoautoinstall}" != "1" ]; then
				if [ $? != 0 ]; then
					fn_print_failure_nl "Unable to install Mono repository."
					fn_script_log_fatal "Unable to installMono repository."
					monoautoinstall=1
				else
					fn_print_complete_nl "Installing Mono repository completed."
					fn_script_log_pass "Installing Mono repository completed."
					monoautoinstall=0
				fi
			fi
		else
			fn_print_information_nl "Installing Mono repository."
			echo -e ""
			fn_print_warning_nl "$(whoami) does not have sudo access. Manually install Mono repository."
			fn_script_log_warn "$(whoami) does not have sudo access. Manually install Mono repository."
			echo -e "* Follow instructions on mono site to install the latest version of Mono."
			echo -e "	https://www.mono-project.com/download/stable/#download-lin"
		fi
	fi
}

fn_deps_email(){
	# Adds postfix to required dependencies if email alert is enabled.
	if [ "${emailalert}" == "on" ]; then
		if [ -f /usr/bin/mailx ]; then
			if [ -d /etc/exim4 ]; then
				array_deps_required+=( exim4 )
			elif [ -d /etc/sendmail ]; then
				array_deps_required+=( sendmail )
			elif [ "$(command -v dpkg-query 2>/dev/null)" ]; then
				array_deps_required+=( mailutils postfix )
			elif [ "$(command -v rpm 2>/dev/null)" ]; then
				array_deps_required+=( mailx postfix )
			fi
		else
			if [ "$(command -v dpkg-query 2>/dev/null)" ]; then
				array_deps_required+=( mailutils postfix )
			elif [ "$(command -v rpm 2>/dev/null)" ]; then
				array_deps_required+=( mailx postfix )
			fi
		fi
	fi
}

fn_found_missing_deps(){
	if [ "${#array_deps_missing[*]}" != "0" ]; then

		fn_print_warning_nl "Missing dependencies: ${red}${array_deps_missing[*]}${default}"
		fn_script_log_warn "Missing dependencies: ${array_deps_missing[*]}"
		fn_sleep_time
		if [ "${monostatus}" ]; then
			fn_install_mono_repo
		fi
		if [ "${jqstatus}" ]; then
			fn_print_warning_nl "jq is not available in the ${distroname} repository."
			echo -e "	* https://docs.linuxgsm.com/requirements/jq"
		fi
		if [ "${autoinstall}" == "1" ]; then
			sudo -n true > /dev/null 2>&1
		else
			sudo -v > /dev/null 2>&1
		fi
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
			if [ "$(command -v dpkg-query 2>/dev/null)" ]; then
				cmd="echo steamcmd steam/question select \"I AGREE\" | sudo debconf-set-selections; echo steamcmd steam/license note '' | sudo debconf-set-selections; sudo dpkg --add-architecture i386; sudo apt-get update; sudo apt-get -y install ${array_deps_missing[*]}"
				eval "${cmd}"
			elif [ "$(command -v dnf 2>/dev/null)" ]; then
				cmd="sudo dnf -y install ${array_deps_missing[*]}"
				eval "${cmd}"
			elif [ "$(command -v yum 2>/dev/null)" ]; then
				cmd="sudo yum -y install ${array_deps_missing[*]}"
				eval "${cmd}"
			fi
			if [ $? != 0 ]; then
				fn_print_failure_nl "Unable to install dependencies."
				fn_script_log_fatal "Unable to install dependencies."
				echo -e ""
				fn_print_warning_nl "Manually install dependencies."
				fn_script_log_warn "Manually install dependencies."
				if [ "$(command -v dpkg-query 2>/dev/null)" ]; then
					echo -e "	sudo dpkg --add-architecture i386; sudo apt update; sudo apt install ${array_deps_missing[*]}"
				elif [ "$(command -v dnf 2>/dev/null)" ]; then
					echo -e "	sudo dnf install ${array_deps_missing[*]}"
				elif [ "$(command -v yum 2>/dev/null)" ]; then
					echo -e "	sudo yum install ${array_deps_missing[*]}"
				fi
				if [ "${steamcmdfail}" ]; then
					echo -e ""
					if [ "${commandname}" == "INSTALL" ]; then
						fn_print_failure_nl "Missing dependencies required to run SteamCMD."
						fn_script_log_fatal "Missing dependencies required to run SteamCMD."
						core_exit.sh
					else
						fn_print_error_nl "Missing dependencies required to run SteamCMD."
						fn_script_log_error "Missing dependencies required to run SteamCMD."
					fi
				fi
			else
				fn_print_complete_nl "Install dependencies completed."
				fn_script_log_pass "Install dependencies completed."
			fi
		else
			fn_print_warning_nl "$(whoami) does not have sudo access. Manually install dependencies."
			fn_script_log_warn "$(whoami) does not have sudo access. Manually install dependencies."
			echo -e ""
			if [ "$(command -v dpkg-query 2>/dev/null)" ]; then
				echo -e "sudo dpkg --add-architecture i386; sudo apt update; sudo apt install ${array_deps_missing[*]}"
			elif [ "$(command -v dnf 2>/dev/null)" ]; then
				echo -e "sudo dnf install ${array_deps_missing[*]}"
			elif [ "$(command -v yum 2>/dev/null)" ]; then
				echo -e "sudo yum install ${array_deps_missing[*]}"
			fi
			if [ "${steamcmdfail}" ]; then
				echo -e ""
				if [ "${commandname}" == "INSTALL" ]; then
					fn_print_failure_nl "Missing dependencies required to run SteamCMD."
					fn_script_log_fatal "Missing dependencies required to run SteamCMD."
					core_exit.sh
				else
					fn_print_error_nl "Missing dependencies required to run SteamCMD."
					fn_script_log_error "Missing dependencies required to run SteamCMD."
				fi
			fi
			echo -e ""
		fi
		if [ "${commandname}" == "INSTALL" ]; then
			sleep 5
		fi
	else
		if [ "${commandname}" == "INSTALL" ]; then
			fn_print_information_nl "Required dependencies already installed."
			fn_script_log_info "Required dependencies already installed."
		fi
	fi
}

fn_check_loop(){
	# Loop though required depenencies.
	for deptocheck in ${array_deps_required[*]}; do
		fn_deps_detector
	done

	# user to be informed of any missing dependencies.
	fn_found_missing_deps
}

fn_deps_detector(){
	# Checks if dependency is missing.

	# Java: Added for users using Oracle JRE to bypass check.
	if [ ${deptocheck} == "openjdk-16-jre" ]; then
		javaversion=$(java -version 2>&1 | grep "version")
		if [ "${javaversion}" ]; then
			javacheck=1
		fi
	fi
	if [ "${javacheck}" == "1" ]; then
		# Added for users using Oracle JRE to bypass check.
		depstatus=0
		deptocheck="${javaversion}"
		unset javacheck
	# Mono
	elif [ "${deptocheck}" == "mono-complete" ]; then
		if [ "$(command -v mono 2>/dev/null)" ]&&[ "$(mono --version 2>&1 | grep -Po '(?<=version )\d')" -ge 5 ]; then
			# Mono >= 5.0.0 already installed.
			depstatus=0
		else
			# Mono not installed or installed Mono < 5.0.0.
			depstatus=1
			monostatus=1
		fi
	elif [ "$(command -v dpkg-query 2>/dev/null)" ]; then
		dpkg-query -W -f='${Status}' "${deptocheck}" 2>/dev/null | grep -q -P '^install ok installed'
		depstatus=$?
	elif [ "$(command -v rpm 2>/dev/null)" ]; then
		rpm -q "${deptocheck}" > /dev/null 2>&1
		depstatus=$?
	fi

	if [ "${depstatus}" == "0" ]; then
		# If dependency is found.
		missingdep=0
		if [ "${commandname}" == "INSTALL" ]; then
			echo -e "${green}${deptocheck}${default}"
			fn_sleep_time
		fi
	else
		# If dependency is not found.
		missingdep=1
		if [ "${commandname}" == "INSTALL" ]; then
			echo -e "${red}${deptocheck}${default}"
			fn_sleep_time
		fi
		# Define required dependencies for SteamCMD.
		if [ "${appid}" ]; then
			# lib32gcc1 is now called lib32gcc-s1 in debian 11
			if { [ "${distroid}" == "debian" ]&&[ "${distroversion}" == "11" ]; }||{ [ "${distroid}" == "ubuntu" ]&&[ "${distroversion}" == "20.10" ]; } || { [ "${distroid}" == "pop" ]&&[ "${distroversion}" == "20.10" ]; }; then
				if [ "${deptocheck}" ==  "glibc.i686" ]||[ "${deptocheck}" ==  "libstdc++64.i686" ]||[ "${deptocheck}" ==  "lib32gcc-s1" ]||[ "${deptocheck}" ==  "lib32stdc++6" ]; then
					steamcmdfail=1
				fi
			else
				if [ "${deptocheck}" ==  "glibc.i686" ]||[ "${deptocheck}" ==  "libstdc++64.i686" ]||[ "${deptocheck}" ==  "lib32gcc1" ]||[ "${deptocheck}" ==  "lib32stdc++6" ]; then
					steamcmdfail=1
				fi
			fi
		fi
	fi

	# Missing dependencies are added to array_deps_missing.
	if [ "${missingdep}" == "1" ]; then
		array_deps_missing+=("${deptocheck}")
	fi
}

info_distro.sh

if [ ! -f "${tmpdir}/dependency-no-check.tmp" ]&&[ ! -f "${datadir}/${distroid}-${distroversion}.csv" ]; then
	# Check that the disto dependency csv file exists and if it does download it.
	fn_check_file_github "lgsm/data" "${distroid}-${distroversion}.csv"
fi

# If the file successfully downloaded run the dependency check.
if [ -n "${checkflag}" ]&&[ "${checkflag}" == "0" ]; then
	dependencyinstall=$(awk -F, '$1=="install" {$1=""; print $0}' "${datadir}/${distroid}-${distroversion}.csv")
	dependencyall=$(awk -F, '$1=="all" {$1=""; print $0}' "${datadir}/${distroid}-${distroversion}.csv")
	dependencyshortname=$(awk -v shortname="$shortname" -F, '$1==shortname {$1=""; print $0}'  "${datadir}/${distroid}-${distroversion}.csv")

	# Generate array of missing deps.
	array_deps_missing=()
	array_deps_required=(${dependencyall} ${dependencyshortname})
	fn_check_loop
# Warn the user that dependency checking is unavailable for their distro.
elif [ "${commandname}" == "INSTALL" ]||[ -n "${checkflag}" ]&&[ "${checkflag}" != "0" ]; then
	fn_print_warning_nl "LinuxGSM dependency checking currently unavailable for ${distroname}."
	# Prevent future dependency checking if unavailable for the distro.
	echo "${version}" > "${tmpdir}/dependency-no-check.tmp"
elif 	[ -f "${tmpdir}/dependency-no-check.tmp" ]; then
	# Allow LinuxGSM to try a dependency check if LinuxGSM has been recently updated.
	nocheckversion=$(cat "${tmpdir}/dependency-no-check.tmp" )
	if [ "${version}" != "${nocheckversion}" ]; then
		rm -f "${tmpdir:?}/dependency-no-check.tmp"
	fi
fi
