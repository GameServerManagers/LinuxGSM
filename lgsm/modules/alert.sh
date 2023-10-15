#!/bin/bash
# LinuxGSM alert.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Overall module for managing alerts.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Generates alert log of the details at the time of the alert.
# Used with email alerts.
fn_alert_log() {
	info_distro.sh
	info_game.sh
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
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | tee -a "${alertlog}" > /dev/null 2>&1
}

fn_alert_test() {
	fn_script_log_info "Sending test alert"
	alertsubject="Alert - ${selfname} - Test"
	alertemoji="🚧"
	alertsound="1"
	alerturl="not enabled"
	alertbody="Testing LinuxGSM Alert. No action to be taken."
	# Green
	alertcolourhex="#cdcd00"
	alertcolourdec="13487360"
}

# Running command manually
fn_alert_stopped() {
	fn_script_log_info "Sending alert: Stopped"
	alertsubject="Alert - ${selfname} - Stopped"
	alertemoji="❌"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${selfname} has stopped"
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_started() {
	fn_script_log_info "Sending alert: Started"
	alertsubject="Alert - ${selfname} - Started"
	alertemoji="✅"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${selfname} has started"
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_restarted() {
	fn_script_log_info "Sending alert: Restarted"
	alertsubject="Alert - ${selfname} - Restarted"
	alertemoji="↺"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${selfname} has restarted"
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

# Failed monitor checks
fn_alert_monitor_session() {
	fn_script_log_info "Sending alert: Restarted: ${executable} not running"
	alertsubject="Alert - ${selfname} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerturl="not enabled"
	alertbody="${selfname} ${executable} not running"
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_monitor_query() {
	fn_script_log_info "Sending alert: Restarted: ${selfname}"
	alertsubject="Alert - ${selfname} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerturl="not enabled"
	alertbody="Unable to query: ${selfname}"
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

# Update alerts
fn_alert_update() {
	fn_script_log_info "Sending alert: Updated"
	alertsubject="Alert - ${selfname} - Updated"
	alertemoji="🎮"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${gamename} received update: ${remotebuildversion}"
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_check_update() {
	fn_script_log_info "Sending alert: Update available"
	alertsubject="Alert - ${selfname} - Update available"
	alertemoji="🎮"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${gamename} update available: ${remotebuildversion}"
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_permissions() {
	fn_script_log_info "Sending alert: Permissions error"
	alertsubject="Alert - ${selfname}: Permissions error"
	alertemoji="❗"
	alertsound="2"
	alerturl="not enabled"
	alertbody="${selfname} has permissions issues"
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_config() {
	fn_script_log_info "Sending alert: New _default.cfg"
	alertsubject="Alert - ${selfname} - New _default.cfg"
	alertemoji="🎮"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${selfname} has received a new _default.cfg. Check file for changes."
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_wipe() {
	fn_script_log_info "Sending alert: Wipe"
	alertsubject="Alert - ${selfname} - Wipe"
	alertemoji="🧹"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${selfname} has been wiped"
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_info() {
	fn_script_log_info "Sending alert: Info"
	alertsubject="Alert - ${selfname} - Info"
	alertemoji="📄"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${selfname} info"
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

if [ "${alert}" == "permissions" ]; then
	fn_alert_permissions
elif [ "${alert}" == "monitor-session" ]; then
	fn_alert_monitor_session
elif [ "${alert}" == "monitor-query" ]; then
	fn_alert_monitor_query
elif [ "${alert}" == "test" ]; then
	fn_alert_test
elif [ "${alert}" == "update" ]; then
	fn_alert_update
elif [ "${alert}" == "check-update" ]; then
	fn_alert_check_update
elif [ "${alert}" == "update-restart" ]; then
	fn_alert_update_restart
elif [ "${alert}" == "config" ]; then
	fn_alert_config
elif [ "${alert}" == "wipe" ]; then
	fn_alert_wipe
fi

# Generate alert log.
fn_alert_log

# Generates the more info link.
if [ "${postalert}" == "on" ] && [ -n "${postalert}" ]; then
	exitbypass=1
	command_postdetails.sh
	fn_firstcommand_reset
	unset exitbypass
elif [ "${postalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "More Info not enabled"
	fn_script_log_warn "More Info alerts not enabled"
fi

if [ "${discordalert}" == "on" ] && [ -n "${discordalert}" ]; then
	alert_discord.sh
elif [ "${discordalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Discord alerts not enabled"
	fn_script_log_warn "Discord alerts not enabled"
elif [ -z "${discordtoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Discord token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/discord"
	fn_script_error "Discord token not set"
fi

if [ "${emailalert}" == "on" ] && [ -n "${email}" ]; then
	alert_email.sh
elif [ "${emailalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Email alerts not enabled"
	fn_script_log_warn "Email alerts not enabled"
elif [ -z "${email}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Email not set"
	fn_script_log_error "Email not set"
fi

if [ "${gotifyalert}" == "on" ] && [ -n "${gotifyalert}" ]; then
	alert_gotify.sh
elif [ "${gotifyalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Gotify alerts not enabled"
	fn_script_log_warn "Gotify alerts not enabled"
elif [ -z "${gotifytoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Gotify token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/gotify"
	fn_script_error "Gotify token not set"
elif [ -z "${gotifywebhook}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Gotify webhook not set"
	echo -e "* https://docs.linuxgsm.com/alerts/gotify"
	fn_script_error "Gotify webhook not set"
fi

if [ "${iftttalert}" == "on" ] && [ -n "${iftttalert}" ]; then
	alert_ifttt.sh
elif [ "${iftttalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "IFTTT alerts not enabled"
	fn_script_log_warn "IFTTT alerts not enabled"
elif [ -z "${ifttttoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "IFTTT token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/ifttt"
	fn_script_error "IFTTT token not set"
fi

if [ "${pushbulletalert}" == "on" ] && [ -n "${pushbullettoken}" ]; then
	alert_pushbullet.sh
elif [ "${pushbulletalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Pushbullet alerts not enabled"
	fn_script_log_warn "Pushbullet alerts not enabled"
elif [ -z "${pushbullettoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Pushbullet token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/pushbullet"
	fn_script_error "Pushbullet token not set"
fi

if [ "${pushoveralert}" == "on" ] && [ -n "${pushoveralert}" ]; then
	alert_pushover.sh
elif [ "${pushoveralert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Pushover alerts not enabled"
	fn_script_log_warn "Pushover alerts not enabled"
elif [ -z "${pushovertoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Pushover token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/pushover"
	fn_script_error "Pushover token not set"
fi

if [ "${telegramalert}" == "on" ] && [ -n "${telegramtoken}" ]; then
	alert_telegram.sh
elif [ "${telegramalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Telegram Messages not enabled"
	fn_script_log_warn "Telegram Messages not enabled"
elif [ -z "${telegramtoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Telegram token not set."
	echo -e "* https://docs.linuxgsm.com/alerts/telegram"
	fn_script_error "Telegram token not set."
elif [ -z "${telegramchatid}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Telegram chat id not set."
	echo -e "* https://docs.linuxgsm.com/alerts/telegram"
	fn_script_error "Telegram chat id not set."
fi

if [ "${rocketchatalert}" == "on" ] && [ -n "${rocketchatalert}" ]; then
	alert_rocketchat.sh
elif [ "${rocketchatalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Rocketchat alerts not enabled"
	fn_script_log_warn "Rocketchat alerts not enabled"
elif [ -z "${rocketchattoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Rocketchat token not set"
	#echo -e "* https://docs.linuxgsm.com/alerts/slack"
	fn_script_error "Rocketchat token not set"
fi

if [ "${slackalert}" == "on" ] && [ -n "${slackalert}" ]; then
	alert_slack.sh
elif [ "${slackalert}" != "on" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Slack alerts not enabled"
	fn_script_log_warn "Slack alerts not enabled"
elif [ -z "${slacktoken}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Slack token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/slack"
	fn_script_error "Slack token not set"
fi
