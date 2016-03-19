#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="190316"

# Description: Creates a .tar.gz file in the backup directory.

local modulename="Backup"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
echo ""
fn_printinfonl "A total of $(du -sh "${rootdir}" --exclude="${backupdir}" | awk '{print $1}') will be compressed into the following backup:"
echo "${backupdir}/${backupname}.tar.gz"
echo ""
while true; do
	read -p "Continue? [y/N]" yn
	case $yn in
	[Yy]* ) break;;
	[Nn]* ) echo Exiting; return;;
	* ) echo "Please answer yes or no.";;
esac
done
echo ""
tmuxwc=$(tmux list-sessions 2>&1|awk '{print $1}'|grep -v failed|grep -Ec "^${servicename}:")
if [ "${tmuxwc}" -eq 1 ]; then
	echo ""
	fn_printwarningnl "${servicename} is currently running."
	sleep 1
	while true; do
		read -p "Stop ${servicename} while running the backup? [y/N]" yn
		case $yn in
		[Yy]* ) command_stop.sh; break;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi
fn_scriptlog "Started backup"
fn_printdots "Backup in progress, please wait..."
sleep 2
if [ ! -d "${backupdir}" ]; then
	mkdir "${backupdir}"
fi
tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
fn_printoknl "Backup created: ${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
fn_scriptlog "Complete, Backup created: ${backupdir}/${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
sleep 1
echo ""
