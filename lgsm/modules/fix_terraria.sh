#!/bin/bash
# LinuxGSM fix_terraria.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Terraria.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export TERM=xterm
