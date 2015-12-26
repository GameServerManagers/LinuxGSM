#!/bin/bash
# LGSM dev_debug.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="061115"

if [ -f ".dev-debug" ]; then
	rm .dev-debug
	fn_printoknl "Disabled dev-debug"
else
	date > .dev-debug
	fn_printoknl "Enabled dev-debug"
fi