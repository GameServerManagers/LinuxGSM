#!/bin/bash
# LinuxGSM fix_ts.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with The Specialists.

# shellcheck disable=SC2034 # Used by the module loader.
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export GLIBC_TUNABLES="${GLIBC_TUNABLES:+${GLIBC_TUNABLES}:}glibc.rtld.execstack=2"
