#!/bin/bash
# LGSM core_trap.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: handles ctrl-C trap to give an exitcode.

fn_exit_trap(){
	echo ""
	core_exit.sh
}

# trap to give an exitcode.
trap fn_exit_trap INT