#!/bin/bash
# LGSM check_permissions.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Checks script, files and folders ownership and permissions.

# Useful variables
currentuser="$(whoami)"
currentgroups="$(groups)"
scriptfullpath="${rootdir}/${selfname}"
conclusionpermissionerror="0"

fn_check_ownership(){
	# Check script ownership
	if [ ! -O "${scriptfullpath}" ] && [ ! -G "${scriptfullpath}" ]; then
		fn_print_fail_nl "Oops ! Ownership issue..."
		echo "	* Current - ${currentuser} - user or its group(s) - ${currentgroups} - does not own \"${selfname}\""
		echo "	* To check the owner and allowed groups, run ls -l \"${selfname}\""
		exit 1
	fi

	# Check rootdir ownership
	if [ ! -O "${rootdir}" ] && [ ! -G "${rootdir}" ]; then
		fn_print_fail_nl "Oops ! Ownership issue..."
		echo "	* Current - ${currentuser} - user or its group(s) - ${currentgroups} - does not own \"${rootdir}\""
		echo "	* To check the owner and allowed groups, run ls -dl \"${rootdir}\""
		exit 1
	fi

	# Check functions ownership
	funownfail="0"
	if [ -n "${functionsdir}" ]; then
		while read -r filename
			do
				if [ ! -O "${filename}" ] && [ ! -G "${filename}" ]; then
					funownfail="1"
					conclusionpermissionerror="1"
				fi
		done <<< "$(find "${functionsdir}" -name "*.sh")"
		
		if [ "${funownfail}" == "1" ]; then
			fn_print_fail_nl "Oops ! Ownership issue..."
			echo "	* Current - ${currentuser} - user or its group(s) - ${currentgroups} - does not own all scripts in \"${functionsdir}\""
			echo "	* To check the owner and allowed groups, run ls -l \"${functionsdir}\""
		fi
	fi
}

fn_check_permissions(){
	# Check rootdir permissions
	if [ -n "${rootdir}" ]; then
		# Get permission numbers on folder under the form 775
		rootdirperm="$(stat -c %a "${rootdir}")"
		# Grab the first and second digit for user and group permission
		userrootdirperm="${rootdirperm:0:1}"
		grouprootdirperm="${rootdirperm:1:1}"
		if [ "${userrootdirperm}" != "7" ] && [ "${grouprootdirperm}" != "7" ]; then
			fn_print_fail_nl "Oops ! Permission issue..."
			echo "	* Current - ${currentuser} - user or its group(s) - ${currentgroups} need full control of \"${rootdir}\""
			echo "	* You might wanna run : chmod -R 770 \"${rootdir}\""
			conclusionpermissionerror="1"
		fi
	fi
		
	# Check functions permissions
	funcpermfail="0"
	if [ -n "${functionsdir}" ]; then
		while read -r filename
			do
				funcperm="$(stat -c %a "${filename}")"
				userfuncdirperm="${funcperm:0:1}"
				groupfuncdirperm="${funcperm:1:1}"
				if [ "${userfuncdirperm}" != "7" ] && [ "${groupfuncdirperm}" != "7" ]; then
					funcpermfail="1"
					conclusionpermissionerror="1"
				fi
		done <<< "$(find "${functionsdir}" -name "*.sh")"
		
		if [ "${funcpermfail}" == "1" ]; then
			fn_print_fail_nl "Oops ! Permission issue..."
			echo "	* Current - ${currentuser} - user or its group(s) - ${currentgroups} need full control on scripts in \"${functionsdir}\""
			echo "	* You might wanna run : chmod -R 770 \"${functionsdir}\""
		fi
	fi
}

fn_check_permissions_conclusion(){
	# Exit if errors found
	if [ "${conclusionpermissionerror}" == "1" ]; then
		exit 1
	fi
}

fn_check_ownership
fn_check_permissions
fn_check_permissions_conclusion
