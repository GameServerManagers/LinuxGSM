#!/bin/bash
# LGSM fn_messages function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Defines on-screen messages such as [  OK  ] and how script logs look.

# Date and servicename for log files.
fn_scriptlog(){
	if [ -n "${modulename}" ]; then
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${modulename}: ${1}" >> "${scriptlog}"
	else
		echo -e "$(date '+%b %d %H:%M:%S') ${servicename}: ${1}" >> "${scriptlog}"
	fi
}

# [ FAIL ]
fn_printfail(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;31m FAIL \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;31m FAIL \e[0m] $@"
	fi
}

fn_printfailnl(){
	if [ -n "${modulename}" ]; then
		echo -e "\r\033[K[\e[0;31m FAIL \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -e "\r\033[K[\e[0;31m FAIL \e[0m] $@"
	fi
}
	
# [  OK  ]
fn_printok(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;32m  OK  \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;32m  OK  \e[0m] $@"
	fi
}

fn_printoknl(){
	if [ -n "${modulename}" ]; then
		echo -e "\r\033[K[\e[0;32m  OK  \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -e "\r\033[K[\e[0;32m  OK  \e[0m] $@"
	fi
}

# [ INFO ]
fn_printinfo(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[0;36m INFO \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[0;36m INFO \e[0m] $@"
	fi
}

fn_printinfonl(){
	if [ -n "${modulename}" ]; then
		echo -e "\r\033[K[\e[0;36m INFO \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -e "\r\033[K[\e[0;36m INFO \e[0m] $@"
	fi
}

# [ WARN ]
fn_printwarn(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[\e[1;33m WARN \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[\e[1;33m WARN \e[0m] $@"
	fi
}

fn_printwarnnl(){
	if [ -n "${modulename}" ]; then
		echo -e "\r\033[K[\e[1;33m WARN \e[0m] ${modulename} ${servicename}: $@"
	else
		echo -e "\r\033[K[\e[1;33m WARN \e[0m] $@"
	fi
}

# [ .... ]
fn_printdots(){
	if [ -n "${modulename}" ]; then
		echo -en "\r\033[K[ .... ] ${modulename} ${servicename}: $@"
	else
		echo -en "\r\033[K[ .... ] $@"
	fi
}

# Complete!
fn_printcomplete(){
	echo -en "\e[0;32mComplete!\e[0m $@"
}

fn_printcompletenl(){
	echo -e "\e[0;32mComplete!\e[0m $@"
}

# Warning!
fn_printwarning(){
	echo -en "\e[0;33mWarning!\e[0m $@"
}

fn_printwarningnl(){
	echo -e "\e[0;33mWarning!\e[0m $@"
}

# Failure!
fn_printfailure(){
	echo -en "\e[0;31mFailure!\e[0m $@"
}

fn_printfailurenl(){
	echo -e "\e[0;31mFailure!\e[0m $@"
}

# Error!
fn_printerror(){
	echo -en "\e[0;31mError!\e[0m $@"
}

fn_printerrornl(){
	echo -e "\e[0;31mError!\e[0m $@"
}

# Info!
fn_printinfomation(){
	echo -en "\e[0;36mInfo!\e[0m $@"
}

fn_printinfomationnl(){
	echo -e "\e[0;36mInfo!\e[0m $@"
}

# FAIL for end of line
fn_printokeol(){
	echo -e "\e[0;32mOK\e[0m"
}

# FAIL for end of line
fn_printfaileol(){
	echo -e "\e[0;31mFAIL\e[0m\n"
}