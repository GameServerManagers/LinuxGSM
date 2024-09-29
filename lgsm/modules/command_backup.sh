#!/bin/bash
# LinuxGSM command_backup.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Creates a .tar.gz file in the backup directory.

commandname="BACKUP"
commandaction="Backing up"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

# Trap to remove lockfile on quit.
fn_backup_trap() {
	echo -e ""
	echo -en "backup ${backupname}.tar.gz..."
	fn_print_canceled_eol_nl
	fn_script_log_info "Backup ${backupname}.tar.gz: CANCELED"
	rm -f "${backupdir:?}/${backupname}.tar.gz" | tee -a "${lgsmlog}"
	echo -en "backup ${backupname}.tar.gz..."
	fn_print_removed_eol_nl
	fn_script_log_info "Backup ${backupname}.tar.gz: REMOVED"
	# Remove backup lockfile.
	rm -f "${lockdir:?}/backup.lock"
	fn_backup_start_server
	unset exitbypass
	core_exit.sh
}

# Check if a backup is pending or has been aborted using backup.lock.
fn_backup_check_lockfile() {
	# Remove stale lockfile.
	if [ -f "${lockdir}/backup.lock" ]; then
		if [ "$(find "${lockdir}/backup.lock" -mmin +60)" ]; then
			fn_print_dots "Lockfile found: "
			fn_print_checking_eol
			fn_print_warn "Lockfile found: Removing stale lockfile: "
			fn_print_warn_eol
			fn_script_log_warn "Lockfile found: Removing stale lockfile"
			rm -f "${lockdir:?}/backup.lock"
		fi
	fi

	if [ -f "${lockdir}/backup.lock" ]; then
		fn_print_info_nl "Lockfile found: Backup is currently running"
		fn_script_log_error "Lockfile found: Backup is currently running: ${lockdir}/backup.lock"
		core_exit.sh
	fi
}

# Initialisation.
fn_backup_init() {
	# Backup file name with selfname and current date.
	backupname="${selfname}-$(date '+%Y-%m-%d-%H%M%S')"

	info_distro.sh
	fn_print_dots "Starting backup"
	fn_script_log_info "Starting backup"
	if [ ! -d "${backupdir}" ] || [ "${backupcount}" == "0" ]; then
		fn_print_info_nl "Starting backup: No previous backups found"
		fn_script_log_info "No previous backups found"
	else
		fn_print_info_nl "Starting backup: Previous backups found"
		fn_script_log_info "Previous backups found"
		if [ "${lastbackupdaysago}" == "0" ]; then
			daysago="less than 1 day ago"
		elif [ "${lastbackupdaysago}" == "1" ]; then
			daysago="1 day ago"
		else
			daysago="${lastbackupdaysago} days ago"
		fi
		echo -e "* Previous backup was created ${daysago}, total size ${lastbackupsize}"
	fi
}

# Check if server is started and whether to stop it.
fn_backup_stop_server() {
	check_status.sh
	# Server is running but will not be stopped.
	if [ "${stoponbackup}" == "off" ]; then
		fn_print_warn_nl "${selfname} is currently running"
		echo -e "* Although unlikely; creating a backup while ${selfname} is running might corrupt the backup."
		fn_script_log_warn "${selfname} is currently running"
		fn_script_log_warn "Although unlikely; creating a backup while ${selfname} is running might corrupt the backup"
	# Server is running and will be stopped if stoponbackup=on or unset.
	# If server is started
	elif [ "${status}" != "0" ]; then
		fn_print_restart_warning
		startserver="1"
		exitbypass=1
		command_stop.sh
		fn_firstcommand_reset
	fi
}

# Create required folders.
fn_backup_dir() {
	# Create backupdir if it doesn't exist.
	if [ ! -d "${backupdir}" ]; then
		mkdir -p "${backupdir}"
	fi
}

fn_backup_create_lockfile() {
	# Create lockfile.
	date '+%s' > "${lockdir:?}/backup.lock"
	fn_script_log_info "Backup lockfile generated"
	fn_script_log_info "${lockdir}/backup.lock"
	# trap to remove lockfile on quit.
	trap fn_backup_trap INT
}

# Compressing files.
fn_backup_compression() {
	# Tells how much will be compressed using rootdirduexbackup value from info_distro and prompt for continue.
	fn_print_info "A total of ${rootdirduexbackup} will be compressed."
	fn_script_log_info "A total of ${rootdirduexbackup} will be compressed: ${backupdir}/${backupname}.tar.gz"
	fn_print_dots "Backup (${rootdirduexbackup}) ${backupname}.tar.gz, in progress..."
	fn_script_log_info "Backup ${rootdirduexbackup} ${backupname}.tar.gz, in progress"
	excludedir=$(fn_backup_relpath)

	# Check that excludedir is a valid path.
	if [ ! -d "${excludedir}" ]; then
		fn_print_fail_nl "Problem identifying the previous backup directory for exclusion."
		fn_script_log_fail "Problem identifying the previous backup directory for exclusion"
		core_exit.sh
	fi

	tar --use-compress-program=pigz -cf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "${excludedir}" --exclude "${lockdir}" --exclude "${tmpdir}" ./.
	local exitcode=$?
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol
		fn_script_log_fail "Backup in progress: FAIL"
		echo -e "${extractcmd}" | tee -a "${lgsmlog}"
		fn_print_fail_nl "Starting backup"
		fn_script_log_fail "Starting backup"
	else
		fn_print_ok_eol
		fn_print_ok_nl "Completed: ${backupname}.tar.gz, total size $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}')"
		fn_script_log_pass "Backup created: ${backupname}.tar.gz, total size $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}')"
		alert="backup"
		alert.sh
	fi
}

# Clear old backups according to maxbackups and maxbackupdays variables.
fn_backup_prune() {
	# Clear if backup variables are set.
	if [ "${maxbackups}" ] && [ -n "${maxbackupdays}" ]; then
		# How many backups there are.
		info_distro.sh
		# How many backups exceed maxbackups.
		backupquotadiff=$((backupcount - maxbackups))
		# How many backups exceed maxbackupdays.
		backupsoudatedcount=$(find "${backupdir}"/ -type f -name "*.tar.gz" -mtime +"${maxbackupdays}" | wc -l)
		# If anything can be cleared.
		if [ "${backupquotadiff}" -gt "0" ] || [ "${backupsoudatedcount}" -gt "0" ]; then
			fn_print_dots "Pruning"
			fn_script_log_info "Backup pruning activated"
			fn_print_ok_nl "Pruning"
			# If maxbackups greater or equal to backupsoutdatedcount, then it is over maxbackupdays.
			if [ "${backupquotadiff}" -ge "${backupsoudatedcount}" ]; then
				# Display how many backups will be cleared.
				echo -e "* Pruning: ${backupquotadiff} backup(s) has exceeded the ${maxbackups} backups limit"
				fn_script_log_info "Pruning: ${backupquotadiff} backup(s) has exceeded the ${maxbackups} backups limit"
				fn_sleep_time_1
				fn_print_dots "Pruning: Clearing ${backupquotadiff} backup(s)"
				fn_script_log_info "Pruning: Clearing ${backupquotadiff} backup(s)"
				# Clear backups over quota.
				find "${backupdir}"/ -type f -name "*.tar.gz" -printf '%T@ %p\n' | sort -rn | tail -${backupquotadiff} | cut -f2- -d" " | xargs rm
				fn_print_ok_nl "Pruning: Clearing ${backupquotadiff} backup(s)"
				fn_script_log_pass "Pruning: Cleared ${backupquotadiff} backup(s)"
			# If maxbackupdays is used over maxbackups.
			elif [ "${backupquotadiff}" -lt "${backupsoudatedcount}" ]; then
				# Display how many backups will be cleared.
				echo -e "* Pruning: ${backupsoudatedcount} backup(s) are older than ${maxbackupdays} days."
				fn_script_log_info "Pruning: ${backupsoudatedcount} backup(s) older than ${maxbackupdays} days."
				fn_sleep_time_1
				fn_print_dots "Pruning: Clearing ${backupquotadiff} backup(s)."
				fn_script_log_info "Pruning: Clearing ${backupquotadiff} backup(s)"
				# Clear backups over quota
				find "${backupdir}"/ -type f -mtime +"${maxbackupdays}" -exec rm -f {} \;
				fn_print_ok_nl "Pruning: Clearing ${backupquotadiff} backup(s)"
				fn_script_log_pass "Pruning: Cleared ${backupquotadiff} backup(s)"
			fi
		fi
	fi
}

fn_backup_relpath() {
	# Written by CedarLUG as a "realpath --relative-to" alternative in bash.
	# Populate an array of tokens initialized from the rootdir components.
	declare -a rdirtoks=($(readlink -f "${rootdir}" | sed "s/\// /g"))
	if [ ${#rdirtoks[@]} -eq 0 ]; then
		fn_print_fail_nl "Problem assessing rootdir during relative path assessment"
		fn_script_log_fail "Problem assessing rootdir during relative path assessment: ${rootdir}"
		core_exit.sh
	fi

	# Populate an array of tokens initialized from the backupdir components.
	declare -a bdirtoks=($(readlink -f "${backupdir}" | sed "s/\// /g"))
	if [ ${#bdirtoks[@]} -eq 0 ]; then
		fn_print_fail_nl "Problem assessing backupdir during relative path assessment"
		fn_script_log_fail "Problem assessing backupdir during relative path assessment: ${rootdir}"
		core_exit.sh
	fi

	# Compare the leading entries of each array.  These common elements will be clipped off.
	# for the relative path output.
	for ((base = 0; base < ${#rdirtoks[@]}; base++)); do
		[[ "${rdirtoks[$base]}" != "${bdirtoks[$base]}" ]] && break
	done

	# Next, climb out of the remaining rootdir location with updir references.
	for ((x = base; x < ${#rdirtoks[@]}; x++)); do
		echo -n "../"
	done

	# Climb down the remaining components of the backupdir location.
	for ((x = base; x < $((${#bdirtoks[@]} - 1)); x++)); do
		echo -n "${bdirtoks[$x]}/"
	done

	# In the event there were no directories left in the backupdir above to
	# traverse down, just add a newline. Otherwise at this point, there is
	# one remaining directory component in the backupdir to navigate.
	if (("$base" < "${#bdirtoks[@]}")); then
		echo -e "${bdirtoks[$((${#bdirtoks[@]} - 1))]}"
	else
		echo
	fi
}

# Start the server if it was stopped for the backup.
fn_backup_start_server() {
	if [ -n "${startserver}" ]; then
		exitbypass=1
		command_start.sh
		fn_firstcommand_reset
	fi
}

fn_print_dots ""
check.sh
core_logs.sh

fn_backup_check_lockfile
fn_backup_init
fn_backup_stop_server
fn_backup_dir
fn_backup_create_lockfile
fn_backup_compression
fn_backup_prune
fn_backup_start_server

# Remove backup lockfile.
rm -f "${lockdir:?}/backup.lock"
core_exit.sh
