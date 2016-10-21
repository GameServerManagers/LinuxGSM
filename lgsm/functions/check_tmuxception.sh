#!/bin/bash
# LGSM check_config.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Checks if run from tmux or screen

local commandname="check"

fn_check_is_in_tmux(){
  if [ -n "${TMUX}" ];then
		fn_print_fail_nl "tmuxception error: Sorry Cobb you cannot start a tmux session inside of a tmux session."
		fn_script_log_fatal "tmuxception error: Attempted to start a tmux session inside of a tmux session."
		fn_print_information_nl "LGSM creates a tmux session when starting the server."
		echo "It is not possible to run a tmux session inside another tmux session"
		echo "https://github.com/GameServerManagers/LinuxGSM/wiki/Tmux#tmuxception"
		core_exit.sh
	fi
}
fn_check_is_in_screen(){
	if [ "$TERM" == "screen" ];then
		fn_print_fail_nl "tmuxception error: Sorry Cobb you cannot start a tmux session inside of a screen session."
		fn_script_log_fatal "tmuxception error: Attempted to start a tmux session inside of a screen session."
		fn_print_information_nl "LGSM creates a tmux session when starting the server."
		echo "It is not possible to run a tmux session inside screen session"
		echo "https://github.com/GameServerManagers/LinuxGSM/wiki/Tmux#tmuxception"
		core_exit.sh
	fi
}

fn_check_is_in_tmux
fn_check_is_in_screen
