#!/bin/bash
# LinuxGSM fix_sfc.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves various issues with SFC.

local commandname="FIX"
local commandaction="Fix"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

echo "Fix SFC."
ln -s "${serverfiles}/bin/datacache_srv.so" "${serverfiles}/bin/datacache.so"
ln -s "${serverfiles}/bin/dedicated_srv.so" "${serverfiles}/bin/dedicated.so"
ln -s "${serverfiles}/bin/engine_srv.so" "${serverfiles}/bin/engine.so"
ln -s "${serverfiles}/bin/materialsystem_srv.so" "${serverfiles}/bin/materialsystem.so"
ln -s "${serverfiles}/bin/replay_srv.so" "${serverfiles}/bin/replay.so"
ln -s "${serverfiles}/bin/shaderapiempty_srv.so" "${serverfiles}/bin/shaderapiempty.so"
ln -s "${serverfiles}/bin/soundemittersystem_srv.so" "${serverfiles}/bin/soundemittersystem.so"
ln -s "${serverfiles}/bin/studiorender_srv.so" "${serverfiles}/bin/studiorender.so"
ln -s "${serverfiles}/bin/vphysics_srv.so" "${serverfiles}/bin/vphysics.so"
ln -s "${serverfiles}/bin/scenefilecache_srv.so" "${serverfiles}/bin/scenefilecache.so"
fn_sleep_time
