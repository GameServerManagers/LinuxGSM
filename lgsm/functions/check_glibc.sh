#!/bin/bash
# LinuxGSM check_glibc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks if the server has the correct Glibc version.

local modulename="CHECK"

info_distro.sh

if [ "${glibc}" == "null" ]; then
	# Glibc is not required.
	:
elif [ -z "${glibc}" ]; then
	fn_print_dots "glibc"
	fn_print_error_nl "glibc requirement unknown"
	fn_script_log_error "glibc requirement unknown"
elif [ "$(printf '%s\n'${glibc}'\n' "${glibcversion}" | sort -V | head -n 1)" != "${glibc}" ]; then
	fn_print_dots "glibc"
	fn_print_error_nl "glibc requirements not met"
	fn_script_log_error "glibc requirements not met"
	echo -en "\n"
	echo -e "	* glibc required: ${glibc}"
	echo -e "	* glibc installed: ${red}${glibcversion}${default}"
	echo -en "\n"
	fn_print_information_nl "distro upgrade is required"
	fn_script_log_info "distro upgrade is required"
fi
