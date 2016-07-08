#!/bin/bash
# LGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Checks if server has correct glibc or has a fix available.

local commandnane="CHECK"
local commandaction="Checking"
# Cannot have selfname as breaks the function.
#local selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

info_glibc.sh
info_distro.sh

if [ "${glibcrequired}" == "NOT REQUIRED" ]; then
	:
elif [ "${glibcrequired}" == "UNKNOWN" ]; then
		fn_print_error_nl "Glibc fix: ${red}${glibcrequired}${default}"
		echo -e "	* glibc required: ${red}${glibcrequired}${default}"
		echo -e "	* glibc installed: ${glibcversion}"
elif [ "$(printf '%s\n'${glibcrequired}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibcrequired}" ]; then
	if [ "${glibcfix}" == "yes" ]; then
		if [ "${selfname}" != "command_install.sh" ]; then
			fn_print_info_nl "Glibc fix: ${green}Using Glibc fix${default}"
			echo -e "	* glibc required: ${red}${glibcrequired}${default}"
			echo -e "	* glibc installed: ${glibcversion}"
			fix_glibc.sh
		fi
	else
		fn_print_error_nl "Glibc fix: ${red}No Glibc fix available!${default}"
		echo -en "\n"
		echo -e "	* glibc required: ${glibcrequired}"
		echo -e "	* glibc installed: ${red}${glibcversion}${default}"
		echo -en "\n"
		fn_print_infomation "The game server will probably not work. A distro upgrade is required!"
		sleep 5
	fi
fi