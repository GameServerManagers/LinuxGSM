#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Creates a .tar.gz file in the backup directory.

local modulename="Backup"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
command_execute.sh

backup_server(){

backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
echo ""
fn_print_info_nl "A total of $(du -sh "${rootdir}" --exclude="${backupdir}" | awk '{print $1}') will be compressed into the following backup:"
echo "${backupdir}/${backupname}.tar.gz"
echo ""
while true; do
	read -p "Continue? [Y/N]" yn
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
fn_scriptlog "Started backup"
fn_print_dots "Backup in progress, please wait..."
sleep 2
if [ ! -d "${backupdir}" ]; then
	mkdir "${backupdir}"
fi
tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
fn_print_ok_nl "Backup created: ${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
fn_scriptlog "Complete, Backup created: ${backupdir}/${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
sleep 1
echo ""
}

alert_backup(){

backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
echo ""
fn_print_info_nl "A total of $(du -sh "${rootdir}" --exclude="${backupdir}" | awk '{print $1}') will be compressed into the following backup:"
echo "${backupdir}/${backupname}.tar.gz"
echo ""
while true; do
	read -p "Continue? [Y/N]" yn
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
fn_scriptlog "Started backup"
fn_print_dots "Backup in progress, please wait..."
sleep 2
if [ ! -d "${backupdir}" ]; then
	mkdir "${backupdir}"
fi
begincount=$(date +"%s")
execute "${msg_type} Server backup started! PREPARE FOR LAG!"
tar -czf "${backupdir}/${backupname}.tar.gz" -C "${rootdir}" --exclude "backups" ./*
termincount=$(date +"%s")
difftimelps=$(($termincount-$begincount))
execute "${msg_type} Backup complete it took $(($difftimelps / 60)) minutes and $(($difftimelps % 60)) seconds!"
fn_print_ok_nl "Backup created: ${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
fn_scriptlog "Complete, Backup created: ${backupdir}/${backupname}.tar.gz is $(du -sh "${backupdir}/${backupname}.tar.gz" | awk '{print $1}') size"
sleep 1
echo ""

}

if [ "${backup_notification}" = "on" ]
	then
	alert_backup
else
	backup_server
	fi
