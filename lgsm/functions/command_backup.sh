#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Creates a .tar.gz file in the backup directory.

local commandname="BACKUP"
local commandaction="Backup"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
fn_script_log "Entering backup"

# Check if a backup is pending or has been aborted using .backup.lock
fn_check_pending_backup(){
	if [ -f "${tmpdir}/.backup.lock" ]; then
		fn_print_error "A backup is currently running or has been aborted."
		fn_print_info_nl "If you keep seing this message, remove the following file:"
		echo "${tmpdir}/.backup.lock"
		fn_script_log_fatal "A backup is currently running or has been aborted."
		fin_script_log_info "If you keep seing this message, remove the following file: ${tmpdir}/.backup.lock"
		core_exit.sh
	fi
}

# Initialization
fn_backup_init(){
	fn_print_dots ""
	sleep 0.5
	# Prepare backup file name with servicename current date
	backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
	# Tells how much will be compressed using rootdirduexbackup value from info_distro and prompt for continue
	info_distro.sh
	fn_print_info_nl "A total of ${rootdirduexbackup} will be compressed into the following backup:"
	fn_script_log "A total of ${rootdirduexbackup} will be compressed into the following backup: ${backupdir}/${backupname}.tar.gz"
	echo "${backupdir}/${backupname}.tar.gz"
}


# Check if server is started and wether to stop it
fn_backup_stop_server(){
	check_status.sh
	# Server is stopped
	if [ "${status}" == "0" ]; then
		serverstopped="no"
	# Server is up and stoponbackup is off
	elif [ "${stoponbackup}" == "off" ]; then
		serverstopped="no"
		fn_print_info_nl "${servicename} is started and will not be stopped."
		fn_print_information_nl "It is advised to stop the server to prevent a file changes and tar errors."
		fn_script_log_info "${servicename} is started during the backup"
		fn_script_log_info "It is advised to stop the server to prevent a file changes and tar errors."
	# Server is up and will be stopped if stoponbackup has no value or anything else than "off"
	else
		fn_print_warning_nl "${servicename} will be stopped during the backup."
		fn_script_log_warn "${servicename} will be stopped during the backup"
		sleep 4
		serverstopped="yes"
		exitbypass=1
		command_stop.sh
	fi
}

# Create required folders
fn_backup_directories(){
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
}

# Create lockfile
fn_backup_create_lockfile(){
if [ -d "${tmpdir}" ]; then
	touch "${tmpdir}/.backup.lock"
	fn_script_log "Lockfile created"
fi
}

# Compressing files
fn_backup_compression(){
fn_script_log "Compressing ${rootdirduexbackup}"
tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
fn_script_log "Compression over"
}

# Check tar exit code and set the result
fn_check_tar_exit(){
if [ $? == 0 ]; then
	backupresult="PASS"
else
	backupresult="FAIL"
fi
}

# Remove lockfile
fn_backup_remove_lockfile(){
if [ -d "${tmpdir}" ]&&[ -f "${tmpdir}/.backup.lock" ]; then
	rm "${tmpdir}/.backup.lock"
	fn_script_log "Lockfile removed"
fi
}

fn_backup_summary(){
	# when backupresult="PASS"
	if [ "${backupresult}" == "PASS" ]; then
		fn_print_ok_nl "Backup created: ${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
		fn_script_log_pass "Backup created: ${backupdir}/${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
	# When backupresult="FAIL"
	elif [ "${backupresult}" == "FAIL" ]; then
		fn_print_error_nl "Backup failed: ${backupname}.tar.gz"
		fn_script_log_error "Backup failed: ${backupname}.tar.gz"
		core_exit.sh
	else
		fn_print_error_nl "Could not determine compression result."
		fn_script_log_error "Could not determine compression result."
		core_exit.sh
	fi
}


# Clear old backups according to maxbackups and maxbackupdays variables
fn_backup_clearing(){
# How many backups there are
backupscount=$(find "${backupdir}/" -type f -name "*.tar.gz"|wc -l)
# How many backups exceed maxbackups
backupquotadiff=$((backupscount-maxbackups))
# How many backups exceed maxbackupdays
backupsoudatedcount=$(find "${backupdir}"/ -type f -name "*.tar.gz" -mtime +"${maxbackupdays}"|wc -l)
# If backup variables are set
if [ -n "${maxbackupdays}" ]&&[ -n "${maxbackups}" ]; then
	# If anything can be cleared
	if [ "${backupquotadiff}" -gt "0" ]||[ "${backupsoudatedcount}" -gt "0" ]; then
		# If maxbackups greater or equal than backupsoutdatedcount, then it is used over maxbackupdays
		if [ "${backupquotadiff}" -gt "${backupsoudatedcount}" ]||[ "${backupquotadiff}" -eq "${backupsoudatedcount}" ]; then
			# Display how many backups will be cleared
			fn_print_info_nl "${backupquotadiff} backup(s) exceed max ${maxbackups} and will be cleared."
			fn_script_log "${backupquotadiff} backup(s) exceed max ${maxbackups} and will be cleared"
			sleep 2
			# Clear over quota backups
			find "${backupdir}"/ -type f -name "*.tar.gz" -printf '%T@ %p\n' | sort -rn | tail -${backupquotadiff} | cut -f2- -d" " | xargs rm
			fn_print_ok_nl "Cleared ${backupquotadiff} backup(s)."
			fn_script_log "Cleared ${backupquotadiff} backup(s)"
		# If maxbackupdays is used over maxbackups
		elif [ "${backupquotadiff}" -lt "${backupsoudatedcount}" ]; then
			# Display how many backups will be cleared
			fn_print_info_nl "${backupsoudatedcount} backup(s) older than ${maxbackupdays} days will be cleared."
			fn_script_log "${backupsoudatedcount} backup(s) older than ${maxbackupdays} days will be cleared"
			find "${backupdir}"/ -mtime +"${maxbackupdays}" -type f -exec rm -f {} \;
			fn_print_ok_nl "Cleared ${backupsoudatedcount} backup(s)."
			fn_script_log_pass "Cleared ${backupsoudatedcount} backup(s)"
		else
			fn_script_log "No backups older than ${maxbackupdays} days were found"
		fi
	fi
else
	fn_script_log "No backups to clear since maxbackupdays and maxbackups variables are not set"
fi
}

# Restart the server if it was stopped for the backup
fn_backup_start_back(){
	if [ "${serverstopped}" == "yes" ]; then
		exitbypass=1
		command_start.sh
	fi
}

# Run functions
fn_check_pending_backup
fn_backup_init
fn_backup_stop_server
fn_backup_directories
fn_backup_create_lockfile
fn_backup_compression
fn_check_tar_exit
fn_backup_remove_lockfile
fn_backup_summary
fn_backup_clearing
fn_backup_start_back

sleep 0.5
core_exit.sh
