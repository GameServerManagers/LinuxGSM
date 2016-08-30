#!/bin/bash
# LGSM fix_ges.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Resolves various issues with GoldenEye: Source.

local commandname="FIX"
local commandaction="Fix"

# Fixes: MALLOC_CHECK_ needing to be set to 0.
export MALLOC_CHECK_=0