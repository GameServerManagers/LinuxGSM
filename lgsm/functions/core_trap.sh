#!/bin/bash
# LGSM core_trap.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Handles CTRL-C trap to give an exit code.

fn_exit_trap(){
	echo ""
	core_exit.sh
}

# trap to give an exit code.
trap fn_exit_trap INT