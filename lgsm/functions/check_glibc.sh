#!/bin/bash
# LinuxGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if the server has the correct Glibc version.

local commandname="CHECK"

info_distro.sh

if [ "${glibc}" == "null" ]; then
	# Glibc is not required.
	:
elif [ "$(printf '%s\n'${glibc}'\n' "${glibcversion}" | sort -V | head -n 1)" != "${glibc}" ]||[ "${glibc}" == "UNKNOWN" ]; then
	fn_print_dots "Glibc"
	fn_print_error_nl "glibc: ${red}glibc distro version ${glibcversion} too old${default}"
	echo -en "\n"
	echo -e "	* glibc required: ${glibc}"
	echo -e "	* glibc installed: ${red}${glibcversion}${default}"
	echo -en "\n"
	fn_print_information "The game server will probably not work. A distro upgrade is required!"
fi
