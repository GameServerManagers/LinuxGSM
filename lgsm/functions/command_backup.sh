#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates a .tar.gz file in the backup directory.

local commandname="BACKUP"
local commandaction="Backup"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
backuplock=
# Check if a backup is pending or has been aborted using .backup.lock
if [ -f "${tmpdir}/.backup.lock" ]; then
	fn_print_warning_nl "A backup is currently pending or has been aborted."
	while true; do
		read -e -i "y" -p "Continue anyway? [Y/N]" yn
		case $yn in
		[Yy]* ) break;;
		[Nn]* ) echo Exiting; return;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi
info_distro.sh
fn_print_dots ""
sleep 0.5
# Prepare backup file name with servicename current date
backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
# Tells how much will be compressed using rootdirduexbackup value from info_distro
fn_print_info_nl "A total of ${rootdirduexbackup} will be compressed into the following backup:"
echo "${backupdir}/${backupname}.tar.gz"
while true; do
	read -e -i "y" -p "Continue? [Y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo Exiting; return;;
	* ) echo "Please answer yes or no.";;
esac
done
check_status.sh
if [ "${status}" != "0" ]; then
	echo ""
	fn_print_warning_nl "${servicename} is currently running."
	sleep 1
	while true; do
		read -p "Stop ${servicename} while running the backup? [Y/N]" yn
		case $yn in
		[Yy]* ) command_stop.sh; serverstopped="yes"; break;;
		[Nn]* ) serverstopped="no"; break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi

fn_print_dots "Backup in progress, please wait..."
fn_script_log_info "Started backup"
sleep 1
if [ ! -d "${backupdir}" ]; then
	mkdir "${backupdir}"
fi
# Create lockfile
touch "${tmpdir}/.backup.lock"
# Compressing files
tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
# Remove lockfile
rm "${tmpdir}/.backup.lock"
# Check tar exit code and act accordingly
if [ $? == 0 ]; then
	fn_print_ok_nl "Backup created: ${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
	fn_script_log_pass "Backup created: ${backupdir}/${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
	
	# Clear old backups if backupdays variable exists
	if [ -n "${backupdays}" ]; then
		# Count how many backups can be cleared
		backupclearcount=$(find "${backupdir}"/ -type f -mtime +"${backupdays}"|wc -l)
		# Check if there is any backup to clear
		if [ "${backupclearcount}" -ne "0" ]; then
			fn_print_info_nl "${backupclearcount} backups older than ${backupdays} days can be cleared."
			while true; do
				read -p "Clear older backups? [Y/N]" yn
				case $yn in
				[Yy]* ) clearoldbackups="yes"; break;;
				[Nn]* ) clearoldbackups="no"; break;;
				* ) echo "Please answer yes or no.";;
			esac
			done
			# If user wants to clear backups
			if [ "${clearoldbackups}" == "yes" ]; then
				find "${backupdir}"/ -mtime +"${backupdays}" -type f -exec rm -f {} \;
				fn_print_ok_nl "Cleared ${backupclearcount} backups."
			fi
		fi
	fi
	# Restart the server if it was stopped for the backup
	if [ "${serverstopped}" == "yes" ]; then
		command_start.sh
	fi
else
	fn_print_error_nl "Backup failed: ${backupname}.tar.gz"
	fn_script_log_error "Backup failed: ${backupname}.tar.gz"
fi
sleep 0.5
core_exit.sh
