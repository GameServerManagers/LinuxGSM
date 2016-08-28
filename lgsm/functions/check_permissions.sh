#!/bin/bash
# LGSM check_permissions.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Checks ownership & permissions of scripts, files and folders.

local commandname="CHECK"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_check_ownership(){
	if [ -f "${rootdir}/${selfname}" ]; then
		if [ $(find "${rootdir}/${selfname}" -not -user $(whoami)|wc -l) -ne "0" ]; then
			selfownissue=1
		fi
	fi
	if [ -d "${functionsdir}" ]; then
		if [ $(find "${functionsdir}" -not -user $(whoami)|wc -l) -ne "0" ]; then
			funcownissue=1
		fi
	fi
	if [ -d "${filesdir}" ]; then
		if [ $(find "${filesdir}" -not -user $(whoami)|wc -l) -ne "0" ]; then
			filesownissue=1
		fi
	fi
	if [ "${selfownissue}" == "1" ]||[ "${funcownissue}" == "1" ]||[ "${filesownissue}" == "1" ]; then
		fn_print_fail_nl "Ownership issues found"
		fn_script_log_fatal "Ownership issues found"
		fn_print_information_nl "The current user ($(whoami)) does not have ownership of the following files:"
		fn_script_log_info "The current user ($(whoami)) does not have ownership of the following files:"
		{
			echo -e "User\tGroup\tFile\n"
			if [ "${selfownissue}" == "1" ]; then
				find "${rootdir}/${selfname}" -not -user $(whoami) -printf "%u\t\t%g\t%p\n"
			fi
			if [ "${funcownissue}" == "1" ]; then
				find "${functionsdir}" -not -user $(whoami) -printf "%u\t\t%g\t%p\n"
			fi
			if [ "${filesownissue}" == "1"  ]; then
				find "${filesdir}" -not -user $(whoami) -printf "%u\t\t%g\t%p\n"
			fi

		} | column -s $'\t' -t | tee -a "${scriptlog}"
		echo ""
		fn_print_information_nl "For more information, please see https://github.com/GameServerManagers/LinuxGSM/wiki/FAQ#-fail--starting-game-server-permissions-issues-found"
		fn_script_log "For more information, please see https://github.com/GameServerManagers/LinuxGSM/wiki/FAQ#-fail--starting-game-server-permissions-issues-found"
		core_exit.sh
	fi
}

fn_check_permissions(){
	if [ -d "${functionsdir}" ]; then
		if [ $(find "${functionsdir}" -type f -not -executable|wc -l) -ne "0" ]; then
			fn_print_fail_nl "Permissions issues found"
			fn_script_log_fatal "Permissions issues found"
			fn_print_information_nl "The following files are not executable:"
			fn_script_log_info "The following files are not executable:"
			{
				echo -e "File\n"
				find "${functionsdir}" -type f -not -executable -printf "%p\n"
			} | column -s $'\t' -t | tee -a "${scriptlog}"
			core_exit.sh
		fi
	fi

	# Check rootdir permissions
	if [ -n "${rootdir}" ]; then
		# Get permission numbers on folder under the form 775
		rootdirperm="$(stat -c %a "${rootdir}")"
		# Grab the first and second digit for user and group permission
		userrootdirperm="${rootdirperm:0:1}"
		grouprootdirperm="${rootdirperm:1:1}"
		if [ "${userrootdirperm}" != "7" ] && [ "${grouprootdirperm}" != "7" ]; then
			fn_print_fail_nl "Permissions issues found"
			fn_script_log_fatal "Permissions issues found"
			fn_print_information_nl "The following directorys does not have the correct permissions:"
			fn_script_log_info "The following directorys does not have the correct permissions:"
			ls -l "${rootdir}"
			core_exit.sh
		fi
	fi
}

fn_check_ownership
fn_check_permissions
