#!/bin/bash
# LinuxGSM core_messages.sh function
# Author: Daniel Gibbs
# Contributor: s-eam
# Website: https://linuxgsm.com
# Description: Defines on-screen messages such as [  OK  ] and how script logs look.

# nl: new line: message is following by a new line.
# eol: end of line: message is placed at the end of the current line.
fn_ansi_loader(){
	if [ "${ansi}" != "off" ]; then
		# echo colors
		default="\e[0m"
		black="\e[30m"
		red="\e[31m"
		lightred="\e[91m"
		green="\e[32m"
		lightgreen="\e[92m"
		yellow="\e[33m"
		lightyellow="\e[93m"
		blue="\e[34m"
		lightblue="\e[94m"
		magenta="\e[35m"
		lightmagenta="\e[95m"
		cyan="\e[36m"
		lightcyan="\e[96m"
		darkgrey="\e[90m"
		lightgrey="\e[37m"
		white="\e[97m"
	fi
	# carriage return & erase to end of line.
	creeol="\r\033[K"
}

fn_sleep_time(){
	if [ "${sleeptime}" != "0" ]||[ "${travistest}" != "1" ]; then
		if [ -z "${sleeptime}" ]; then
			sleeptime=0.5
		fi
		sleep "${sleeptime}"
	fi
}

# Log display
########################
## Feb 28 14:56:58 ut99-server: Monitor:
fn_script_log(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ "${modulename}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${commandname}: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${1}" >> "${lgsmlog}"
		fi
	fi
}

## Feb 28 14:56:58 ut99-server: Monitor: PASS:
fn_script_log_pass(){
	if [ -d "${lgsmlogdir}" ]; then

		if [ "${modulename}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${commandname}: PASS: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: PASS: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=0
}

## Feb 28 14:56:58 ut99-server: Monitor: FATAL:
fn_script_log_fatal(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ "${modulename}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${commandname}: FATAL: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: FATAL: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=1
}

## Feb 28 14:56:58 ut99-server: Monitor: ERROR:
fn_script_log_error(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ "${modulename}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${commandname}: ERROR: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ERROR: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=2
}

## Feb 28 14:56:58 ut99-server: Monitor: WARN:
fn_script_log_warn(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ "${modulename}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${commandname}: WARN: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: WARN: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=3
}

## Feb 28 14:56:58 ut99-server: Monitor: INFO:
fn_script_log_info(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ "${modulename}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${commandname}: INFO: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: INFO: ${1}" >> "${lgsmlog}"
		fi
	fi
}

# On-Screen - Automated functions
##################################

# [ .... ]
fn_print_dots(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[ .... ] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[ .... ] $*"
	fi
	fn_sleep_time
}

fn_print_dots_nl(){
	if [ "${commandaction}" ]; then
		echo -e "${creeol}[ .... ] ${commandaction} ${selfname}: $*"
	else
		echo -e "${creeol}[ .... ] $*"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [  OK  ]
fn_print_ok(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${green}  OK  ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${green}  OK  ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_ok_nl(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${green}  OK  ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${green}  OK  ${default}] $*"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ FAIL ]
fn_print_fail(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${red} FAIL ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${red} FAIL ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_fail_nl(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${red} FAIL ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${red} FAIL ${default}] $*"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ ERROR ]
fn_print_error(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${red}ERROR ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${red}ERROR ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_error_nl(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${red}ERROR ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${red}ERROR ${default}] $*"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ WARN ]
fn_print_warn(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${lightyellow} WARN ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${lightyellow} WARN ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_warn_nl(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${lightyellow} WARN ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${lightyellow} WARN ${default}] $*"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ INFO ]
fn_print_info(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${cyan} INFO ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${cyan} INFO ${default}] $*"
	fi
	fn_sleep_time
}

fn_print_info_nl(){
	if [ "${commandaction}" ]; then
		echo -en "${creeol}[${cyan} INFO ${default}] ${commandaction} ${selfname}: $*"
	else
		echo -en "${creeol}[${cyan} INFO ${default}] $*"
	fi
	fn_sleep_time
	echo -en "\n"
}

# On-Screen - Interactive messages
##################################

# No More Room in Hell Debug
# =================================
fn_print_header(){
	echo -e ""
	echo -e "${lightyellow}${gamename} ${commandaction}${default}"
	echo -e "=================================${default}"
}

# Complete!
fn_print_complete(){
	echo -en "${green}Complete!${default} $*"
	fn_sleep_time
}

fn_print_complete_nl(){
	echo -e "${green}Complete!${default} $*"
	fn_sleep_time
}

# Failure!
fn_print_failure(){
	echo -en "${red}Failure!${default} $*"
	fn_sleep_time
}

fn_print_failure_nl(){
	echo -e "${red}Failure!${default} $*"
	fn_sleep_time
}

# Error!
fn_print_error2(){
	echo -en "${red}Error!${default} $*"
	fn_sleep_time
}

fn_print_error2_nl(){
	echo -e "${red}Error!${default} $*"
	fn_sleep_time
}

# Warning!
fn_print_warning(){
	echo -en "${lightyellow}Warning!${default} $*"
	fn_sleep_time
}

fn_print_warning_nl(){
	echo -e "${lightyellow}Warning!${default} $*"
	fn_sleep_time
}

# Information!
fn_print_information(){
	echo -en "${cyan}Information!${default} $*"
	fn_sleep_time
}

fn_print_information_nl(){
	echo -e "${cyan}Information!${default} $*"
	fn_sleep_time
}

# Y/N Prompt
fn_prompt_yn(){
	local prompt="$1"
	local initial="$2"

	if [ "${initial}" == "Y" ]; then
		prompt+=" [Y/n] "
	elif [ "${initial}" == "N" ]; then
		prompt+=" [y/N] "
	else
		prompt+=" [y/n] "
	fi

	while true; do
		read -e -i "${initial}" -p  "${prompt}" -r yn
		case "${yn}" in
			[Yy]|[Yy][Ee][Ss]) return 0 ;;
			[Nn]|[Nn][Oo]) return 1 ;;
		*) echo -e "Please answer yes or no." ;;
		esac
	done
}

# On-Screen End of Line
##################################

# OK
fn_print_ok_eol(){
	echo -en "${green}OK${default}"
}

fn_print_ok_eol_nl(){
	echo -e "${green}OK${default}"
}

# FAIL
fn_print_fail_eol(){
	echo -en "${red}FAIL${default}"
}

fn_print_fail_eol_nl(){
	echo -e "${red}FAIL${default}"
}

# ERROR
fn_print_error_eol(){
	echo -en "${red}ERROR${default}"
}

fn_print_error_eol_nl(){
	echo -en "${red}ERROR${default}"
}

# WARN
fn_print_warn_eol(){
	echo -en "${lightyellow}WARN${default}"
}

fn_print_warn_eol_nl(){
	echo -e "${lightyellow}WARN${default}"
}

# INFO
fn_print_info_eol(){
	echo -en "${red}INFO${default}"
}

fn_print_info_eol_nl(){
	echo -e "${red}INFO${default}"
}

# QUERYING
fn_print_querying_eol(){
	echo -en "${cyan}QUERYING${default}"
}

fn_print_querying_eol_nl(){
	echo -e "${cyan}QUERYING${default}"
}

# CHECKING
fn_print_checking_eol(){
	echo -en "${cyan}CHECKING${default}"
}

fn_print_checking_eol_nl(){
	echo -e "${cyan}CHECKING${default}"
}

# DELAY
fn_print_delay_eol(){
	echo -en "${green}DELAY${default}"
}

fn_print_delay_eol_nl(){
	echo -e "${green}DELAY${default}"
}

# CANCELED
fn_print_canceled_eol(){
	echo -en "${yellow}CANCELED${default}"
}

fn_print_canceled_eol_nl(){
	echo -e "${yellow}CANCELED${default}"
}

# REMOVED
fn_print_removed_eol(){
	echo -en "${red}REMOVED${default}"
}

fn_print_removed_eol_nl(){
	echo -e "${red}REMOVED${default}"
}

# UPDATE
fn_print_update_eol(){
	echo -en "${cyan}UPDATE${default}"
}

fn_print_update_eol_nl(){
	echo -e "${cyan}UPDATE${default}"
}

fn_print_ascii_logo(){
	echo -e ""
	echo -e "                                mdMMMMbm"
	echo -e "                              mMMMMMMMMMMm"
	echo -e "                              mMMMMMMMMMMMMm"
	echo -e "                             mMMMMMMMMMMMMMMm"
	echo -e "                             hMMMV^VMMV^VMMMh"
	echo -e "                             MMMMM  MM  MMMMM"
	echo -e "                             hMMs   vv   sMMh"
	echo -e "                            hMMM:        :MMMh"
	echo -e "                          .hMMMh          hMMMh."
	echo -e "                         -dMMMh     ${lightgrey}__${default}     hMMMd-"
	echo -e "                        :mMMMs      ${lightgrey}||${default}      sMMMm:"
	echo -e "                       :MMMM+       ${lightgrey}||${default} ${red}_${default}     +NMMN:"
	echo -e "                      .mMMM+     ${lightgrey}========${default}     +MMMm."
	echo -e "                      yMMMy   ${darkgrey}##############${default}   yMMMy"
	echo -e "                      mMMM:   ${darkgrey}##############${default}   :MMMm"
	echo -e "                      mMM   ${lightyellow}nn${default}   ${lightyellow}nn${default}    ${lightyellow}nn${default}   ${lightyellow}nn${default}   MMm"
	echo -e "                      o   ${lightyellow}nNNNNNNNn${default}    ${lightyellow}nNNNNNNNn${default}   o"
	echo -e "                         ${lightyellow}nNNNNNNNNNn${default}  ${lightyellow}nNNNNNNNNNn${default}"
	echo -e "                        ${lightyellow}nNNNNNNNNNNN${default}  ${lightyellow}NNNNNNNNNNNn${default}"
	echo -e "                         ${lightyellow}+NNNNNNNNN:${default}  ${lightyellow}:NNNNNNNNN+${default}"
	echo -e "                           ${lightyellow}nNNNNNNN${default} /\ ${lightyellow}NNNNNNNn${default}"
	echo -e "                             ${lightyellow}nnnnn${default}  db  ${lightyellow}nnnnn${default}"
	echo -e ""
	echo -e "${lightyellow}888${default}      ${lightyellow}d8b${default}                             ${default}.d8888b.   .d8888b.  888b     d888"
	echo -e "${lightyellow}888      Y8P                            ${default}d88P  Y88b d88P  Y88b 8888b   d8888"
	echo -e "${lightyellow}888${default}                                     ${default}888${default}    888 Y88b.      88888b.d88888"
	echo -e "${lightyellow}888${default}      ${lightyellow}888${default} ${lightyellow}88888b.${default}  ${lightyellow}888${default}  ${lightyellow}888${default} ${lightyellow}888${default}  ${lightyellow}888${default} 888          Y888b.   888Y88888P888"
	echo -e "${lightyellow}888${default}      ${lightyellow}888${default} ${lightyellow}888${default}  ${lightyellow}88b${default} ${lightyellow}888${default}  ${lightyellow}888${default}  ${lightyellow}Y8bd8P${default}  888  88888      Y88b. 888 Y888P 888"
	echo -e "${lightyellow}888${default}      ${lightyellow}888${default} ${lightyellow}888${default}  ${lightyellow}888${default} ${lightyellow}888${default}  ${lightyellow}888${default}   ${lightyellow}X88K${default}   888    888        888 888  Y8P  888"
	echo -e "${lightyellow}888${default}      ${lightyellow}888${default} ${lightyellow}888${default}  ${lightyellow}888${default} ${lightyellow}Y88b${default} ${lightyellow}88Y${default} ${lightyellow}.d8pq8b.${default} Y88b  d88P Y88b  d88P 888   *   888"
	echo -e "${lightyellow}LinuxGSM${default} ${lightyellow}888${default} ${lightyellow}888${default}  ${lightyellow}888${default}  ${lightyellow}Y8888Y${default}  ${lightyellow}888${default}  ${lightyellow}888${default}   Y2012P88   Y8888P   888       888"
	echo -e ""
}
