#!/bin/bash
# LGSM command_update_functions.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
check.sh
fn_print_dots "Updating functions"
fn_scriptlog "Updating functions"
sleep 1
echo -ne "\n"

# Removed legecy functions dir
if [ -n "${rootdir}" ]; then
	if [ -d "${rootdir}/functions/" ]; then
		rm -rfv "${rootdir}/functions/"
		exitcode=$?
	fi
fi

if [ -n "${functionsdir}" ]; then
	if [ -d "${functionsdir}" ]; then
		rm -rfv "${functionsdir}/"*
		exitcode=$?
	fi	
fi

if [ "${exitcode}" == "0" ]; then
	fn_print_ok "Updating functions"
	fn_scriptlog "Success! Updating functions"
else
	fn_print_fail "Updating functions"
	fn_scriptlog "Failure! Updating functions"
fi
echo -ne "\n"