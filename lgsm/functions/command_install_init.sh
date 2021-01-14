#!/bin/bash
# LinuxGSM command_install_init.sh function
# Author: legendofmiracles
# Website: https://linuxgsm.com
# Description: Installs the service files for systemd in the correct place.
commandname="INITSYSTEM"
commandaction="systemd service file"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

fn_print_content_on_error() {
	fn_print_fail_nl "sudo exited with non 0 exit code - something went wrong"
	fn_print_information_nl "You can place the contents of the service file manually in $1"
	fn_print_information_nl "Contents: "
	printf "\n$2"
	exit 1
}

fn_install_systemd() {
	file_c=$'[Unit]
Description=LinuxGSM gamename Server
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=whoami
ExecStart=path start
ExecStop=path stop
Restart=no
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target'
	file_c=$(printf "$file_c" | sed s/'gamename'/$gamename/g | sed "s|path|$path|g" | sed s/'whoami'/$(whoami)/g)
	path="/etc/systemd/system/${selfname}-lgsm.service"
	fn_print_ok_nl "Generated the file contents"
	fn_print_information_nl "Enter the password of root: (only if you haven't this terminal in the past few minutes)"
	printf "$file_c" | sudo tee $path && return 0 || fn_print_content_on_error $path "$file_c"
}

fn_install_systemd
if [ $? -eq 1 ]
then
	fn_script_log_fatal "sudo exited with non 0 exit code."
else
	echo
	fn_print_complete_nl "Placed the file in /etc/systemd/system/ as ${selfname}-lgsm.service"
	fn_print_information_nl "run \`systemctl enable ${selfname}-lgsm.service\` (as root), to enable the game on boot"
	fn_script_log_pass "successfullly installed the systemd service file"
fi
core_exit.sh

