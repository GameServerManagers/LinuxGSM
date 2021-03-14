#!/bin/bash
# LinuxGSM alert.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Overall function for managing alerts.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Generates alert log of the details at the time of the alert.
# Used with email alerts.
fn_alert_log(){
	info_distro.sh
	info_config.sh
	info_messages.sh
	if [ -f "${alertlog}" ]; then
		rm -f "${alertlog:?}"
	fi

	{
		fn_info_message_head
		fn_info_message_distro
		fn_info_message_server_resource
		fn_info_message_gameserver_resource
		fn_info_message_gameserver
		fn_info_logs
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${alertlog}" > /dev/null 2>&1
}

fn_alert_test(){
	fn_script_log_info "Sending test alert"
	alertsubject="Alert - ${selfname} - Test"
	alertemoji="🚧"
	alertsound="1"
	alerturl="not enabled"
	alertbody="Testing LinuxGSM Alert. No action to be taken."
}

fn_alert_restart(){
	fn_script_log_info "Sending alert: Restarted: ${executable} not running"
	alertsubject="Alert - ${selfname} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerturl="not enabled"
	alertbody="${selfname} ${executable} not running"
}

fn_alert_restart_query(){
	fn_script_log_info "Sending alert: Restarted: ${selfname}"
	alertsubject="Alert - ${selfname} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerturl="not enabled"
	alertbody="Unable to query: ${selfname}"
}

fn_alert_update(){
	fn_script_log_info "Sending alert: Updated"
	alertsubject="Alert - ${selfname} - Updated"
	alertemoji="🎮"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${gamename} received update"
}

fn_alert_check_update(){
	fn_script_log_info "Sending alert: Update available"
	alertsubject="Alert - ${selfname} - Update available"
	alertemoji="🎮"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${gamename} update available"
}

fn_alert_permissions(){
	fn_script_log_info "Sending alert: Permissions error"
	alertsubject="Alert - ${selfname}: Permissions error"
	alertemoji="❗"
	alertsound="2"
	alerturl="not enabled"
	alertbody="${selfname} has permissions issues"
}

fn_alert_config(){
	fn_script_log_info "Sending alert: New _default.cfg"
	alertsubject="Alert - ${selfname} - New _default.cfg"
	alertemoji="🎮"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${selfname} has received a new _default.cfg. Check file for changes."
}

if [ "${alert}" == "permissions" ]; then
	fn_alert_permissions
elif [ "${alert}" == "restart" ]; then
	fn_alert_restart
elif [ "${alert}" == "restartquery" ]; then
	fn_alert_restart_query
elif [ "${alert}" == "test" ]; then
	fn_alert_test
elif [ "${alert}" == "update" ]; then
	fn_alert_update
elif [ "${alert}" == "check-update" ]; then
	fn_alert_check_update
elif [ "${alert}" == "config" ]; then
	fn_alert_config
fi

# Generate alert log.
fn_alert_log

# Generates the more info link.
if [ "${postalert}" == "on" ]&&[ -n "${postalert}" ]; then
	exitbypass=1
	command_postdetails.sh
	fn_firstcommand_reset
	unset exitbypass
elif [ "${postalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "More Info not enabled"
	fn_script_log_warn "More Info alerts not enabled"
fi

if [ "${discordalert}" == "on" ]&&[ -n "${discordalert}" ]; then
	alert_discord.sh
elif [ "${discordalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Discord alerts not enabled"
	fn_script_log_warn "Discord alerts not enabled"
elif [ -z "${discordtoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Discord token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/discord"
	fn_script_error "Discord token not set"
fi

if [ "${emailalert}" == "on" ]&&[ -n "${email}" ]; then
	alert_email.sh
elif [ "${emailalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Email alerts not enabled"
	fn_script_log_warn "Email alerts not enabled"
elif [ -z "${email}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Email not set"
	fn_script_log_error "Email not set"
fi

if [ "${iftttalert}" == "on" ]&&[ -n "${iftttalert}" ]; then
	alert_ifttt.sh
elif [ "${iftttalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "IFTTT alerts not enabled"
	fn_script_log_warn "IFTTT alerts not enabled"
elif [ -z "${ifttttoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "IFTTT token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/ifttt"
	fn_script_error "IFTTT token not set"
fi

if [ "${mailgunalert}" == "on" ]&&[ -n "${mailgunalert}" ]; then
	alert_mailgun.sh
elif [ "${mailgunalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Mailgun alerts not enabled"
	fn_script_log_warn "Mailgun alerts not enabled"
elif [ -z "${mailguntoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Mailgun token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/mailgun"
	fn_script_error "Mailgun token not set"
fi

if [ "${pushbulletalert}" == "on" ]&&[ -n "${pushbullettoken}" ]; then
	alert_pushbullet.sh
elif [ "${pushbulletalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Pushbullet alerts not enabled"
	fn_script_log_warn "Pushbullet alerts not enabled"
elif [ -z "${pushbullettoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Pushbullet token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/pushbullet"
	fn_script_error "Pushbullet token not set"
fi

if [ "${pushoveralert}" == "on" ]&&[ -n "${pushoveralert}" ]; then
	alert_pushover.sh
elif [ "${pushoveralert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Pushover alerts not enabled"
	fn_script_log_warn "Pushover alerts not enabled"
elif [ -z "${pushovertoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Pushover token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/pushover"
	fn_script_error "Pushover token not set"
fi

if [ "${telegramalert}" == "on" ]&&[ -n "${telegramtoken}" ]; then
	alert_telegram.sh
elif [ "${telegramalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Telegram Messages not enabled"
	fn_script_log_warn "Telegram Messages not enabled"
elif [ -z "${telegramtoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Telegram token not set."
	echo -e "* https://docs.linuxgsm.com/alerts/telegram"
	fn_script_error "Telegram token not set."
elif [ -z "${telegramchatid}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Telegram chat id not set."
	echo -e "* https://docs.linuxgsm.com/alerts/telegram"
	fn_script_error "Telegram chat id not set."
fi

if [ "${rocketchatalert}" == "on" ]&&[ -n "${rocketchatalert}" ]; then
	alert_rocketchat.sh
elif [ "${rocketchatalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Rocketchat alerts not enabled"
	fn_script_log_warn "Rocketchat alerts not enabled"
elif [ -z "${rocketchattoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Rocketchat token not set"
	#echo -e "* https://docs.linuxgsm.com/alerts/slack"
	fn_script_error "Rocketchat token not set"
fi

if [ "${slackalert}" == "on" ]&&[ -n "${slackalert}" ]; then
	alert_slack.sh
elif [ "${slackalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Slack alerts not enabled"
	fn_script_log_warn "Slack alerts not enabled"
elif [ -z "${slacktoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Slack token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/slack"
	fn_script_error "Slack token not set"
fi
