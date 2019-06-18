#!/usr/bin/env bash
# command_dev_clear_functions.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Deletes the contents of the functions dir.

echo "================================="
echo "Clear Functions"
echo "================================="
echo ""
if fn_prompt_yn "Do you want to delete all functions?" Y; then
	rm -rfv "${functionsdir:?}/"*
	rm -rfv "${configdirdefault:?}/"*
fi
core_exit.sh