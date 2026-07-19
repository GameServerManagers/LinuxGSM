#!/bin/bash
# LinuxGSM fix_nmrih.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Create symlinks for renamed No More Room In Hell serverfiles.
# Solution from Steam Community post: https://steamcommunity.com/app/224260/discussions/2/1732089092441769414/

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -f "${serverfiles}/bin/vphysics.so" ]; then
	ln -s "${serverfiles}/bin/vphysics_srv.so" "${serverfiles}/bin/vphysics.so"
fi
if [ ! -f "${serverfiles}/bin/studiorender.so" ]; then
	ln -s "${serverfiles}/bin/studiorender_srv.so" "${serverfiles}/bin/studiorender.so"
fi
if [ ! -f "${serverfiles}/bin/soundemittersystem.so" ]; then
	ln -s "${serverfiles}/bin/soundemittersystem_srv.so" "${serverfiles}/bin/soundemittersystem.so"
fi
if [ ! -f "${serverfiles}/bin/shaderapiempty.so" ]; then
	ln -s "${serverfiles}/bin/shaderapiempty_srv.so" "${serverfiles}/bin/shaderapiempty.so"
fi
if [ ! -f "${serverfiles}/bin/scenefilecache.so" ]; then
	ln -s "${serverfiles}/bin/scenefilecache_srv.so" "${serverfiles}/bin/scenefilecache.so"
fi
if [ ! -f "${serverfiles}/bin/replay.so" ]; then
	ln -s "${serverfiles}/bin/replay_srv.so" "${serverfiles}/bin/replay.so"
fi
if [ ! -f "${serverfiles}/bin/materialsystem.so" ]; then
	ln -s "${serverfiles}/bin/materialsystem_srv.so" "${serverfiles}/bin/materialsystem.so"
fi
