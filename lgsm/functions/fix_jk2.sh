#!/bin/bash
# LGSM fix_jk2.sh function
# Description: Resolves an issue with Jedi Knight 2.

local commandname="FIX"
local commandaction="Fix"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fixname="JK2 shared libraries"
fn_fix_msg_start
export LD_LIBRARY_PATH=${filesdir}:${filesdir}/lib:${LD_LIBRARY_PATH}
fn_fix_msg_end
