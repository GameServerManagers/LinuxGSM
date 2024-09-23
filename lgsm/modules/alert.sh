#!/bin/bash
# LinuxGSM alert.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
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
		fn_info_messages_head
		fn_info_messages_distro
		fn_info_messages_server_resource
		fn_info_messages_gameserver_resource
		fn_info_messages_gameserver
		fn_info_logs
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | tee -a "${alertlog}" > /dev/null 2>&1
}

fn_alert_test() {
	fn_script_log_info "Sending alert: Testing LinuxGSM Alert. No action to be taken"
	alertaction="Tested"
	alertemoji="🚧"
	alertsound="1"
	alertmessage="Testing ${selfname} LinuxGSM Alert. No action to be taken."
	# Green
	alertcolourhex="#cdcd00"
	alertcolourdec="13487360"
}

# Running command manually
fn_alert_stopped() {
	fn_script_log_info "Sending alert: ${selfname} has stopped"
	alertaction="Stopped"
	alertemoji="❌"
	alertsound="1"
	alertmessage="${selfname} has been stopped."
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_started() {
	fn_script_log_info "Sending alert: ${selfname} has started"
	alertaction="Started"
	alertemoji="✔️"
	alertsound="1"
	alertmessage="${selfname} has been started."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_restarted() {
	fn_script_log_info "Sending alert: ${selfname} has restarted"
	alertaction="Restarted"
	alertemoji="🗘"
	alertsound="1"
	alertmessage="${selfname} has been restarted."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

# Failed monitor checks
fn_alert_monitor_session() {
	fn_script_log_info "Sending alert: ${selfname} is not running. Game server has been restarted"
	alertaction="Restarted"
	alertemoji="🚨"
	alertsound="2"
	alertmessage="${selfname} is not running. Game server has been restarted."
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_monitor_query() {
	fn_script_log_info "Sending alert: Unable to query ${selfname}. Game server has been restarted"
	alertaction="Restarted"
	alertemoji="🚨"
	alertsound="2"
	alertmessage="Unable to query ${selfname}. Game server has been restarted."
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

# Update alerts
fn_alert_update() {
	fn_script_log_info "Sending alert: ${selfname} has received a game server update: ${localbuild}"
	alertaction="Updated"
	alertemoji="🎉"
	alertsound="1"
	alertmessage="${selfname} has received a game server update: ${localbuild}."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_update_request() {
	fn_script_log_info "Sending alert: ${selfname} has requested an update and needs to be restarted."
	alertaction="Updating"
	alertemoji="🎉"
	alertsound="1"
	alertmessage="${selfname} has requested an update and needs to be restarted."
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_check_update() {
	fn_script_log_info "Sending alert: ${gamename} update available: ${remotebuildversion}"
	alertaction="Update available"
	alertemoji="🎉"
	alertsound="1"
	alertmessage="${gamename} update available: ${remotebuildversion}"
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_update_linuxgsm() {
	fn_script_log_info "Sending alert: ${selfname} has received an LinuxGSM update"
	alertaction="Updated"
	alertemoji="🎉"
	alertsound="1"
	alertbody="${gamename} update available"
	alertmessage="${selfname} has received an LinuxGSM update and been restarted."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_backup() {
	fn_script_log_info "Sending alert: ${selfname} has been backed up"
	alertaction="Backed Up"
	alertemoji="📂"
	alertsound="1"
	alertmessage="${selfname} has been backed up."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_permissions() {
	fn_script_log_info "Sending alert: ${selfname} has permissions issues"
	alertaction="Checked Permissions"
	alertemoji="❗"
	alertsound="2"
	alertmessage="${selfname} has permissions issues."
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_config() {
	fn_script_log_info "Sending alert: ${selfname} has received a new _default.cfg"
	alertaction="Updated _default.cfg"
	alertemoji="🎉"
	alertsound="1"
	alertmessage="${selfname} has received a new _default.cfg."
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_wipe() {
	fn_script_log_info "Sending alert: ${selfname} has been wiped"
	alertaction="Wiped"
	alertemoji="🧹"
	alertsound="1"
	alertmessage="${selfname} has been wiped."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_info() {
	fn_script_log_info "Sending alert: ${selfname} info"
	alerttitle="LinuxGSM Alert - ${selfname} - Info"
	alertaction="Queried"
	alertemoji="📄"
	alertsound="1"
	alertmessage="${selfname} info."
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

# Images
alerticon="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/gameicons/${shortname}-icon.png"

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
elif [ "${alert}" == "update-request" ]; then
	fn_alert_update_request
elif [ "${alert}" == "check-update" ]; then
	fn_alert_check_update
elif [ "${alert}" == "config" ]; then
	fn_alert_config
elif [ "${alert}" == "wipe" ]; then
	fn_alert_wipe
elif [ "${alert}" == "info" ]; then
	fn_alert_info
elif [ "${alert}" == "started" ]; then
	fn_alert_started
elif [ "${alert}" == "stopped" ]; then
	fn_alert_stopped
elif [ "${alert}" == "restarted" ]; then
	fn_alert_restarted
elif [ "${alert}" == "update-linuxgsm" ]; then
	fn_alert_update_linuxgsm
elif [ "${alert}" == "backup" ]; then
	fn_alert_backup
else
	fn_print_fail_nl "Missing alert type"
	fn_script_log_fail "Missing alert type"
	core_exit.sh
fi

alerttitle="${alertemoji} ${alertaction} - ${servername} ${alertemoji}"

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
elif [ -z "${rocketchatwebhook}" ] && [ "${commandname}" == "TEST-ALERT" ]; then
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
