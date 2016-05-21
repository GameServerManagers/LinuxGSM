#!/bin/bash
# LGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Checks if server has correct glibc or has a fix available.

info_glibc.sh
info_distro.sh

if [ "${glibcrequired}" == "NOT REQUIRED" ]; then
	:
elif [ "${glibcrequired}" == "UNKNOWN" ]; then
		fn_print_info_nl "Glibc fix: \e[0;31m${glibcrequired}\e[0m"
		echo -e "	* glibc required: \e[0;31m${glibcrequired}\e[0m"
		echo -e "	* glibc installed: ${glibcversion}"
elif [ "$(printf '%s\n'${glibcrequired}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibcrequired}" ]; then
	if [ "${glibcfix}" == "yes" ]; then
		if [ "${function_selfname}" != "command_install.sh" ]; then
			fn_print_info_nl "Glibc fix: \e[0;32mUsing Glibc fix\e[0m"
			echo -e "	* glibc required: \e[0;31m${glibcrequired}\e[0m"
			echo -e "	* glibc installed: ${glibcversion}"
			fix_glibc.sh
		fi
	else
		fn_print_warn_nl "Glibc fix: \e[0;31mNo Glibc fix available!\e[0m"
		echo -en "\n"
		echo -e "	* glibc required: ${glibcrequired}"
		echo -e "	* glibc installed: \e[0;31m${glibcversion}\e[0m"
		echo -en "\n"
		fn_print_infomation "The game server will probably not work. A distro upgrade is required!"
		sleep 5
	fi
fi