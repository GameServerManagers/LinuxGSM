#!/bin/bash
# LinuxGSM command_console.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Gives access to the server tmux console.

commandname="CONSOLE"
commandaction="Access console"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
fn_print_header

if [ "${consoleverbose}" == "yes" ]; then
	echo -e "* Verbose output: ${lightgreen}yes${default}"
elif [ "${consoleverbose}" == "no" ]; then
	echo -e "* Verbose output: ${red}no${default}"
else
	echo -e "* Verbose output: ${red}unknown${default}"
fi

if [ "${consoleinteract}" == "yes" ]; then
	echo -e "* Interactive output: ${lightgreen}yes${default}"
elif [ "${consoleinteract}" == "no" ]; then
	echo -e "* Interactive output: ${red}no${default}"
else
	echo -e "* Interactive output: ${red}unknown${default}"
fi
echo ""
fn_print_information_nl "Press \"CTRL+b\" then \"d\" to exit console."
fn_print_warning_nl "Do NOT press CTRL+c to exit."
echo -e "* https://docs.linuxgsm.com/commands/console"
echo -e ""
if ! fn_prompt_yn "Continue?" Y; then
	exitcode=0
	core_exit.sh
fi
fn_print_dots "Accessing console"
check_status.sh
if [ "${status}" != "0" ]; then
	fn_print_ok_nl "Accessing console"
	fn_script_log_pass "Console accessed"
	tmux attach-session -t "${sessionname}"
	fn_print_ok_nl "Closing console"
	fn_script_log_pass "Console closed"
else
	fn_print_error_nl "Server not running"
	fn_script_log_error "Failed to access: Server not running"
	if fn_prompt_yn "Do you want to start the server?" Y; then
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
	fi
fi

core_exit.sh
