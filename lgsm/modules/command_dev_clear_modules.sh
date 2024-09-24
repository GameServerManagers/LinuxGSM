#!/bin/bash
# LinuxGSM command_dev_clear_modules.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Deletes the contents of the modules dir.

commandname="DEV-CLEAR-MODULES"
commandaction="Clearing modules"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

echo -e ""
echo -e "${bold}${lightyellow}Clear Modules${default}"
fn_messages_separator
echo -e ""
if fn_prompt_yn "Do you want to delete all modules?" Y; then
	rm -rfv "${modulesdir:?}/"*
	rm -rfv "${configdirdefault:?}/"*
	fn_script_log_info "Cleared modules directory"
	fn_script_log_info "Cleared default config directory"
fi

core_exit.sh
