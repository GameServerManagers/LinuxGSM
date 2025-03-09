#!/bin/bash
# LinuxGSM check_deps.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks and installs missing dependencies.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_dotnet_repo() {
	if [ "${distroid}" == "ubuntu" ]; then
		# if package dotnet-runtime-7.0 is unavailable in ubuntu repos, add the microsoft repo.
		if ! apt-cache show dotnet-runtime-7.0 > /dev/null 2>&1; then
			fn_fetch_file "https://packages.microsoft.com/config/ubuntu/${distroversion}/packages-microsoft-prod.deb" "" "" "" "/tmp" "packages-microsoft-prod.deb" "" "" "" ""
			sudo dpkg -i /tmp/packages-microsoft-prod.deb
		fi
	elif [ "${distroid}" == "debian" ]; then
		fn_fetch_file "https://packages.microsoft.com/config/debian/${distroversion}/packages-microsoft-prod.deb" "" "" "" "/tmp" "packages-microsoft-prod.deb" "" "" "" ""
		sudo dpkg -i /tmp/packages-microsoft-prod.deb
	fi
}

fn_install_mono_repo() {
	if [ "${autodepinstall}" == "0" ]; then
		fn_print_information_nl "Automatically adding Mono repository."
		fn_script_log_info "Automatically adding Mono repository."
		echo -en ".\r"
		fn_sleep_time_1
		echo -en "..\r"
		fn_sleep_time_1
		echo -en "...\r"
		fn_sleep_time_1
		echo -en "   \r"
		if [ "${distroid}" == "ubuntu" ]; then
			if [ "${distroversion}" == "22.04" ]; then
				cmd="sudo apt-get install gnupg ca-certificates;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/ubuntu stable-jammy main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			elif [ "${distroversion}" == "20.04" ]; then
				cmd="sudo apt-get install gnupg ca-certificates;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/ubuntu stable-focal main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			elif [ "${distroversion}" == "18.04" ]; then
				cmd="sudo apt-get install gnupg ca-certificates;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/ubuntu stable-bionic main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			elif [ "${distroversion}" == "16.04" ]; then
				cmd="sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;sudo apt install apt-transport-https ca-certificates;echo 'deb https://download.mono-project.com/repo/ubuntu stable-xenial main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			else
				monoautoinstall="1"
			fi
		elif [ "${distroid}" == "debian" ]; then
			if [ "${distroversion}" == "12" ]; then
				cmd="sudo apt-get install apt-transport-https dirmngr gnupg ca-certificates;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/debian stable-bookworm main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			elif [ "${distroversion}" == "11" ]; then
				cmd="sudo apt-get install apt-transport-https dirmngr gnupg ca-certificates;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/debian stable-bullseye main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			elif [ "${distroversion}" == "10" ]; then
				cmd="sudo apt-get install apt-transport-https dirmngr gnupg ca-certificates;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/debian stable-buster main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			elif [ "${distroversion}" == "9" ]; then
				cmd="sudo apt-get install apt-transport-https dirmngr gnupg ca-certificates;sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF;echo 'deb https://download.mono-project.com/repo/debian stable-stretch main' | sudo tee /etc/apt/sources.list.d/mono-official-stable.list;sudo apt update"
			else
				monoautoinstall="1"
			fi
		elif [ "${distroid}" == "centos" ] || [ "${distroid}" == "almalinux" ] || [ "${distroid}" == "rocky" ]; then
			if [ "${distroversion}" == "8" ]; then
				cmd="sudo rpmkeys --import 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF';su -c 'curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo'"
			elif [ "${distroversion}" == "7" ]; then
				cmd="sudo rpmkeys --import 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF';su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'"
			else
				monoautoinstall="1"
			fi
		elif [ "${distroid}" == "fedora" ]; then
			if [ "${distroversion}" -ge "29" ]; then
				cmd="sudo rpm --import 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF';su -c 'curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo';dnf update"
			else
				cmd="sudo rpm --import 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF';su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo';dnf update"
			fi
		else
			monoautoinstall="1"
		fi

		# Run the mono repo install.
		eval "${cmd}"

		# Did Mono repo install correctly?
		if [ "${monoautoinstall}" != "1" ]; then
			exitcode=$?
			if [ "${exitcode}" -ne 0 ]; then
				fn_print_failure_nl "Unable to install Mono repository."
				fn_script_log_fail "Unable to install Mono repository."
			else
				fn_print_success_nl "Installing Mono repository completed."
				fn_script_log_pass "Installing Mono repository completed."
			fi
		fi

		# Mono can not be auto installed with this distro.
		if [ "${monoautoinstall}" == "1" ]; then
			fn_print_warning_nl "Mono auto install not available for ${distroname}."
			echo -e "Follow instructions on Mono website to install."
			echo -e "https://www.mono-project.com/download/stable/#download-lin"
			fn_script_log_warn "Unable to install Mono repository. Mono auto install not available for ${distroname}."
		fi

	else
		fn_print_information_nl "Installing Mono repository."
		fn_print_warning_nl "$(whoami) does not have sudo access."
		echo -e "Follow instructions on Mono website to install."
		echo -e "https://www.mono-project.com/download/stable/#download-lin"
		fn_script_log_warn "Unable to install Mono repository. $(whoami) does not have sudo access."
	fi
}

fn_deps_email() {
	# Adds postfix to required dependencies if email alert is enabled.
	if [ "${emailalert}" == "on" ]; then
		if [ -f /usr/bin/mailx ]; then
			if [ -d /etc/exim4 ]; then
				array_deps_required+=(exim4)
			elif [ -d /etc/sendmail ]; then
				array_deps_required+=(sendmail)
			elif [ "$(command -v yum 2> /dev/null)" ] || [ "$(command -v dnf 2> /dev/null)" ]; then
				array_deps_required+=(s-nail postfix)
			elif [ "$(command -v apt 2> /dev/null)" ]; then
				array_deps_required+=(mailutils postfix)
			fi
		else
			if [ "$(command -v yum 2> /dev/null)" ] || [ "$(command -v dnf 2> /dev/null)" ]; then
				array_deps_required+=(s-nail postfix)
			elif [ "$(command -v apt 2> /dev/null)" ]; then
				array_deps_required+=(mailutils postfix)
			fi
		fi
	fi
}

fn_install_missing_deps() {
	# If any dependencies are not installed.
	if [ "${#array_deps_missing[*]}" != "0" ]; then
		if [ "${commandname}" == "INSTALL" ]; then
			fn_print_warning_nl "Missing dependencies: ${red}${array_deps_missing[*]}${default}"
			fn_script_log_warn "Missing dependencies: ${array_deps_missing[*]}"
		else
			fn_print_dots "Missing dependencies"
			fn_print_warn "Missing dependencies: ${red}${array_deps_missing[*]}${default}"
			fn_script_log_warn "Missing dependencies: ${array_deps_missing[*]}"
		fi

		# Attempt automatic dependency installation
		if [ "${autoinstall}" == "1" ]; then
			sudo -n true > /dev/null 2>&1
		else
			sudo -v > /dev/null 2>&1
		fi
		autodepinstall="$?"

		if [ "${monoinstalled}" == "false" ]; then
			fn_install_mono_repo
		fi

		if [ "${dotnetinstalled}" == "false" ]; then
			fn_install_dotnet_repo
		fi

		if [ "${commandname}" == "INSTALL" ]; then
			if [ "${autodepinstall}" == "0" ]; then
				fn_print_information_nl "$(whoami) has sudo access."
				fn_script_log_info "$(whoami) has sudo access."
			else
				fn_print_warning_nl "$(whoami) does not have sudo access. Manually install dependencies or run ./${selfname} install as root."
				fn_script_log_warn "$(whoami) does not have sudo access. Manually install dependencies or run ./${selfname} install as root."
			fi
		fi

		# Add sudo dpkg --add-architecture i386 if using i386 packages.
		if [ "$(command -v apt 2> /dev/null)" ]; then
			if printf '%s\n' "${array_deps_required[@]}" | grep -q -P 'i386'; then
				i386installcommand="sudo dpkg --add-architecture i386; "
			fi
		fi

		# If automatic dependency install is available
		if [ "${autodepinstall}" == "0" ]; then
			fn_print_information_nl "Automatically installing missing dependencies."
			fn_script_log_info "Automatically installing missing dependencies."
			echo -en ".\r"
			fn_sleep_time_1
			echo -en "..\r"
			fn_sleep_time_1
			echo -en "...\r"
			fn_sleep_time_1
			echo -en "   \r"
			if [ "$(command -v apt 2> /dev/null)" ]; then
				cmd="echo steamcmd steam/question select \"I AGREE\" | sudo debconf-set-selections; echo steamcmd steam/license note '' | sudo debconf-set-selections; ${i386installcommand}sudo apt-get update; sudo apt-get -y install ${array_deps_missing[*]}"
				eval "${cmd}"
			elif [ "$(command -v dnf 2> /dev/null)" ]; then
				cmd="sudo dnf -y install ${array_deps_missing[*]}"
				eval "${cmd}"
			elif [ "$(command -v yum 2> /dev/null)" ]; then
				cmd="sudo yum -y install ${array_deps_missing[*]}"
				eval "${cmd}"
			fi
			autodepinstall="$?"

			# If auto install passes, remove steamcmd install failure and set exit code to 0.
			if [ "${autodepinstall}" == "0" ]; then
				unset steamcmdfail
				exitcode=0
			fi
		fi

		# If automatic dependency install is unavailable.
		if [ "${autodepinstall}" != "0" ]; then
			if [ "$(command -v apt 2> /dev/null)" ]; then
				echo -e " Run: '${green}${i386installcommand}sudo apt update; sudo apt install ${array_deps_missing[*]}${default}' as root to install missing dependencies."
			elif [ "$(command -v dnf 2> /dev/null)" ]; then
				echo -e " Run: '${green}sudo dnf install ${array_deps_missing[*]}${default}' as root to install missing dependencies."
			elif [ "$(command -v yum 2> /dev/null)" ]; then
				echo -e " Run: '${green}sudo yum install ${array_deps_missing[*]}${default}' as root to install missing dependencies."
			fi
		fi

		if [ "${steamcmdfail}" ]; then
			if [ "${commandname}" == "INSTALL" ]; then
				fn_print_failure_nl "Missing dependencies required to run SteamCMD."
				fn_script_log_fail "Missing dependencies required to run SteamCMD."
				core_exit.sh
			else
				fn_print_error_nl "Missing dependencies required to run SteamCMD."
				fn_script_log_error "Missing dependencies required to run SteamCMD."
			fi
		fi

	else
		if [ "${commandname}" == "INSTALL" ]; then
			fn_print_skip2_nl "Required dependencies already installed."
			fn_script_log_info "Required dependencies already installed."
		fi
	fi
}

fn_check_loop() {
	# Loop though required depenencies checking if they are installed.
	for deptocheck in "${array_deps_required[@]}"; do
		fn_deps_detector
	done

	# user will be informed of any missing dependencies.
	fn_install_missing_deps
}

# Checks if dependency is installed or not.
fn_deps_detector() {
	## Check.
	# SteamCMD: Will be removed from required array if no appid is present or non-free repo is not available.
	# This will cause SteamCMD to be installed using tar.
	if [ "${deptocheck}" == "libsdl2-2.0-0:i386" ] && [ -z "${appid}" ]; then
		array_deps_required=("${array_deps_required[@]/libsdl2-2.0-0:i386/}")
		steamcmdstatus=1
		return
	elif [ "${deptocheck}" == "steamcmd" ] && [ -z "${appid}" ]; then
		array_deps_required=("${array_deps_required[@]/steamcmd/}")
		steamcmdstatus=1
		return
	elif [ "${deptocheck}" == "steamcmd" ] && [ "${distroid}" == "debian" ] && ! grep -qE '[^deb]+non-free([^-]|$)' /etc/apt/sources.list; then
		array_deps_required=("${array_deps_required[@]/steamcmd/}")
		steamcmdstatus=1
		return
	# Java: Added for users using Oracle JRE to bypass check.
	elif [[ ${deptocheck} == "openjdk"* ]] || [[ ${deptocheck} == "java"* ]]; then
		# Is java already installed?
		if [ -n "${javaversion}" ]; then
			# Added for users using Oracle JRE to bypass check.
			depstatus=0
			deptocheck="${javaversion}"
		else
			depstatus=1
		fi
	# Mono: A Mono repo needs to be installed.
	elif [ "${deptocheck}" == "mono-complete" ]; then
		if [ -n "${monoversion}" ] && [ "${monoversion}" -ge "5" ]; then
			# Mono >= 5.0.0 already installed.
			depstatus=0
			monoinstalled=true
		else
			# Mono not installed or installed Mono < 5.0.0.
			depstatus=1
			monoinstalled=false
		fi
	# .NET Core: A .NET Core repo needs to be installed.
	elif [ "${deptocheck}" == "dotnet-runtime-7.0" ]; then
		# .NET is not installed.
		if dotnet --list-runtimes | grep -q "Microsoft.NETCore.App 7.0"; then
			depstatus=0
			dotnetinstalled=true
		else
			depstatus=1
			dotnetinstalled=false
		fi
	elif [ "$(command -v apt 2> /dev/null)" ]; then
		dpkg-query -W -f='${Status}' "${deptocheck}" 2> /dev/null | grep -q -P '^install ok installed'
		depstatus=$?
	elif [ "$(command -v dnf 2> /dev/null)" ]; then
		dnf list installed "${deptocheck}" > /dev/null 2>&1
		depstatus=$?
	elif [ "$(command -v rpm 2> /dev/null)" ]; then
		rpm -q "${deptocheck}" > /dev/null 2>&1
		depstatus=$?
	fi

	# Outcome of Check.
	if [ "${steamcmdstatus}" == "1" ]; then
		# If SteamCMD is not available in repo dont check for it.
		unset steamcmdstatus
	elif [ "${depstatus}" == "0" ]; then
		# If dependency is found.
		missingdep=0
		if [ "${commandname}" == "INSTALL" ]; then
			echo -e "${green}${deptocheck}${default}"
			fn_sleep_time
		fi
	elif [ "${depstatus}" != "0" ]; then
		# If dependency is not found.
		missingdep=1
		if [ "${commandname}" == "INSTALL" ]; then
			echo -e "${red}${deptocheck}${default}"
			fn_sleep_time
		fi
		# If SteamCMD requirements are not met install will fail.
		if [ -n "${appid}" ]; then
			for steamcmddeptocheck in "${array_deps_required_steamcmd[@]}"; do
				if [ "${deptocheck}" != "steamcmd" ] && [ "${deptocheck}" == "${steamcmddeptocheck}" ]; then
					steamcmdfail=1
				fi
			done
		fi
	fi
	unset depstatus

	# Missing dependencies are added to array_deps_missing.
	if [ "${missingdep}" == "1" ]; then
		array_deps_missing+=("${deptocheck}")
	fi
}

if [ "${commandname}" == "INSTALL" ]; then
	if [ "$(whoami)" == "root" ]; then
		echo -e ""
		echo -e "${bold}${lightyellow}Checking ${gamename} Dependencies as root${default}"
		fn_messages_separator
		fn_print_information_nl "Checking any missing dependencies for ${gamename} server only."
		fn_print_information_nl "This will NOT install a ${gamename} server."
	else
		echo -e ""
		echo -e "${bold}${lightyellow}Checking ${gamename} Dependencies${default}"
		fn_messages_separator
	fi
fi

# Will warn user if their distro is no longer supported by the vendor.
if [ -n "${distrosupport}" ]; then
	if [ "${distrosupport}" == "unsupported" ]; then
		fn_print_warning_nl "${distroname} is no longer supported by the vendor or LinuxGSM. Upgrading is recommended."
		fn_script_log_warn "${distroname} is no longer supported by the vendor or LinuxGSM. Upgrading is recommended."
	fi
fi

info_distro.sh

if [ ! -f "${tmpdir}/dependency-no-check.tmp" ] && [ ! -f "${datadir}/${distroid}-${distroversioncsv}.csv" ]; then
	# Check that the distro dependency csv file exists.
	fn_check_file_github "lgsm/data" "${distroid}-${distroversioncsv}.csv"
	if [ -n "${checkflag}" ] && [ "${checkflag}" == "0" ]; then
		fn_fetch_file_github "lgsm/data" "${distroid}-${distroversioncsv}.csv" "${datadir}" "chmodx" "norun" "noforce" "nohash"
	fi
fi

# If the file successfully downloaded run the dependency check.
if [ -f "${datadir}/${distroid}-${distroversioncsv}.csv" ]; then
	depall=$(awk -F, '$1=="all" {$1=""; print $0}' "${datadir}/${distroid}-${distroversioncsv}.csv")
	depsteamcmd=$(awk -F, '$1=="steamcmd" {$1=""; print $0}' "${datadir}/${distroid}-${distroversioncsv}.csv")
	depshortname=$(awk -v shortname="${shortname}" -F, '$1==shortname {$1=""; print $0}' "${datadir}/${distroid}-${distroversioncsv}.csv")

	# Generate array of missing deps.
	array_deps_missing=()

	array_deps_required=("${depall} ${depsteamcmd} ${depshortname}")
	array_deps_required_steamcmd=("${depsteamcmd}")
	fn_deps_email
	# Unique sort dependency array.
	IFS=" " read -r -a array_deps_required <<< "$(echo "${array_deps_required[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"

	fn_check_loop
# Warn the user that dependency checking is unavailable for their distro.
elif [ "${commandname}" == "INSTALL" ] || [ -n "${checkflag}" ] && [ "${checkflag}" != "0" ]; then
	fn_print_warning_nl "LinuxGSM dependency checking currently unavailable for ${distroname}."
	# Prevent future dependency checking if unavailable for the distro.
	echo "${version}" > "${tmpdir}/dependency-no-check.tmp"
elif [ -f "${tmpdir}/dependency-no-check.tmp" ]; then
	# Allow LinuxGSM to try a dependency check if LinuxGSM has been recently updated.
	nocheckversion=$(cat "${tmpdir}/dependency-no-check.tmp")
	if [ "${version}" != "${nocheckversion}" ]; then
		rm -f "${tmpdir:?}/dependency-no-check.tmp"
	fi
fi
