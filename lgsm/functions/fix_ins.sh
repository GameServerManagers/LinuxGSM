#!/bin/bash
# LGSM fix_ins.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="291215"

# Description: Resolves various issues with Insurgency.

# Resolves ./srcds_linux: error while loading shared libraries: libtier0.so: cannot open shared object file: No such file or directory

export LD_LIBRARY_PATH=:${filesdir}:${filesdir}/bin:{$LD_LIBRARY_PATH}

# fix for issue #529 - gamemode not passed to debug or start

if [ "${function_selfname}" == "command_debug.sh" ]; then
        defaultmap="\"${defaultmap}\""
else
        defaultmap="\\\"${defaultmap}\\\""
fi
