#!/bin/bash
# LinuxGSM fix_mta.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Resolves various issues with Multi Theft Auto.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ ! -f "${lgsmdir}/lib/libmysqlclient.so.16" ]; then
	fixname="libmysqlclient16"
	fn_fix_msg_start_nl
	fn_fetch_file "https://nightly.mtasa.com/files/modules/64/libmysqlclient.so.16" "" "" "" "${lgsmdir}/lib" "libmysqlclient.so.16" "chmodx" "norun" "noforce" "6c188e0f8fb5d7a29f4bc413b9fed6c2"
	fn_fix_msg_end
fi
