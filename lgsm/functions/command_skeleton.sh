#!/bin/bash
# LinuxGSM command_skeleton.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Creates an copy of a game servers directorys.


fn_print_dots ""
check.sh

# Find all directorys and create them in the skel directory
find ${rootdir} -type d -not \( -path ./skel -prune \) | cpio -pdvm skel
