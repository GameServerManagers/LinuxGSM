#!/bin/bash
# LGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="020116"

# Description: Checks if server has correct glibc or has a fix available.

info_glibc.sh
info_distro.sh

if [ "$(printf '%s\n'${glibcrequired}'\n' ${glibcversion} | sort -V | head -n 1)" != "${glibcrequired}" ]; then
	if [ "${glibcfix}" == "yes" ]; then 
		fn_print_info_nl "Glibc fix: Using Glibc fix"
		echo "	* glibc required: ${glibcrequired}"
		echo "	* glibc installed: ${glibcversion}"
		export LD_LIBRARY_PATH=:"${libdir}"
	else
		fn_print_warn_nl "Glibc fix: No Glibc fix available!"
		echo -en "\n"
		echo "	* glibc required: ${glibcrequired}"
		echo "	* glibc installed: ${glibcversion}"
		echo -en "\n"
		fn_print_infomation "The game server will probably not work. A distro upgrade is required!"
	fi
	echo -en "\n"
fi