#!/bin/bash
# LinuxGSM check_config.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Checks if run from tmux or screen

local commandname="CHECK"

fn_check_is_in_tmux(){
  if [ -n "${TMUX}" ]; then
		fn_print_fail_nl "tmuxception error: Sorry Cobb you cannot start a tmux session inside of a tmux session."
		fn_script_log_fatal "Tmuxception error: Attempted to start a tmux session inside of a tmux session."
		fn_print_information_nl "LinuxGSM creates a tmux session when starting the server."
		echo -e "It is not possible to run a tmux session inside another tmux session"
		echo -e "https://docs.linuxgsm.com/requirements/tmux#tmuxception"
		core_exit.sh
	fi
}

fn_check_is_in_screen(){
	if [ -n "${STY}" ]; then
		fn_print_fail_nl "tmuxception error: Sorry Cobb you cannot start a tmux session inside of a screen session."
		fn_script_log_fatal "Tmuxception error: Attempted to start a tmux session inside of a screen session."
		fn_print_information_nl "LinuxGSM creates a tmux session when starting the server."
		echo -e "It is not possible to run a tmux session inside screen session"
		echo -e "https://docs.linuxgsm.com/requirements/tmux#tmuxception"
		core_exit.sh
	fi
}

fn_check_is_in_tmux
fn_check_is_in_screen
