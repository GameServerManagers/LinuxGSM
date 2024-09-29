#!/bin/bash
# LinuxGSM command_skeleton.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates an copy of a game servers directorys.

commandname="SKELETON"
commandaction="Skeleton"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_dots "Creating skeleton directory"
check.sh

# Find all directorys and create them in the skel directory
find "${rootdir}" -type d -not \( -path ./skel -prune \) | cpio -pdvm skel 2> /dev/null
exitcode=$?
if [ "${exitcode}" != 0 ]; then
	fn_print_fail_nl "Creating skeleton directory"
	fn_script_log_fail "Creating skeleton directory"
else
	fn_print_ok_nl "Creating skeleton directory: ./skel"
	fn_script_log_pass "Creating skeleton directory: ./skel"
fi
core_exit.sh
