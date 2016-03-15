#!/bin/bash
# LGSM check_permissions function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: http://gameservermanagers.com
lgsm_version="150316"

# Description: Checks script, files and folders ownership and permissions.

# Initializing useful variables
currentuser="$(whoami)"
scriptfullpath="${rootdir}/${selfname}"
permissionerror="0"

fn_check_ownership(){
if [ "${currentuser}" != "$(stat -c %U "${scriptfullpath}")" ] && [ "${currentuser}" != "$(stat -c %G "${scriptfullpath}")" ]; then
  permissionerror="1"
  fn_print_fail_nl "Permission denied"
  echo "	* To check allowed user and group run ls -l ${selfname}"
fi
}

fn_check_permissions(){
if [ -n "${functionsdir}" ]; then
  find "${functionsdir}" -name "*.sh" | while read filename; do perm="$(stat -c %a "${filename}")"; shortperm="$(echo ${perms:0:1})";
    if [ "${shortperm}" != "7" ]; then
      permissionerror="1"
      echo "Found permission error on $filename"
      fn_print_warn_n1 "Warning, permission issues found in ${functionsdir}"
      echo "  * Easy fix : chmod -R 755 ${functionsdir}"
    fi
  done
fi
}

fn_check_permissions_summary(){
if [ "${permissionerror}" == "1" ]; then
  exit 1
fi
}

fn_check_ownership
fn_check_permissions
fn_check_permissions_summary
