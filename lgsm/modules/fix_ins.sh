#!/bin/bash
# LinuxGSM fix_ins.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Insurgency.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Fixes: ./srcds_linux: error while loading shared libraries: libtier0.so: cannot open shared object file: No such file or directory.

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}:${serverfiles}/bin"

# Fixes: issue #529 - gamemode not passed to debug or start.

if [ "${commandname}" == "DEBUG" ]; then
	defaultmap="\"${defaultmap}\""
else
	defaultmap="\\\"${defaultmap}\\\""
fi

# Fixes: srcds_run is shipped with CRLF line endings and a /bin/sh shebang but needs bash (pushd/popd).

if [ -f "${serverfiles}/srcds_run" ]; then
	if grep -q $'\r' "${serverfiles}/srcds_run" || head -n 1 "${serverfiles}/srcds_run" | grep -q '^#!/bin/sh'; then
		sed -i 's/\r$//;1s|^#!/bin/sh$|#!/bin/bash|' "${serverfiles}/srcds_run"
	fi
fi
