#!/bin/bash
# LinuxGSM check_glibc.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks if the server has the correct Glibc version.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_distro.sh

if [ "${glibc}" == "null" ]; then
	# Glibc is not required.
	:
elif [ -z "${glibc}" ]; then
	fn_print_dots "Checking glibc"
	fn_print_error_nl "Checking glibc: requirement unknown"
	fn_script_log_error "Checking glibc: requirement unknown"
	fn_sleep_time_5
elif [ "$(printf '%s\n'${glibc}'\n' "${glibcversion}" | sort -V | head -n 1)" != "${glibc}" ]; then
	fn_print_dots "Checking glibc"
	fn_print_error_nl "Checking glibc: requirements not met"
	fn_script_log_error "Checking glibc: requirements not met"
	echo -en "\n"
	echo -e "	* glibc required: ${glibc}"
	echo -e "	* glibc installed: ${red}${glibcversion}${default}"
	echo -en "\n"
	fn_print_information_nl "Distro upgrade is required"
	fn_script_log_info "Distro upgrade is required"
	fn_sleep_time_5
fi
