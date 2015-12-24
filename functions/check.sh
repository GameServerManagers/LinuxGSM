#!/bin/bash
# LGSM fn_check function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="201215"

# Description: Overall function for managing checks.
# Runs checks that will either halt on or fix an issue.

fn_module_compare() {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}


check_root.sh

if [ "${module}" != "install" ]; then
	check_systemdir.sh
fi

no_check_logs=( details install map-compressor )
fn_module_compare "${cmd}" "${no_check_logs[@]}"
if [ $? != 0 ]; then
	fn_check_logs
fi

check_ip=( debug )
fn_module_compare "${cmd}" "${no_check_logs[@]}"
if [ $? != 0 ]; then
	check_ip.sh
fi

fn_check_steamcmd
fn_check_steamuser
fn_check_tmux

fn_check_ts3status # may need to move out of checks