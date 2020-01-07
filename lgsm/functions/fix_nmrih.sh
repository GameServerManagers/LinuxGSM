#!/bin/bash
# LinuxGSM fix_nmrih.sh function
# Author: Denperidge
# Description: Create symlinks for renamed No More Room In Hell serverfiles
# Solution from Steam Community post: https://steamcommunity.com/app/224260/discussions/2/1732089092441769414/

ln -s "${serverfiles}/bin/vphysics_srv.so" "${serverfiles}/bin/vphysics.so"
ln -s "${serverfiles}/bin/studiorender_srv.so" "${serverfiles}/bin/studiorender.so"
ln -s "${serverfiles}/bin/soundemittersystem_srv.so" "${serverfiles}/bin/soundemittersystem.so"
ln -s "${serverfiles}/bin/shaderapiempty_srv.so" "${serverfiles}/bin/shaderapiempty.so"
ln -s "${serverfiles}/bin/scenefilecache_srv.so" "${serverfiles}/bin/scenefilecache.so"
ln -s "${serverfiles}/bin/replay_srv.so" "${serverfiles}/bin/replay.so"
ln -s "${serverfiles}/bin/materialsystem_srv.so" "${serverfiles}/bin/materialsystem.so" 