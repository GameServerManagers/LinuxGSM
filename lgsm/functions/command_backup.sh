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
fn_print_header
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
	echo ""
}


# Check if server is started and wether to shut it down
fn_backup_stop_server(){
	check_status.sh
	echo ""
	# Server is shut down
	if [ "${status}" == "0" ]; then
		serverstopped="no"
	# Server is up and shutdownonbackup is off
	elif [ "${shutdownonbackup}" == "off" ]; then
		serverstopped="no"
		fn_print_warning_nl "${servicename} is started and will not be stopped."
		fn_print_info_nl "It is advised to shutdown the server to prevent a file change during compression resulting in a tar error."
		fn_script_log_warn "${servicename} is started during the backup"
		fn_script_log_info "It is advised to shutdown the server to prevent a file change during compression resulting in a tar error."
	# Server is up and will be stopped if shutdownonbackup has no value or anything else than "off"
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
	if [ -n "${maxbackupdays}" ]; then
		# Count how many backups can be cleared
		backupclearcount=$(find "${backupdir}"/ -type f -mtime +"${maxbackupdays}"|wc -l)
		# Check if there is any backup to clear
		if [ "${backupclearcount}" -ne "0" ]; then
			fn_print_info_nl "${backupclearcount} backups older than ${maxbackupdays} days can be cleared."
			fn_script_log "${backupclearcount} backups older than ${maxbackupdays} days can be cleared"
			find "${backupdir}"/ -mtime +"${maxbackupdays}" -type f -exec rm -f {} \;
			fn_print_ok_nl "Cleared ${backupclearcount} backups."
			fn_script_log_pass "Cleared ${backupclearcount} backups"
		else
			fn_script_log "No backups older than ${maxbackupdays} days were found"
		fi
	else
		fn_script_log "No backups to clear since maxbackupdays variable is empty"
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
