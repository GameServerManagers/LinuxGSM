#!/bin/bash
# LinuxGSM fix_wurm.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves issues with Wurm Unlimited.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# First run requires start with no parms.
# After first run new dirs are created.
if [ ! -d "${serverfiles}/Creative" ]; then
	fixname="Copy Creative directory"
	fn_fix_msg_start
	cp -R "${serverfiles}/dist/Creative" "${serverfiles}/Creative"
	fn_fix_msg_end
fi

if [ ! -d "${serverfiles}/Adventure" ]; then
	fixname="Copy Adventure directory"
	fn_fix_msg_start
	cp -R "${serverfiles}/dist/Adventure" "${serverfiles}/Adventure"
	fn_fix_msg_end
fi
