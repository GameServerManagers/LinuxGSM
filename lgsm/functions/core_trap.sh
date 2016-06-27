#!/bin/bash
# LGSM core_trap.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: handles ctrl-C trap to give an exitcode.

fn_exit_trap(){
	core_exit.sh
}

# trap to remove lockfile on quit.
trap fn_exit_trap INT