#!/bin/bash
# LinuxGSM check_last_update.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks lock file to see when last update happened.

laststart=$(cat "${lockdir}/laststart.lock")
lastupdate=$(cat "${lockdir}/lastupdate.lock")

if [ "${laststart}" -lt "${lastupdate}"  ]; then
  fn_print_info_nl "${selfname} has not been restarted since last update"
  fn_script_log_info "${selfname} has not been restarted since last update"
  command_restart.sh
fi
