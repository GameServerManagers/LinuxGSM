#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Creates a .tar.gz file in the backup directory.

local commandname="BACKUP"
local commandaction="Backup"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
info_distro.sh
backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
fn_print_dots ""
sleep 0.5
fn_print_info_nl "A total of ${rootdirduexbackup} will be compressed into the following backup:"
echo "${backupdir}/${backupname}.tar.gz"
echo ""
while true; do
	read -e -i "y" -p "Continue? [Y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo Exiting; return;;
	* ) echo "Please answer yes or no.";;
esac
done
echo ""
check_status.sh
if [ "${status}" != "0" ]; then
	echo ""
	fn_print_warning_nl "${servicename} is currently running."
	sleep 1
	while true; do
		read -p "Stop ${servicename} while running the backup? [Y/N]" yn
		case $yn in
		[Yy]* ) command_stop.sh; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi

fn_print_dots "Backup in progress, please wait..."
fn_script_log_info "Started backup"
sleep 2
if [ ! -d "${backupdir}" ]; then
	mkdir "${backupdir}"
fi
tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
if [ $? == 0 ]; then
	fn_print_ok_nl "Backup created: ${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
	fn_script_log_pass "Backup created: ${backupdir}/${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
else
	fn_print_error_nl "Backup failed: ${backupname}.tar.gz"
	fn_script_log_error "Backup failed: ${backupname}.tar.gz"
fi
sleep 1
echo ""
core_exit.sh
