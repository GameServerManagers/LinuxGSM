#!/bin/bash
# LGSM fn_messages function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Defines on-screen messages such as [  OK  ] and how script logs look.

# nl: new line: message is following by a new line
# eol: end of line: message is placed at the end of the current line

# Date, servicename & module details displayed in log files.
# e.g Feb 28 14:56:58 ut99-server: Monitor:
fn_scriptlog(){
	if [ -n "${modulename}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${modulename}: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${1}" >> "${scriptlog}"
	fi
}

# [ FAIL ]
fn_print_fail(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;31m FAIL \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;31m FAIL \e[0m] $@"
	fi
}

fn_print_fail_nl(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;31m FAIL \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;31m FAIL \e[0m] $@"
	fi
	sleep 1
	echo -en "\n"		
}
	
# [  OK  ]
fn_print_ok(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;32m  OK  \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;32m  OK  \e[0m] $@"
	fi
}

fn_print_ok_nl(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;32m  OK  \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;32m  OK  \e[0m] $@"
	fi
	sleep 1
	echo -en "\n"	
}

# [ INFO ]
fn_print_info(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;36m INFO \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;36m INFO \e[0m] $@"
	fi
}

fn_print_info_nl(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;36m INFO \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;36m INFO \e[0m] $@"
	fi
	sleep 1
	echo -en "\n"		
}

# [ WARN ]
fn_print_warn(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[1;33m WARN \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[1;33m WARN \e[0m] $@"
	fi
}

fn_print_warn_nl(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[1;33m WARN \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[1;33m WARN \e[0m] $@"
	fi
	sleep 1
	echo -en "\n"		
}

# [ .... ]
fn_print_dots(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[ .... ] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[ .... ] $@"
	fi
}

# Complete!
fn_print_complete(){
	echo -en "\e[0;32mComplete!\e[0m $@"
}

fn_print_complete_nl(){
	echo -e "\e[0;32mComplete!\e[0m $@"
}

# Warning!
fn_print_warning(){
	echo -en "\e[0;33mWarning!\e[0m $@"
}

fn_print_warning_nl(){
	echo -e "\e[0;33mWarning!\e[0m $@"
}

# Failure!
fn_print_failure(){
	echo -en "\e[0;31mFailure!\e[0m $@"
}

fn_print_failure_nl(){
	echo -e "\e[0;31mFailure!\e[0m $@"
}

# Error!
fn_print_error(){
	echo -en "\e[0;31mError!\e[0m $@"
}

fn_print_error_nl(){
	echo -e "\e[0;31mError!\e[0m $@"
}

# Infomation!
fn_print_infomation(){
	echo -en "\e[0;36mInfomation!\e[0m $@"
}

fn_print_infomation_nl(){
	echo -e "\e[0;36mInfomation!\e[0m $@"
}

# FAIL for end of line
fn_print_ok_eol(){
	echo -en "\e[0;32mOK\e[0m"
}

fn_print_ok_eol_nl(){
	echo -e "\e[0;32mOK\e[0m"
}

# FAIL for end of line
fn_print_fail_eol(){
	echo -en "\e[0;31mFAIL\e[0m"
}

fn_print_fail_eol_nl(){
	echo -e "\e[0;31mFAIL\e[0m"
}

# QUERYING for end of line
fn_print_querying_eol(){
	echo -en "\e[0;36mQUERYING\e[0m"
}

fn_print_querying_eol_nl(){
	echo -e "\e[0;36mQUERYING\e[0m"
}

# CHECKING for end of line
fn_print_checking_eol(){
	echo -en "\e[0;36mCHECKING\e[0m"
}

fn_print_checking_eol_nl(){
	echo -e "\e[0;36mCHECKING\e[0m"
}

# CANCELED for end of line
fn_print_canceled_eol(){
	echo -en "\e[0;33mCANCELED\e[0m"
}

fn_print_canceled_eol_nl(){
	echo -e "\e[0;33mCANCELED\e[0m"
}

# REMOVED for end of line
fn_print_removed_eol(){
	echo -en "\e[0;31mREMOVED\e[0m"
}

fn_print_removed_eol_nl(){
	echo -e "\e[0;31mREMOVED\e[0m"
}