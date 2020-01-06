#!/bin/bash
# LinuxGSM install_nmrih_symlinks.sh function
# Author: Denperidge
# Description: Create symlinks for renamed No More Room In Hell serverfiles 
# Solution from Steam Community post: https://steamcommunity.com/app/224260/discussions/2/1732089092441769414/

local bin = ~/serverfiles/bin/
ln -s $bin/vphysics_srv.so $bin/vphysics.so
ln -s $bin/studiorender_srv.so $bin/studiorender.so
ln -s $bin/soundemittersystem_srv.so $bin/soundemittersystem.so
ln -s $bin/shaderapiempty_srv.so $bin/shaderapiempty.so
ln -s $bin/scenefilecache_srv.so $bin/scenefilecache.so
ln -s $bin/replay_srv.so $bin/replay.so
ln -s $bin/materialsystem_srv.so $bin/materialsystem.so 