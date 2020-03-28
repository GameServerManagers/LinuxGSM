#!/bin/bash
# LinuxGSM check_last_update.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Checks lock file to see when last update happened.

laststart=$(cat "${lockdir}/laststart.lock")
lastupdate=$(cat "${lockdir}/lastupdate.lock")

if [ "${laststart}" < "${lastupdate}"  ]; then
  command_restart.sh
fi
