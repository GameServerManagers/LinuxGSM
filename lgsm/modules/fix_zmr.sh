#!/bin/bash
# LinuxGSM fix_sfc.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Zombie Master: Reborn.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -f "${serverfiles}/bin/datacache.so" ]; then
	ln -s "${serverfiles}/bin/datacache_srv.so" "${serverfiles}/bin/datacache.so"
fi

if [ ! -f "${serverfiles}/bin/dedicated.so" ]; then
	ln -s "${serverfiles}/bin/dedicated_srv.so" "${serverfiles}/bin/dedicated.so"
fi

if [ ! -f "${serverfiles}/bin/engine.so" ]; then
	ln -s "${serverfiles}/bin/engine_srv.so" "${serverfiles}/bin/engine.so"
fi

if [ ! -f "${serverfiles}/bin/materialsystem.so" ]; then
	ln -s "${serverfiles}/bin/materialsystem_srv.so" "${serverfiles}/bin/materialsystem.so"
fi

if [ ! -f "${serverfiles}/bin/replay.so" ]; then
	ln -s "${serverfiles}/bin/replay_srv.so" "${serverfiles}/bin/replay.so"
fi

if [ ! -f "${serverfiles}/bin/shaderapiempty.so" ]; then
	ln -s "${serverfiles}/bin/shaderapiempty_srv.so" "${serverfiles}/bin/shaderapiempty.so"
fi

if [ ! -f "${serverfiles}/bin/soundemittersystem.so" ]; then
	ln -s "${serverfiles}/bin/soundemittersystem_srv.so" "${serverfiles}/bin/soundemittersystem.so"
fi

if [ ! -f "${serverfiles}/bin/studiorender.so" ]; then
	ln -s "${serverfiles}/bin/studiorender_srv.so" "${serverfiles}/bin/studiorender.so"
fi

if [ ! -f "${serverfiles}/bin/vphysics.so" ]; then
	ln -s "${serverfiles}/bin/vphysics_srv.so" "${serverfiles}/bin/vphysics.so"
fi

if [ ! -f "${serverfiles}/bin/scenefilecache.so" ]; then
	ln -s "${serverfiles}/bin/scenefilecache_srv.so" "${serverfiles}/bin/scenefilecache.so"
fi
