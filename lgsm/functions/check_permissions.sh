#!/bin/bash
# LGSM check_permissions.sh
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="150316"

# Description: Checks script, files and folders ownership and permissions.

# Initializing useful variables
currentuser="$(whoami)"
scriptfullpath="${rootdir}/${selfname}"
conclusionpermissionerror="0"

fn_check_ownership(){
if [ "${currentuser}" != "$(stat -c %U "${scriptfullpath}")" ] && [ "${currentuser}" != "$(stat -c %G "${scriptfullpath}")" ]; then
  conclusionpermissionerror="1"
  fn_print_fail_nl "Permission denied"
  echo "	* To check allowed user and group run ls -l ${selfname}"
fi
}

fn_check_permissions(){
permissionfailure="0"
if [ -n "${functionsdir}" ]; then
  while read -r filename
    do
      perm="$(stat -c %a "${filename}")"
      shortperm="${perm:0:1}"
      if [ "${shortperm}" != "7" ]; then
        permissionfailure="1"
        conclusionpermissionerror="1"
      fi
  done <<< "$(find "${functionsdir}" -name "*.sh")"
  
  if [ "${permissionfailure}" == "1" ]; then
    fn_print_fail_nl "Warning, permission issues found in functions."
    echo "  * Easy fix : chmod -R 755 ${functionsdir}"
  fi
fi
}

fn_check_permissions_conclusion(){
if [ "${conclusionpermissionerror}" == "1" ]; then
  exit 1
fi
}

fn_check_ownership
fn_check_permissions
fn_check_permissions_conclusion
