#!/bin/bash
# LinuxGSM command_toggle_cronjobs.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Install and Uninstall cronjobs automatically.

commandname="TOGGLE-CRONJOBS"
commandaction="Toggle cronjobs"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh

# Identifier for automatically added cronjobs
lgsmcomment="# added by LinuxGSM"

# Function to toggle a cronjob for the specified LinuxGSM command
fn_toggle_cronjob() {
    local lgsmcommandname=$1
    local jobschedule=$2

    local lgsmcommand="${rootdir}/${selfname} $lgsmcommandname"

	# TODO: Decide wether to log cronjob output to "${lgsmlogdir}/${lgsmcommandname}-cronjob.log" by default
    local outputlog="/dev/null" # Replace with to log cron output
	local errorlog="/dev/null" # Replace with a log file path to log cron errors

    local completejob="${jobschedule} ${lgsmcommand} > ${outputlog} 2> ${errorlog} ${lgsmcomment}"

    local currentcrontab
	currentcrontab=$(crontab -l 2>/dev/null)

	# If a cronjob for this LinuxGSM  command already exists
	# ! ($| ) is used to match the end of the line or a space after the command to avoid matching similar commands like ./gameserver update & ./gameserver update-lgsm
    if echo "$currentcrontab" | grep -Eq "${lgsmcommand}($| )"; then
        # If the existing cronjob was auto-added by LinuxGSM
        if echo "$currentcrontab" | grep -E "${lgsmcommand}($| )" | grep -q "${lgsmcomment}"; then
            # Remove the existing cronjob
            local newcrontab
			newcrontab=$(echo "$currentcrontab" | grep -Ev "${lgsmcommand}($| )")

			# Update the crontab to keep all cronjobs except the removed one
			# Check if the crontab was updated successfully
			if echo "$newcrontab" | crontab -; then
            	fn_print_ok_nl "Removed cronjob for '${lgsmcommand}'"
				fn_script_log_pass "Removed the auto-added cronjob for '${lgsmcommand}' from the crontab."
        	else
            	fn_print_fail_nl "Failed to remove cronjob for '${lgsmcommand}'"
            	fn_script_log_fail "Failed to remove cronjob for '${lgsmcommand}' from the crontab."
        	fi
        else
            # Job exists but was not auto-added by LinuxGSM, so skip
			fn_print_warn_nl "Cronjob for '${lgsmcommand}' already exists"
			fn_script_log_warn "A cronjob for '${lgsmcommand}' already exists but was not auto-added by LGSM."
        fi
    else
        # Add the job to the crontab while keeping existing cronjobs
		# Check if the crontab was updated successfully
		if printf "%s\n%s\n" "$currentcrontab" "$completejob" | crontab -; then
            fn_print_ok_nl "Added the cronjob for '${lgsmcommand}'"
            fn_script_log_pass "Added the cronjob for '${lgsmcommand}' to the crontab."
        else
            fn_print_fail_nl "Failed to add cronjob for '${lgsmcommand}'"
            fn_script_log_fail "Failed to add the cronjob for '${lgsmcommand}' to the crontab."
        fi
    fi
}

# Toggle cronjobs
fn_toggle_cronjob "monitor" "*/5 * * * *" # Every 5 minutes
fn_toggle_cronjob "update" "*/30 * * * *" # Every 30 minutes
fn_toggle_cronjob "update-lgsm" "0 0 * * *" # Daily at midnight
fn_toggle_cronjob "restart" "30 4 * * *" # Daily at 4:30am

core_exit.sh
