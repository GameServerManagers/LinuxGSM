#!/bin/bash
# LinuxGSM core_legacy.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Code for backwards compatability with older versions of LinuxGSM.

if [ -z ${serverfiles} ]; then
	serverfiles="${filesdir}"
fi