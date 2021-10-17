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
		fn_info_message_script
		fn_info_message_backup
		fn_info_message_commandlineparms
		fn_info_message_ports_edit
		fn_info_message_ports
		fn_info_logs
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${alertlog}" > /dev/null 2>&1
}

fn_alert_test(){
	fn_script_log_info "Sending test alert"
	alerttitle="Alert - ${selfname} - Test"
	alertemoji="🚧"
	alertsound="1"
	alerttriggermessage="Testing LinuxGSM Alert. No action to be taken."
	# Green
	alertcolourhex="#cdcd00"
	alertcolourdec="13487360"
}

fn_alert_restart(){
	fn_script_log_info "Sending alert: Restarted: ${selfname}, ${executable} is not running"
	alerttitle="Alert - ${selfname} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerttriggermessage="${selfname} is not running. Game Server has been restarted."
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_restart_query(){
	fn_script_log_info "Sending alert: Restarted: ${selfname}"
	alerttitle="Alert - ${selfname} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerttriggermessage="Unable to query ${selfname}. Game server has been restarted."
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_update(){
	fn_script_log_info "Sending alert: Updated: ${selfname}"
	alerttitle="Alert - ${selfname} - Updated"
	alertemoji="🎉"
	alertsound="1"
	alerttriggermessage="${selfname} has received an update."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

fn_alert_check_update(){
	fn_script_log_info "Sending alert: Update available"
	alerttitle="Alert - ${selfname} - Update available"
	alertemoji="💿"
	alertsound="1"
	alerttriggermessage="Update available for ${selfname}."
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_permissions(){
	fn_script_log_info "Sending alert: Permissions error"
	alerttitle="Alert - ${selfname}: Permissions error"
	alertemoji="❗"
	alertsound="2"
	alerttriggermessage="${selfname} has permissions issues."
	# Red
	alertcolourhex="#cd0000"
	alertcolourdec="13434880"
}

fn_alert_config(){
	fn_script_log_info "Sending alert: New _default.cfg"
	alerttitle="Alert - ${selfname} - New _default.cfg"
	alertemoji="📄"
	alertsound="1"
	alerttriggermessage="${selfname} has received a new _default.cfg. Check file for changes."
	# Blue
	alertcolourhex="#1e90ff"
	alertcolourdec="2003199"
}

fn_alert_wipe(){
	fn_script_log_info "Sending alert: Wiped: ${selfname} wiped"
	alerttitle="Alert - ${selfname} - Wiped"
	alertemoji="🧹"
	alertsound="1"
	alerttriggermessage="${selfname} as been wiped."
	# Green
	alertcolourhex="#00cd00"
	alertcolourdec="52480"
}

# Gather info required for alert.
info_distro.sh
info_game.sh
query_gamedig.sh

# Allow Alert to display gamedig info if available.
if [ "${querystatus}" != "0" ]; then
	if [ -n "${maxplayers}" ]; then
		alertplayerstitle="Maxplayers"
		alertplayers="${maxplayers}"
	fi
else
	if [ -n "${gdplayers}" ]&&[ -n "${gdmaxplayers}" ]; then
		alertplayerstitle="Current Players"
		alertplayers="${gdplayers}/${gdmaxplayers}"
	elif [ -n "${gdplayers}" ]&&[ -n "${maxplayers}" ]; then
		alertplayerstitle="Current Players"
		alertplayers="${gdplayers}/${maxplayers}"
	elif [ -z "${gdplayers}" ]&&[ -n "${gdmaxplayers}" ]; then
		alertplayerstitle="Current Players"
		alertplayers="-1/${gdmaxplayers}"
	elif [ -n "${gdplayers}" ]&&[ -z "${gdmaxplayers}" ]; then
		alertplayerstitle="Current Players"
		alertplayers="${gdplayers}/∞"
	elif [ -z "${gdplayers}" ]&&[ -z "${gdmaxplayers}" ]&&[ -n "${maxplayers}" ]; then
		alertplayerstitle="Maxplayers"
		alertplayers="${maxplayers}"
	fi
fi

if [ -z "${alertplayers}" ]; then
	alertplayerstitle="Current Players"
	alertplayers="Unknown"
fi

if [ -n "${gdmap}" ]; then
	alertmap="${gdmap}"
else
	alertmap="Unknown"
fi

if [ -n "${gdversion}" ]; then
	alertversion="${gdversion}"
else
	alertversion="Unknown"
fi

if [ "${postalert}" == "on" ]; then
	alertmoreinfo="More info"
fi

# Images
mapimagestatus="$(curl -o /dev/null -s -w "%{http_code}\n" https://raw.githubusercontent.com/${githubuser}/game-server-map-images/main/${shortname}/${alertmap}.jpg)"
if [ -n "${gdmap}" ]&&[ "${mapimagestatus}" == "200" ]; then
alertimage="https://raw.githubusercontent.com/${githubuser}/game-server-map-images/main/${shortname}/${gdmap}.jpg"
alertimagealt="${gdmap}"
elif [ -n "${appid}" ]; then
	alertimage="https://cdn.cloudflare.steamstatic.com/steam/apps/${gameappid}/header.jpg"
	alertimagealt="${gamename} header"
else
	alertimage="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/gameheaders/${shortname}-header.jpg"
	alertimagealt="${gamename} header"
fi
alerticon="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/lgsm/data/gameicons/${shortname}-icon.png"
alerticonalt="${gamename} icon"

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
elif [ "${alert}" == "wipe" ]; then
	fn_alert_wipe
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

if [ "${gotifyalert}" == "on" ]&&[ -n "${gotifyalert}" ]; then
	alert_gotify.sh
elif [ "${gotifyalert}" != "on" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_warn_nl "Gotify alerts not enabled"
	fn_script_log_warn "Gotify alerts not enabled"
elif [ -z "${gotifytoken}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Gotify token not set"
	echo -e "* https://docs.linuxgsm.com/alerts/gotify"
	fn_script_error "Gotify token not set"
elif [ -z "${gotifywebhook}" ]&&[ "${commandname}" == "TEST-ALERT" ]; then
	fn_print_error_nl "Gotify webhook not set"
	echo -e "* https://docs.linuxgsm.com/alerts/gotify"
	fn_script_error "Gotify webhook not set"
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
