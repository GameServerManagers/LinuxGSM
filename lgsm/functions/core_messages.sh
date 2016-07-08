#!/bin/bash
# LGSM fn_messages function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Defines on-screen messages such as [  OK  ] and how script logs look.

# nl: new line: message is following by a new line
# eol: end of line: message is placed at the end of the current line

if [ "${ansi}" != "off" ]; then
	# echo colors
	default="\e[0m"
	red="\e[31m"
	green="\e[32m"
	yellow="\e[33m"
	blue="\e[34m"
	magenta="\e[35m"
	cyan="\e[36m"
	lightyellow="\e[93m"
fi

# Log display
##########
## Feb 28 14:56:58 ut99-server: Monitor:
fn_script_log(){
	if [ -n "${commandaction}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${commandaction}: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${1}" >> "${scriptlog}"
	fi
}

## Feb 28 14:56:58 ut99-server: Monitor: PASS:
fn_script_log_pass(){
	if [ -n "${commandaction}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${commandaction}: PASS: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: PASS: ${1}" >> "${scriptlog}"
	fi
	exitcode=0
}

## Feb 28 14:56:58 ut99-server: Monitor: FATAL:
fn_script_log_fatal(){
	if [ -n "${commandaction}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${commandaction}: FATAL: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: FATAL: ${1}" >> "${scriptlog}"
	fi
	exitcode=1
}

## Feb 28 14:56:58 ut99-server: Monitor: ERROR:
fn_script_log_error(){
	if [ -n "${commandaction}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${commandaction}: ERROR: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ERROR: ${1}" >> "${scriptlog}"
	fi
	exitcode=2
}

## Feb 28 14:56:58 ut99-server: Monitor: WARN:
fn_script_log_warn(){
	if [ -n "${commandaction}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${commandaction}: WARN: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: WARN: ${1}" >> "${scriptlog}"
	fi
	exitcode=3
}

## Feb 28 14:56:58 ut99-server: Monitor: INFO:
fn_script_log_info(){
	if [ -n "${commandaction}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${commandaction}: INFO: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: INFO: ${1}" >> "${scriptlog}"
	fi
}

# On-Screen
##########

# [ .... ]
fn_print_dots(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[ .... ] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[ .... ] $@"
	fi
}

fn_print_dots_nl(){
	if [ -n "${commandaction}" ]; then
		echo -e "\r[ .... ] ${commandaction} ${servicename}: $@"
	else
		echo -e "\r[ .... ] $@"
	fi
	sleep 0.5
	echo -en "\n"
}

# [  OK  ]
fn_print_ok(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${green}  OK  ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${green}  OK  ${default}] $@"
	fi
}

fn_print_ok_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${green}  OK  ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${green}  OK  ${default}] $@"
	fi
	sleep 0.5
	echo -en "\n"
}

# [ FAIL ]
fn_print_fail(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${red} FAIL ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${red} FAIL ${default}] $@"
	fi
}

fn_print_fail_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${red} FAIL ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${red} FAIL ${default}] $@"
	fi
	sleep 0.5
	echo -en "\n"
}

# [ ERROR ]
fn_print_error(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${red} ERROR${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${red} ERROR${default}] $@"
	fi
}

fn_print_error_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${red} ERROR${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${red} ERROR${default}] $@"
	fi
	sleep 0.5
	echo -en "\n"
}

# [ WARN ]
fn_print_warn(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${yellow} WARN ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${yellow} WARN ${default}] $@"
	fi
}

fn_print_warn_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${yellow} WARN ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${yellow} WARN ${default}] $@"
	fi
	sleep 0.5
	echo -en "\n"
}

# [ INFO ]
fn_print_info(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${cyan} INFO ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${cyan} INFO ${default}] $@"
	fi
}

fn_print_info_nl(){
	if [ -n "${commandaction}" ]; then
		echo -en "\r[${cyan} INFO ${default}] ${commandaction} ${servicename}: $@"
	else
		echo -en "\r[${cyan} INFO ${default}] $@"
	fi
	sleep 0.5
	echo -en "\n"
}

# On-Screen full word
##########

# Complete!
fn_print_complete(){
	echo -en "${green}Complete!${default} $@"
}

fn_print_complete_nl(){
	echo -e "${green}Complete!${default} $@"
}

# Failure!
fn_print_failure(){
	echo -en "${red}Failure!${default} $@"
}

fn_print_failure_nl(){
	echo -e "${red}Failure!${default} $@"
}

# Error!
fn_print_error2(){
	echo -en "${red}Error!${default} $@"
}

fn_print_error2_nl(){
	echo -e "${red}Error!${default} $@"
}

# Warning!
fn_print_warning(){
	echo -en "${yellow}Warning!${default} $@"
}

fn_print_warning_nl(){
	echo -e "${yellow}Warning!${default} $@"
}

# Infomation!
fn_print_infomation(){
	echo -en "${cyan}Infomation!${default} $@"
}

fn_print_infomation_nl(){
	echo -e "${cyan}Infomation!${default} $@"
}

# On-Screen End of Line
##########

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

# WARN
fn_print_warn_eol(){
	echo -en "${red}FAIL${default}"
}

fn_print_warn_eol_nl(){
	echo -e "${red}FAIL${default}"
}

# INFO
fn_print_info_eol(){
	echo -en "${red}FAIL${default}"
}

fn_print_info_eol_nl(){
	echo -e "${red}FAIL${default}"
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