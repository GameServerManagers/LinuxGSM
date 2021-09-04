#!/bin/bash
# LinuxGSM fix_mcb.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Resolves possible startup issue with Minecraft Bedrock.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# official docs state that the server should be started with: LD_LIBRARY_PATH=. ./bedrock_server
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${serverfiles}"
