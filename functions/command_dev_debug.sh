#!/bin/bash
# LGSM dev_debug.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="281215"

function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

if [ -f ".dev-debug" ]; then
	rm .dev-debug
	fn_printoknl "Disabled dev-debug"
else
	date > .dev-debug
	fn_printoknl "Enabled dev-debug"
fi