#!/bin/bash
# LinuxGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if the server has the correct Glibc version or a fix available.

local commandname="CHECK"

info_glibc.sh
info_distro.sh

if [ "${glibcrequired}" == "NOT REQUIRED" ]; then
	:
elif [ "$(printf '%s\n'${glibcrequired}'\n' "${glibcversion}" | sort -V | head -n 1)" != "${glibcrequired}" ]||[ "${glibcrequired}" == "UNKNOWN" ]; then
	fn_print_dots "Glibc"
	fn_print_error_nl "glibc: ${red}glibc distro version ${glibcversion} too old${default}"
	echo -en "\n"
	echo -e "	* glibc required: ${glibcrequired}"
	echo -e "	* glibc installed: ${red}${glibcversion}${default}"
	echo -en "\n"
	fn_print_information "The game server will probably not work. A distro upgrade is required!"
fi
