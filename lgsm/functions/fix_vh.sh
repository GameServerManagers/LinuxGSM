#!/bin/bash
# LinuxGSM fix_rust.sh function
# Author: Alasdair Haig
# Website: https://linuxgsm.com
# Description: Resolves startup issue with Valheim

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
