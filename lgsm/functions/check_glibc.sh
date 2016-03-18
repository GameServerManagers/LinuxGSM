#!/bin/bash
# LGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="020116"

# Description: Checks if server has correct glibc or has a fix available.

info_glibc.sh

glibc_version="$(ldd --version | sed -n '1s/.* //p')"
if [ "$(printf '%s\n$glibc_required\n' $glibc_version | sort -V | head -n 1)" != "${glibc_required}" ]; then
	if [ "${glibcfix}" != "yes" ]; then 
		fn_print_warn_nl "Glibc fix: No Glibc fix available!"
		echo -en "\n"
		echo "	* glibc required: $glibc_required"
		echo "	* glibc installed: $glibc_version"
		echo -en "\n"
		fn_print_infomation "The game server will probably not work. A distro upgrade is required!"
		sleep 5
	fi
	echo -en "\n"
fi