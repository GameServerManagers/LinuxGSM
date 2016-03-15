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
  exit 1
fi
}

fn_check_permissions(){
# Checking permission on rootdir
if [ -n "${rootdir}" ]; then
  rootdirperm="$(stat -c %a "${rootdir}")"
  userrootdirperm="${rootdirperm:0:1}"
  grouprootdirperm="${rootdirperm:1:1}"
  if [ "${userrootdirperm}" != "7" ] && [ "${grouprootdirperm}" != "7" ]; then
    fn_print_fail_nl "Permission issues found in root directory"
    echo "  * You might wanna run : chmod -R 755 \"${rootdir}\""
    conclusionpermissionerror="1"
  fi
fi
  
# Checking permissions on functions
funcpermfail="0"
if [ -n "${functionsdir}" ]; then
  while read -r filename
    do
      funcperm="$(stat -c %a "${filename}")"
      userfuncdirperm="${funcperm:0:1}"
      groupfuncdirperm="${duncperm:1:1}"
      if [ "${userfuncdirperm}" != "7" ] && [ "${groupfuncdirperm}" != "7" ]; then
        funcpermfail="1"
        conclusionpermissionerror="1"
      fi
  done <<< "$(find "${functionsdir}" -name "*.sh")"
  
  if [ "${funcpermfail}" == "1" ]; then
    fn_print_fail_nl "Permission issues found in functions."
    echo "  * You might wanna run : chmod -R 755 \"${functionsdir}\""
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
