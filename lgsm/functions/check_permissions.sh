#!/bin/bash
# LGSM check_permissions function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="150316"

# Description: Checks script, files and folders ownership and permissions.

# Initializing useful variables
currentuser="$(sh -c 'whoami')"
scriptfullpath="${rootdir}/${selfname}"

fn_check_ownership(){
if [ "${currentuser}" != "$(stat -c %U ${scripfullpath})" ] || [ "${currentuser}" != "$(stat -c %G ${scripfullpath})" ]; then
  fn_print_fail_nl "Permission denied"
  exit 1
fi
}

fn_check_ownership
