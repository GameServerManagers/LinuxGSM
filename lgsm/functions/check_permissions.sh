#!/bin/bash
# LGSM check_permissions.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Checks ownership & permissions of scripts, files and directories.

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
		fn_print_information_nl "For more information, please see https://github.com/GameServerManagers/LinuxGSM/wiki/FAQ#-fail--starting-game-server-ownership-issues-found"
		fn_script_log "For more information, please see https://github.com/GameServerManagers/LinuxGSM/wiki/FAQ#-fail--starting-game-server-ownership-issues-found"
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
		# Get permission numbers on directory under the form 775
		rootdirperm="$(stat -c %a "${rootdir}")"
		# Grab the first and second digit for user and group permission
		userrootdirperm="${rootdirperm:0:1}"
		grouprootdirperm="${rootdirperm:1:1}"
		if [ "${userrootdirperm}" != "7" ] && [ "${grouprootdirperm}" != "7" ]; then
			fn_print_fail_nl "Permissions issues found"
			fn_script_log_fatal "Permissions issues found"
			fn_print_information_nl "The following directory does not have the correct permissions:"
			fn_script_log_info "The following directory does not have the correct permissions:"
			fn_script_log_info "${rootdir}"
			ls -l "${rootdir}"
			core_exit.sh
		fi
	fi
	# Check if executable is executable and attempt to fix it
	# First get executable name
	execname="$(basename "${executable}")"
	if [ -f "${executabledir}/${execname}" ]; then
		# Get permission numbers on file under the form 775
		execperm="$(stat -c %a "${executabledir}/${execname}")"
		# Grab the first and second digit for user and group permission
		userexecperm="${execperm:0:1}"
		groupexecperm="${execperm:1:1}"
		# Check for invalid user permission
		if [ "${userexecperm}" == "0" ] || [ "${userexecperm}" == "2" ] || [ "${userexecperm}" == "4" ]  || [ "${userexecperm}" == "6" ]; then
			# If user permission is invalid, then check for invalid group permissions
			if [ "${groupexecperm}" == "0" ] || [ "${groupexecperm}" == "2" ] || [ "${groupexecperm}" == "4" ]  || [ "${groupexecperm}" == "6" ]; then
				# If permission issues are found
				fn_print_warn_nl "Permissions issue found"
				fn_script_log_warn "Permissions issue found"
				fn_print_information_nl "The following file is not executable:"
				ls -l "${executabledir}/${execname}"
				fn_script_log_info "The following file is not executable:"
				fn_script_log_info "${executabledir}/${execname}"
				fn_print_information_nl "Applying chmod u+x,g+x ${executabledir}/${execname}"
				fn_script_log_info "Applying chmod u+x,g+x ${execperm}"
				# Make the executable executable
				chmod u+x,g+x "${executabledir}/${execname}"
				# Second check to see if it's been successfully applied
				# Get permission numbers on file under the form 775
				execperm="$(stat -c %a "${executabledir}/${execname}")"
				# Grab the first and second digit for user and group permission
				userexecperm="${execperm:0:1}"
				groupexecperm="${execperm:1:1}"
				if [ "${userexecperm}" == "0" ] || [ "${userexecperm}" == "2" ] || [ "${userexecperm}" == "4" ]  || [ "${userexecperm}" == "6" ]; then
					if [ "${groupexecperm}" == "0" ] || [ "${groupexecperm}" == "2" ] || [ "${groupexecperm}" == "4" ]  || [ "${groupexecperm}" == "6" ]; then
					# If errors are still found
					fn_print_fail_nl "The following file could not be set executable:"
					ls -l "${executabledir}/${execname}"
					fn_script_log_warn "The following file could not be set executable:"
					fn_script_log_info "${executabledir}/${execname}"
					core_exit.sh
					fi
				fi
			fi
		fi
	fi
}

fn_check_ownership
fn_check_permissions
