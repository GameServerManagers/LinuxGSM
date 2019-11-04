#!/bin/bash
# LinuxGSM core_trap.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Handles CTRL-C trap to give an exit code.

fn_exit_trap(){
	echo -e ""
	core_exit.sh
}

# trap to give an exit code.
trap fn_exit_trap INT
