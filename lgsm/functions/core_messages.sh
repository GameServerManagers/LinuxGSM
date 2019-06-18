#!/usr/bin/env bash
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
		if [ -n "${commandname}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ${commandname}: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ${1}" >> "${lgsmlog}"
		fi
	fi
}

## Feb 28 14:56:58 ut99-server: Monitor: PASS:
fn_script_log_pass(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ${commandname}: PASS: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: PASS: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=0
}

## Feb 28 14:56:58 ut99-server: Monitor: FATAL:
fn_script_log_fatal(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ${commandname}: FATAL: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: FATAL: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=1
}

## Feb 28 14:56:58 ut99-server: Monitor: ERROR:
fn_script_log_error(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ${commandname}: ERROR: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ERROR: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=2
}

## Feb 28 14:56:58 ut99-server: Monitor: WARN:
fn_script_log_warn(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ${commandname}: WARN: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: WARN: ${1}" >> "${lgsmlog}"
		fi
	fi
	exitcode=3
}

## Feb 28 14:56:58 ut99-server: Monitor: INFO:
fn_script_log_info(){
	if [ -d "${lgsmlogdir}" ]; then
		if [ -n "${commandname}" ]; then
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: ${commandname}: INFO: ${1}" >> "${lgsmlog}"
		else
			echo -e "$(date '+%b %d %H:%M:%S.%3N') ${servicename}: INFO: ${1}" >> "${lgsmlog}"
		fi
	fi
}

# On-Screen - Automated functions
##################################

# [ .... ]
fn_print_dots(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[ .... ] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[ .... ] $@"
	fi
	fn_sleep_time
}

fn_print_dots_nl(){
	if [ -n "${commandaction}" ]; then
		echo -e "${creeol}[ .... ] ${commandaction} ${servicename}: $@"
	else
		echo -e "${creeol}[ .... ] $@"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [  OK  ]
fn_print_ok(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${green}  OK  ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${green}  OK  ${default}] $@"
	fi
	fn_sleep_time
}

fn_print_ok_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${green}  OK  ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${green}  OK  ${default}] $@"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ FAIL ]
fn_print_fail(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${red} FAIL ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${red} FAIL ${default}] $@"
	fi
	fn_sleep_time
}

fn_print_fail_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${red} FAIL ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${red} FAIL ${default}] $@"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ ERROR ]
fn_print_error(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${red}ERROR ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${red}ERROR ${default}] $@"
	fi
	fn_sleep_time
}

fn_print_error_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${red}ERROR ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${red}ERROR ${default}] $@"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ WARN ]
fn_print_warn(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${yellow} WARN ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${yellow} WARN ${default}] $@"
	fi
	fn_sleep_time
}

fn_print_warn_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${yellow} WARN ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${yellow} WARN ${default}] $@"
	fi
	fn_sleep_time
	echo -en "\n"
}

# [ INFO ]
fn_print_info(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${cyan} INFO ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${cyan} INFO ${default}] $@"
	fi
	fn_sleep_time
}

fn_print_info_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "${creeol}[${cyan} INFO ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "${creeol}[${cyan} INFO ${default}] $@"
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
	echo -e "${gamename} ${commandaction}"
	echo -e "=================================${default}"
	echo -e ""
}

# Complete!
fn_print_complete(){
	echo -en "${green}Complete!${default} $@"
	fn_sleep_time
}

fn_print_complete_nl(){
	echo -e "${green}Complete!${default} $@"
	fn_sleep_time
}

# Failure!
fn_print_failure(){
	echo -en "${red}Failure!${default} $@"
	fn_sleep_time
}

fn_print_failure_nl(){
	echo -e "${red}Failure!${default} $@"
	fn_sleep_time
}

# Error!
fn_print_error2(){
	echo -en "${red}Error!${default} $@"
	fn_sleep_time
}

fn_print_error2_nl(){
	echo -e "${red}Error!${default} $@"
	fn_sleep_time
}

# Warning!
fn_print_warning(){
	echo -en "${yellow}Warning!${default} $@"
	fn_sleep_time
}

fn_print_warning_nl(){
	echo -e "${yellow}Warning!${default} $@"
	fn_sleep_time
}

# Information!
fn_print_information(){
	echo -en "${cyan}Information!${default} $@"
	fn_sleep_time
}

fn_print_information_nl(){
	echo -e "${cyan}Information!${default} $@"
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
		*) echo "Please answer yes or no." ;;
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

# WARN
fn_print_warn_eol(){
	echo -en "${red}WARN${default}"
}

fn_print_warn_eol_nl(){
	echo -e "${red}WARN${default}"
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
