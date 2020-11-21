#!/bin/bash
# command_dev_clear_functions.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Deletes the contents of the functions dir.

commandname="DEV-CLEAR-MODULES"
commandaction="Clearing modules"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

echo -e "================================="
echo -e "Clear Functions"
echo -e "================================="
echo -e ""
if fn_prompt_yn "Do you want to delete all functions?" Y; then
	rm -rfv "${functionsdir:?}/"*
	rm -rfv "${configdirdefault:?}/"*
	fn_script_log_info "Cleared modules directory"
	fn_script_log_info "Cleared default config directory"
fi

core_exit.sh
