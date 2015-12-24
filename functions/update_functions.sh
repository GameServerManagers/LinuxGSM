#!/bin/bash
# LGSM fn_update_functions function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

fn_printdots "Updating functions"
fn_scriptlog "Updating functions"
sleep 1
echo -ne "\n"
rm -rfv "${rootdir}/functions/"*
exitcode=$?
if [ "${exitcode}" == "0" ]; then
	fn_printok "Updating functions"
	fn_scriptlog "Successfull! Updating functions"
else
	fn_printokfail "Updating functions"
	fn_scriptlog "Failure! Updating functions"
fi
echo -ne "\n"