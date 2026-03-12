#!/bin/bash
# LinuxGSM command_dev_ui.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Dev only: Assist with UI development.

commandname="DEV-DEBUG"
commandaction="Developer UI"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_header

# Load ANSI colors
fn_ansi_loader

fn_print_nl ""
fn_print_nl "${lightgreen}Colours${default}"
fn_messages_separator
# Print supported colors
fn_print_nl "${default}default"
fn_print_nl "${black}black${default}"
fn_print_nl "${red}red${default}"
fn_print_nl "${lightred}lightred${default}"
fn_print_nl "${green}green${default}"
fn_print_nl "${lightgreen}lightgreen${default}"
fn_print_nl "${yellow}yellow${default}"
fn_print_nl "${lightyellow}lightyellow${default}"
fn_print_nl "${blue}blue${default}"
fn_print_nl "${lightblue}lightblue${default}"
fn_print_nl "${magenta}magenta${default}"
fn_print_nl "${lightmagenta}lightmagenta${default}"
fn_print_nl "${cyan}cyan${default}"
fn_print_nl "${lightcyan}lightcyan${default}"
fn_print_nl "${darkgrey}darkgrey${default}"
fn_print_nl "${lightgrey}lightgrey${default}"
fn_print_nl "${white}white${default}"
fn_print_nl "${bold}bold${default}"
fn_print_nl "${dim}dim${default}"
fn_print_nl "${italic}italic${default}"
fn_print_nl "${underline}underline${default}"
fn_print_nl "${reverse}reverse${default}"

fn_print_nl ""
fn_print_nl "${lightgreen}Non Interactive UI Status Messages${default}"
fn_messages_separator
fn_print_nl ""
fn_print_nl "Print Message"
fn_print_nl ""
fn_print_nl "${lightgreen}Status Messages${default}"
fn_messages_separator
fn_print_dots_nl "Dots"
fn_print_ok_nl "OK"
fn_print_fail_nl "Fail"
fn_print_error_nl "Error"
fn_print_warn_nl "Warn"
fn_print_info_nl "Info"
fn_print_start_nl "Start"

fn_print_nl ""
fn_print_nl "${lightgreen}Interactive UI Status Messages${default}"
fn_messages_separator
fn_print_success_nl
fn_print_failure_nl
fn_print_error2_nl
fn_print_warning_nl
fn_print_information_nl

fn_print_nl ""
fn_print_nl "${lightgreen}EOL Status Messages${default}"
fn_messages_separator

fn_print "Print yes message with eol"
fn_print_yes_eol_nl
fn_print "Print no message with eol"
fn_print_no_eol_nl
fn_print "Print ok message with eol"
fn_print_ok_eol_nl
fn_print "Print fail message with eol"
fn_print_fail_eol_nl
fn_print "Print error message with eol"
fn_print_error_eol_nl
fn_print "Print warn message with eol"
fn_print_wait_eol_nl
fn_print "Print info message with eol"
fn_print_warn_eol_nl
fn_print "Print querying message with eol"
fn_print_info_eol_nl
fn_print "Print checking message with eol"
fn_print_querying_eol_nl
fn_print "Print delay message with eol"
fn_print_checking_eol_nl
fn_print "Print canceled message with eol"
fn_print_delay_eol_nl
fn_print "Print removed message with eol"
fn_print_canceled_eol_nl
fn_print "Print update message with eol"
fn_print_removed_eol_nl
fn_print "Print skip message with eol"
fn_print_update_eol_nl
fn_print "Print skip message with eol"
fn_print_skip_eol_nl

fn_print_nl ""
fn_print_nl "${lightgreen}Restart warning${default}"
fn_messages_separator
fn_print_restart_warning

core_exit.sh
