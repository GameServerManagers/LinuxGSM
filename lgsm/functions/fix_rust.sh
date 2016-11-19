#!/bin/bash
# LGSM fix_rust.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Resolves startup issue with Rust

local commandname="FIX"
local commandaction="Fix"

# Fixes: ./srcds_linux: error while loading shared libraries: libtier0.so: cannot open shared object file: No such file or directory.
export LD_LIBRARY_PATH="${systemdir}/RustDedicated_Data/Plugins/x86_64"
