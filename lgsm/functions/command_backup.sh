#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates a .tar.gz file in the backup directory.

local commandname="BACKUP"
local commandaction="Backup"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
fn_print_header
fn_script_log "Entering backup"
# Check if a backup is pending or has been aborted using .backup.lock
if [ -f "${tmpdir}/.backup.lock" ]; then
	fn_print_warning_nl "A backup is currently running or has been aborted."
	fn_script_log_warn "A backup is currently running or has been aborted."
	while true; do
		read -e -i "y" -p "Continue anyway? [Y/N]" yn
		case $yn in
		[Yy]* ) fn_script_log "User continues anyway"; break;;
		[Nn]* ) echo Exiting; fn_script_log "User aborted"; return;;
		* ) echo "Please answer yes or no.";;
	esac
	done
echo ""
fi
fn_print_dots ""
sleep 0.5
# Prepare backup file name with servicename current date
backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
# Tells how much will be compressed using rootdirduexbackup value from info_distro and prompt for continue
info_distro.sh
fn_print_info_nl "A total of ${rootdirduexbackup} will be compressed into the following backup:"
fn_script_log "A total of ${rootdirduexbackup} will be compressed into the following backup: ${backupdir}/${backupname}.tar.gz"
echo "${backupdir}/${backupname}.tar.gz"
echo ""
while true; do
	read -e -i "y" -p "Continue? [Y/n]" yn
	case $yn in
	[Yy]* ) fn_script_log "User validates"; break;;
	[Nn]* ) echo "Exiting"; fn_script_log "User aborted"; return;;
	* ) echo "Please answer yes or no.";;
esac
done

# Check if server is started
check_status.sh
if [ "${status}" != "0" ]; then
	echo ""
	fn_print_warning_nl "${servicename} is currently running."
	fn_script_log_warn "${servicename} is currently running."
	sleep 0.5
	while true; do
		read -e -i "n" -p "Stop ${servicename} while running the backup? [y/N]" yn
		case $yn in
		[Yy]* ) exitbypass=1; fn_script_log "User choose to stop the server"; command_stop.sh; serverstopped="yes"; break;;
		[Nn]* ) fn_script_log "User choose to not stop the server"; serverstopped="no"; break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi

fn_print_dots "Backup in progress, please wait..."
fn_script_log_info "Initiating backup"
sleep 0.5

# Directories creation
# Create backupdir if it doesn't exist
if [ ! -d "${backupdir}" ]; then
	fn_print_info_nl "Creating ${backupdir}"
	fn_script_log_info "Creating ${backupdir}"
	mkdir "${backupdir}"
fi
# Create tmpdir if it doesn't exist
if [ -n "${tmpdir}" ]&&[ ! -d "${tmpdir}" ]; then
	fn_print_info_nl "Creating ${tmpdir}"
	fn_script_log "Creating ${tmpdir}"
	mkdir -p "${tmpdir}"
fi
# Create lockfile
if [ -d "${tmpdir}" ]; then
	touch "${tmpdir}/.backup.lock"
	fn_script_log "Lockfile created"
fi

# Compressing files
fn_script_log "Compressing ${rootdirduexbackup}..."
tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
fn_script_log "Compression over."

# Remove lockfile
if [ -d "${tmpdir}" ]; then
	rm "${tmpdir}/.backup.lock"
	fn_script_log "Lockfile removed"
fi

# Check tar exit code and act accordingly
if [ $? == 0 ]; then
	# Exit code doesn't report any error
	fn_print_ok_nl "Backup created: ${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
	fn_script_log_pass "Backup created: ${backupdir}/${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
	
	# Clear old backups if backupdays variable exists
	if [ -n "${backupdays}" ]; then
		# Count how many backups can be cleared
		backupclearcount=$(find "${backupdir}"/ -type f -mtime +"${backupdays}"|wc -l)
		# Check if there is any backup to clear
		if [ "${backupclearcount}" -ne "0" ]; then
			fn_print_info_nl "${backupclearcount} backups older than ${backupdays} days can be cleared."
			fn_script_log "${backupclearcount} backups older than ${backupdays} days can be cleared."
			while true; do
				read -p -e"Clear older backups? [Y/N]" yn
				case $yn in
				[Yy]* ) clearoldbackups="yes"; break;;
				[Nn]* ) clearoldbackups="no"; fn_script_log "Not clearing backups"; break;;
				* ) echo "Please answer yes or no.";;
			esac
			done
			# If user wants to clear backups
			if [ "${clearoldbackups}" == "yes" ]; then
				find "${backupdir}"/ -mtime +"${backupdays}" -type f -exec rm -f {} \;
				fn_print_ok_nl "Cleared ${backupclearcount} backups."
				fn_script_log_pass "Cleared ${backupclearcount} backups."
			fi
		else
			fn_script_log "No backups older than ${backupdays} days were found."
		fi
	else
		fn_script_log "No backups to clear since backupdays variable is empty."
	fi
	# Restart the server if it was stopped for the backup
	if [ "${serverstopped}" == "yes" ]; then
		exitbypass=1
		command_start.sh
	fi
else
	# Exit code reports an error
	fn_print_error_nl "Backup failed: ${backupname}.tar.gz"
	fn_script_log_error "Backup failed: ${backupname}.tar.gz"
fi
sleep 0.5
core_exit.sh
