#!/bin/bash
# LinuxGSM core_messages.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Defines on-screen messages such as [  OK  ] and how script logs look.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# nl: new line: message is following by a new line.
# eol: end of line: message is placed at the end of the current line.
fn_ansi_loader() {
	# carriage return.
	creeol="\r"
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
		# erase to end of line.
		creeol+="\033[K"
	fi
	# carriage return & erase to end of line.
	creeol="\r\033[K"

	bold="\e[1m"
	dim="\e[2m"
	italic="\e[3m"
	underline="\e[4m"
	reverse="\e[7m"
}

fn_sleep_time() {
	sleep "0.1"
}

fn_sleep_time_05() {
	sleep "0.5"
}

fn_sleep_time_1() {
	sleep "1"
}

fn_sleep_time_5() {
	sleep "5"
}

fn_sleep_time_10() {
	sleep "10"
}

# Log display
########################
## Feb 28 14:56:58 ut99-server: Monitor:
fn_script_log() {
	if [ -d "${lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${commandname}: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${selfname}: ${1}" >> "${lgsmlog}"
		fi
	fi
}

## Feb 28 14:56:58 ut99-server: Monitor: PASS:
fn_script_log_pass() {
	fn_script_log "PASS: ${1}"
	exitcode=0
}

## Feb 28 14:56:58 ut99-server: Monitor: FATAL:
fn_script_log_fail() {
	fn_script_log "FAIL: ${1}"
	exitcode=1
}

## Feb 28 14:56:58 ut99-server: Monitor: ERROR:
fn_script_log_error() {
	fn_script_log "ERROR: ${1}"
	exitcode=2
}

## Feb 28 14:56:58 ut99-server: Monitor: WARN:
fn_script_log_warn() {
	fn_script_log "WARN: ${1}"
	exitcode=3
}

## Feb 28 14:56:58 ut99-server: Monitor: INFO:
fn_script_log_info() {
	fn_script_log "INFO: ${1}"
}

# On-Screen - Automated functions
##################################

fn_print() {
	echo -en "$*${default}"
}

fn_print_nl() {
	echo -e "$*${default}"
}

# Helper function to print messages with a specific format and color
fn_print_message() {
	local type="$1"
	local color="$2"
	local message="$3"
	if [ "${commandaction}" ]; then
		echo -en "${bold}${creeol}[${color} ${type} ${default}]${default} ${commandaction} ${selfname}: ${message}${default}"
	else
		echo -en "${bold}${cree}[${color} ${type} ${default}]${default} ${message}${default}"
	fi
	fn_sleep_time
}

fn_print_message_nl() {
	local type="$1"
	local color="$2"
	local message="$3"
	if [ "${commandaction}" ]; then
		echo -e "${bold}${creeol}[${color} ${type} ${default}]${default} ${commandaction} ${selfname}: ${message}${default}"
	else
		echo -e "${bold}${creeol}[${color} ${type} ${default}]${default} ${message}${default}"
	fi
	fn_sleep_time
}

# [ .... ]
fn_print_dots() {
	fn_print_message "...." "${default}" "$*"
	fn_sleep_time_05
}

fn_print_dots_nl() {
	fn_print_message_nl "...." "${default}" "$*"
	fn_sleep_time_05
}

# [  OK  ]
fn_print_ok() {
	fn_print_message " OK " "${green}" "$*"
}

fn_print_ok_nl() {
	fn_print_message_nl " OK " "${green}" "$*"
}

# [ FAIL ]
fn_print_fail() {
	fn_print_message "FAIL" "${red}" "$*"
}

fn_print_fail_nl() {
	fn_print_message_nl "FAIL" "${red}" "$*"
}

# [ ERROR ]
fn_print_error() {
	fn_print_message "ERROR" "${red}" "$*"
}

fn_print_error_nl() {
	fn_print_message_nl "ERROR" "${red}" "$*"
}

# [ WARN ]
fn_print_warn() {
	fn_print_message "WARN" "${lightyellow}" "$*"
}

fn_print_warn_nl() {
	fn_print_message_nl "WARN" "${lightyellow}" "$*"
}

# [ INFO ]
fn_print_info() {
	fn_print_message "INFO" "${cyan}" "$*"
}

fn_print_info_nl() {
	fn_print_message_nl "INFO" "${cyan}" "$*"
}

# [ SKIP ]
fn_print_skip() {
	fn_print_message "SKIP" "${cyan}" "$*"
}

fn_print_skip_nl() {
	fn_print_message_nl "SKIP" "${cyan}" "$*"
}

# [ START ]
fn_print_start() {
	fn_print_message "START" "${lightgreen}" "$*"
}

fn_print_start_nl() {
	fn_print_message_nl "START" "${lightgreen}" "$*"
}

# On-Screen - Interactive messages
##################################

# Separator is different for details.
fn_messages_separator() {
	if [ "${commandname}" == "DETAILS" ]; then
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
	else
		echo -e "${bold}=================================${default}"
		fn_sleep_time
	fi
}

# No More Room in Hell Debug
# =================================
fn_print_header() {
	echo -e ""
	echo -e "${bold}${lightyellow}${gamename} ${commandaction}${default}"
	fn_messages_separator
}

# Success!
fn_print_success() {
	echo -en "${green}Success!${default} $*${default}"
	fn_sleep_time
}

fn_print_success_nl() {
	echo -e "${green}Success!${default} $*${default}"
	fn_sleep_time
}

# Failure!
fn_print_failure() {
	echo -en "${red}Failure!${default} $*${default}"
	fn_sleep_time
}

fn_print_failure_nl() {
	echo -e "${red}Failure!${default} $*${default}"
	fn_sleep_time
}

# Error!
fn_print_error2() {
	echo -en "${red}Error!${default} $*${default}"
	fn_sleep_time
}

fn_print_error2_nl() {
	echo -e "${red}Error!${default} $*${default}"
	fn_sleep_time
}

# Warning!
fn_print_warning() {
	echo -en "${lightyellow}Warning!${default} $*${default}"
	fn_sleep_time
}

fn_print_warning_nl() {
	echo -e "${lightyellow}Warning!${default} $*${default}"
	fn_sleep_time
}

# Information!
fn_print_information() {
	echo -en "${cyan}Information!${default} $*${default}"
	fn_sleep_time
}

fn_print_information_nl() {
	echo -e "${cyan}Information!${default} $*${default}"
	fn_sleep_time
}

# Skip!
fn_print_skip2() {
	echo -en "${cyan}Skip!${default} $*${default}"
	fn_sleep_time
}

fn_print_skip2_nl() {
	echo -e "${cyan}Skip!${default} $*${default}"
	fn_sleep_time
}

# Y/N Prompt
fn_prompt_yn() {
	echo -e ""
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
		read -e -i "${initial}" -p "${prompt}" -r yn
		case "${yn}" in
			[Yy] | [Yy][Ee][Ss]) return 0 ;;
			[Nn] | [Nn][Oo]) return 1 ;;
			*) echo -e "Please answer yes or no." ;;
		esac
	done
}

# Prompt for message
fn_prompt_message() {
	while true; do
		unset prompt
		local prompt="$1"
		read -e -p "${prompt}" -r answer
		if fn_prompt_yn "Continue" Y; then
			break
		fi
	done
	echo "${answer}"
}

# On-Screen End of Line
##################################

# YES
fn_print_yes_eol() {
	echo -en " ... ${cyan}YES${default}"
	fn_sleep_time
}

fn_print_yes_eol_nl() {
	echo -e " ... ${cyan}YES${default}"
	fn_sleep_time
}

# NO
fn_print_no_eol() {
	echo -en " ... ${red}NO${default}"
	fn_sleep_time
}

fn_print_no_eol_nl() {
	echo -e " ... ${red}NO${default}"
	fn_sleep_time
}

# OK
fn_print_ok_eol() {
	echo -en " ... ${green}OK${default}"
	fn_sleep_time
}

fn_print_ok_eol_nl() {
	echo -e " ... ${green}OK${default}"
	fn_sleep_time
}

# FAIL
fn_print_fail_eol() {
	echo -en " ... ${red}FAIL${default}"
	fn_sleep_time
}

fn_print_fail_eol_nl() {
	echo -e " ... ${red}FAIL${default}"
	fn_sleep_time
}

# ERROR
fn_print_error_eol() {
	echo -en " ... ${red}ERROR${default}"
	fn_sleep_time
}

fn_print_error_eol_nl() {
	echo -e " ... ${red}ERROR${default}"
	fn_sleep_time
}

# WAIT
fn_print_wait_eol() {
	echo -en " ... ${cyan}WAIT${default}"
	fn_sleep_time
}

fn_print_wait_eol_nl() {
	echo -e " ... ${cyan}WAIT${default}"
	fn_sleep_time
}

# WARN
fn_print_warn_eol() {
	echo -en " ... ${lightyellow}WARN${default}"
	fn_sleep_time
}

fn_print_warn_eol_nl() {
	echo -e " ... ${lightyellow}WARN${default}"
	fn_sleep_time
}

# INFO
fn_print_info_eol() {
	echo -en " ... ${cyan}INFO${default}"
	fn_sleep_time
}

fn_print_info_eol_nl() {
	echo -e " ... ${cyan}INFO${default}"
	fn_sleep_time
}

# QUERYING
fn_print_querying_eol() {
	echo -en " ... ${cyan}QUERYING${default}"
	fn_sleep_time_1
}

fn_print_querying_eol_nl() {
	echo -e " ... ${cyan}QUERYING${default}"
	fn_sleep_time_1
}

# CHECKING
fn_print_checking_eol() {
	echo -en " ... ${cyan}CHECKING${default}"
	fn_sleep_time_1
}

fn_print_checking_eol_nl() {
	echo -e " ... ${cyan}CHECKING${default}"
	fn_sleep_time_1
}

# DELAY
fn_print_delay_eol() {
	echo -en " ... ${green}DELAY${default}"
	fn_sleep_time_1
}

fn_print_delay_eol_nl() {
	echo -e " ... ${green}DELAY${default}"
	fn_sleep_time_1
}

# CANCELED
fn_print_canceled_eol() {
	echo -en " ... ${lightyellow}CANCELED${default}"
	fn_sleep_time_1
}

fn_print_canceled_eol_nl() {
	echo -e " ... ${lightyellow}CANCELED${default}"
	fn_sleep_time_1
}

# REMOVED
fn_print_removed_eol() {
	echo -en " ... ${red}REMOVED${default}"
	fn_sleep_time_1
}

fn_print_removed_eol_nl() {
	echo -e " ... ${red}REMOVED${default}"
	fn_sleep_time_1
}

# UPDATE
fn_print_update_eol() {
	echo -en " ... ${lightblue}UPDATE${default}"
	fn_sleep_time
}

fn_print_update_eol_nl() {
	echo -e " ... ${lightblue}UPDATE${default}"
	fn_sleep_time
}

# SKIP
fn_print_skip_eol() {
	echo -en " ... ${cyan}SKIP${default}"
	fn_sleep_time
}

fn_print_skip_eol_nl() {
	echo -e " ... ${cyan}SKIP${default}"
	fn_sleep_time
}

fn_print_ascii_logo() {
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

fn_print_restart_warning() {
	fn_print_warn "${selfname} will be restarted"
	fn_script_log_warn "${selfname} will be restarted"
	totalseconds=3
	for seconds in {3..1}; do
		fn_print_warn "${selfname} will be restarted: ${totalseconds}"
		totalseconds=$((totalseconds - 1))
		fn_sleep_time_1
		if [ "${seconds}" == "0" ]; then
			break
		fi
	done
	fn_print_warn_nl "${selfname} will be restarted"
}

# Functions below are used to ensure that logs and UI correctly reflect the command it is actually running.
# Useful when a command has to call upon another command causing the other command to overrite commandname variables

# Used to remember the command that ran first.
fn_firstcommand_set() {
	if [ -z "${firstcommandname}" ]; then
		firstcommandname="${commandname}"
		firstcommandaction="${commandaction}"
	fi
}

# Used to reset commandname variables to the command the script ran first.
fn_firstcommand_reset() {
	commandname="${firstcommandname}"
	commandaction="${firstcommandaction}"
}
