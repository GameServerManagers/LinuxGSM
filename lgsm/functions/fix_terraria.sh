#!/bin/bash
# LinuxGSM fix_terraria.sh module
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Contributors: http://linuxgsm.com/contrib
# Description: Resolves an issue with Terraria.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export TERM=xterm
