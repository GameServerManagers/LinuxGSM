#!/bin/bash
# LinuxGSM fix_terraria.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves an issue with Terraria.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export TERM=xterm
