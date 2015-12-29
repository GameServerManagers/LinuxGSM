#!/bin/bash
# LGSM command_backup.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Description: Creates a .tar.gz file in the backup directory.

local modulename="Backup"
function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

check.sh
backupname="${servicename}-$(date '+%Y-%m-%d-%H%M%S')"
echo ""
echo "${gamename} Backup"
echo "============================"
echo ""
echo "The following backup will be created:"
echo ""
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
fn_scriptlog "Started"
echo -en "starting backup.\r"
sleep 1
echo -en "starting backup..\r"
sleep 1
echo -en "starting backup...\r"
sleep 1
echo -en "\n"
cd "${rootdir}"
if [ ! -d "${backupdir}" ]; then
	mkdir -v "${backupdir}"
fi
tar -cvzf "${backupdir}/${backupname}.tar.gz" --exclude "${backupdir}" ./*
echo ""
echo "Backup created: ${backupdir}/${backupname}.tar.gz"
fn_scriptlog "Created: ${backupdir}/${backupname}.tar.gz"
sleep 1
echo ""
fn_printcompletenl "Complete."
fn_scriptlog "Complete"
echo ""
