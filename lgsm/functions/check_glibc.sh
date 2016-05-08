#!/bin/bash
# LGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="020116"

# Description: Checks if server has correct glibc or has a fix available.

info_glibc.sh

glibcversion="$(ldd --version | sed -n '1s/.* //p')"
if [ "$(printf '%s\n${glibcrequired}\n' ${glibcversion} | sort -V | head -n 1)" == "${glibcrequired}" ]; then
	if [ "${glibcfix}" != "yes" ]; then 
		fn_print_warn_nl "Glibc fix: No Glibc fix available!"
		echo -en "\n"
		echo "	* glibc required: $glibcrequired"
		echo "	* glibc installed: $glibcversion"
		echo -en "\n"
		fn_print_infomation "The game server will probably not work. A distro upgrade is required!"
		sleep 5
	fi
	echo -en "\n"
fi