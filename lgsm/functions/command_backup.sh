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

# Trap to remove lockfile on quit.
fn_backup_trap(){
	echo ""
	echo -ne "backup ${backupname}.tar.gz..."
	fn_print_canceled_eol_nl
	fn_script_log_info "backup ${backupname}.tar.gz: CANCELED"
	sleep 1
	rm -f "${backupdir}/${backupname}.tar.gz" | tee -a "${scriptlog}"
	echo -ne "backup ${backupname}.tar.gz..."
	fn_print_removed_eol_nl
	fn_script_log_info "backup ${backupname}.tar.gz: REMOVED"
	# Remove lock file
	rm -f "${tmpdir}/.backup.lock"
	core_exit.sh
}

# Check if a backup is pending or has been aborted using .backup.lock
fn_backup_check_lockfile(){
	if [ -f "${tmpdir}/.backup.lock" ]; then
		fn_print_info_nl "Lock file found: Backup is currently running"
		fn_script_log_error "Lock file found: Backup is currently running: ${tmpdir}/.backup.lock"
		core_exit.sh
	fi
}

# Initialisation
fn_backup_init(){
	# Backup file name with servicename and current date
	backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"

	info_distro.sh
	fn_print_dots "Backup starting"
	fn_script_log_info "Backup starting"
	sleep 1
	fn_print_ok "Backup starting"
	sleep 1
	echo -ne "\n"
	if [ ! -d "${backupdir}" ]||[ "${backupcount}" == "0" ]; then
		fn_print_info_nl "There are no previous backups"
	else
		if [ "${lastbackupdaysago}" == "0" ]; then
			daysago="less than 1 day ago"
		elif [ "${lastbackupdaysago}" == "1" ]; then
			daysago="1 day ago"
		else
			daysago="${lastbackupdaysago} days ago"
		fi
		echo "	* Previous backup was created ${daysago}, total size ${lastbackupsize}"
		sleep 1
	fi
}


# Check if server is started and wether to stop it
fn_backup_stop_server(){
	check_status.sh
	# Server is stopped
	if [ "${status}" == "0" ]; then
		serverstopped="no"
	# Server is running and stoponbackup=off
	elif [ "${stoponbackup}" == "off" ]; then
		serverstopped="no"
		fn_print_warn_nl "${servicename} is currently running"
		echo "	* Although unlikely; creating a backup while ${servicename} is running might corrupt the backup."
		fn_script_log_warn "${servicename} is currently running"
		fn_script_log_warn "Although unlikely; creating a backup while ${servicename} is running might corrupt the backup"
	# Server is running and will be stopped if stoponbackup=on or unset
	else
		fn_print_warn_nl "${servicename} will be stopped during the backup"
		fn_script_log_warn "${servicename} will be stopped during the backup"
		sleep 4
		serverstopped="yes"
		exitbypass=1
		command_stop.sh
	fi
}

# Create required folders
fn_backup_dir(){
	# Create backupdir if it doesn't exist
	if [ ! -d "${backupdir}" ]; then
		mkdir -p "${backupdir}"
	fi
}

fn_backup_create_lockfile(){
	# Create lockfile
	date > "${tmpdir}/.backup.lock"
	fn_script_log_info "Lockfile generated"
	fn_script_log_info "${tmpdir}/.backup.lock"
	# trap to remove lockfile on quit.
	trap fn_backup_trap INT
}

# Compressing files
fn_backup_compression(){
	# Tells how much will be compressed using rootdirduexbackup value from info_distro and prompt for continue
	fn_print_info "A total of ${rootdirduexbackup} will be compressed."
	fn_script_log_info "A total of ${rootdirduexbackup} will be compressed: ${backupdir}/${backupname}.tar.gz"
	sleep 2
	fn_print_dots "Backup (${rootdirduexbackup}) ${backupname}.tar.gz, in progress..."
	fn_script_log_info "backup ${rootdirduexbackup} ${backupname}.tar.gz, in progress"
	tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
	local exitcode=$?
	if [ ${exitcode} -ne 0 ]; then
		fn_print_fail_eol
		fn_script_log_fatal "Backup in progress: FAIL"
		echo "${tarcmd}" | tee -a "${scriptlog}"
		fn_print_fail_nl "Starting backup"
		fn_script_log_fatal "Starting backup"
	else
		fn_print_ok_eol
		sleep 1
		fn_print_ok_nl "Completed: ${backupname}.tar.gz, total size $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}')"
		fn_script_log_pass "Backup created: ${backupname}.tar.gz, total size $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}')"
	fi
	# Remove lock file
	rm -f "${tmpdir}/.backup.lock"
}

# Clear old backups according to maxbackups and maxbackupdays variables
fn_backup_prune(){
	# Clear if backup variables are set
	if [ -n "${maxbackups}" ]&&[ -n "${maxbackupdays}" ]; then
		# How many backups there are
		info_distro.sh
		# How many backups exceed maxbackups
		backupquotadiff=$((backupcount-maxbackups))
		# How many backups exceed maxbackupdays
		backupsoudatedcount=$(find "${backupdir}"/ -type f -name "*.tar.gz" -mtime +"${maxbackupdays}"|wc -l)
		# If anything can be cleared
		if [ "${backupquotadiff}" -gt "0" ]||[ "${backupsoudatedcount}" -gt "0" ]; then
			fn_print_dots "Pruning"
			fn_script_log_info "Backup pruning activated"
			sleep 1
			fn_print_ok_nl "Pruning"
			sleep 1
			# If maxbackups greater or equal to backupsoutdatedcount, then it is over maxbackupdays
			if [ "${backupquotadiff}" -ge "${backupsoudatedcount}" ]; then
				# Display how many backups will be cleared
				echo "	* Pruning: ${backupquotadiff} backup(s) has exceeded the ${maxbackups} backups limit"
				fn_script_log_info "Pruning: ${backupquotadiff} backup(s) has exceeded the ${maxbackups} backups limit"
				sleep 1
				fn_print_dots "Pruning: Clearing ${backupquotadiff} backup(s)"
				fn_script_log_info "Pruning: Clearing ${backupquotadiff} backup(s)"
				sleep 1
				# Clear backups over quota
				find "${backupdir}"/ -type f -name "*.tar.gz" -printf '%T@ %p\n' | sort -rn | tail -${backupquotadiff} | cut -f2- -d" " | xargs rm
				fn_print_ok_nl "Pruning: Clearing ${backupquotadiff} backup(s)"
				fn_script_log_pass "Pruning: Cleared ${backupquotadiff} backup(s)"
			# If maxbackupdays is used over maxbackups
			elif [ "${backupquotadiff}" -lt "${backupsoudatedcount}" ]; then
				# Display how many backups will be cleared
				echo "	* Pruning: ${backupsoudatedcount} backup(s) are older than ${maxbackupdays} days."
				fn_script_log_info "Pruning: ${backupsoudatedcount} backup(s) older than ${maxbackupdays} days."
				sleep 1
				fn_print_dots "Pruning: Clearing ${backupquotadiff} backup(s)."
				fn_script_log_info "Pruning: Clearing ${backupquotadiff} backup(s)"
				sleep 1
				# Clear backups over quota
				find "${backupdir}"/ -type f -mtime +"${maxbackupdays}" -exec rm -f {} \;
				fn_print_ok_nl "Pruning: Clearing ${backupquotadiff} backup(s)"
				fn_script_log_pass "Pruning: Cleared ${backupquotadiff} backup(s)"
			fi
			sleep 1
		fi
	fi
}

# Restart the server if it was stopped for the backup
fn_backup_start_server(){
	if [ "${serverstopped}" == "yes" ]; then
		exitbypass=1
		command_start.sh
	fi
}

# Run functions
fn_backup_check_lockfile
fn_backup_create_lockfile
fn_backup_init
fn_backup_stop_server
fn_backup_dir
fn_backup_compression
fn_backup_prune
fn_backup_start_server
core_exit.sh
