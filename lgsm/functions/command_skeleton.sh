#!/bin/bash
# LinuxGSM command_skeleton.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Creates an copy of a game servers directorys.


fn_print_dots "Creating skeleton directory"
check.sh

# Find all directorys and create them in the skel directory
find "${rootdir}" -type d -not \( -path ./skel -prune \) | cpio -pdvm skel 2>/dev/null
exitcode=$?
if [ "${exitcode}" != 0 ]; then
	fn_print_fail_nl "Creating skeleton directory"
	fn_script_log_fatal "Creating skeleton directory"
else
	fn_print_ok_nl "Creating skeleton directory: ./skel"
	fn_script_log_pass "Creating skeleton directory: ./skel"
fi
core_exit.sh
