#!/bin/bash
# command_dev_clear_functions.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Deletes the contents of the functions dir.

echo -e "================================="
echo -e "Clear Functions"
echo -e "================================="
echo -e ""
if fn_prompt_yn "Do you want to delete all functions?" Y; then
	rm -rfv "${functionsdir:?}/"*
	rm -rfv "${configdirdefault:?}/"*
fi

core_exit.sh
