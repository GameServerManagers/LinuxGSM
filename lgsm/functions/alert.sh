#!/bin/bash
# LGSM alert.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Overall function for managing alerts.

local modulename="Alert"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_alert_test(){
	fn_script_log_info "Sending test alert"
	alertsubject="LGSM - Test Alert - ${servername}"
	alertbody="LGSM test alert, how you read?"
}

fn_alert_restart(){
	fn_script_log_info "Sending restart alert: ${executable} process not running"
	alertsubject="LGSM - Restarted - ${servername}"
	alertbody="${servicename} ${executable} process not running"
}

fn_alert_restart_query(){
	fn_script_log_info "Sending restart alert: ${gsquerycmd}"
	alertsubject="LGSM - Restarted - ${servername}"
	alertbody="gsquery.py failed to query: ${gsquerycmd}"
}

fn_alert_update(){
	fn_script_log_info "Sending update alert"
	alertsubject="LGSM - Updated - ${servername}"
	alertbody="${servicename} recieved update"
}

if [ "${alert}" == "restart" ]; then
	fn_alert_restart
elif [ "${alert}" == "restartquery" ]; then
	fn_alert_restart_query
elif [ "${alert}" == "update" ]; then
	fn_alert_update
elif [ "${alert}" == "test" ]; then
	fn_alert_test
fi

if [ "${emailnotification}" == "on" ]||[ "${emailalert}" == "on" ]&&[ -n "${email}" ]; then
	alert_email.sh
elif [ "${emailnotification}" != "on" ]||[ "${emailalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_info_nl "Email alerts not enabled"
	fn_script_log_info "Email alerts not enabled"
elif [ -z "${email}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_fail_nl "Email not set"
	fn_script_log "Email not set"
fi

if [ "${pushbulletalert}" == "on" ]&&[ -n "${pushbullettoken}" ]; then
	alert_pushbullet.sh
elif [ "${pushbulletalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_info_nl "Pushbullet alerts not enabled"
	fn_script_log_info "Pushbullet alerts not enabled"
elif [ -z "${pushbullettoken}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_fail_nl "Pushbullet token not set"
	fn_script_log_warn "Pushbullet token not set"
fi