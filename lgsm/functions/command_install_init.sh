#!/usr/bin/env bash
commandname="INITSYSTEM"
commandaction="systemd service file"
functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

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
	fn_print_ok_nl "Generated the file contents"
	fn_print_information_nl "Enter the password of root:"
	su -c "echo \"$file_c\" > /usr/lib/systemd/system/${selfname}-lgsm.service" || return 1 && return 0
}

fn_install_systemd
if [ $? -eq 1 ]
then
	fn_print_error_nl "su exited with non 0 exit code.. something went wrong";
	fn_script_log_fatal "su exited with non 0 exit code."
else
	fn_print_complete_nl "Placed the file in /usr/lib/systemd/system/ as ${selfname}-lgsm.service"
	fn_print_information_nl "run \`systemctl enable ${selfname}-lgsm.service\`, to enable the game on boot"
	fn_script_log_pass "sucessfullly installed the systemd service file"
fi
core_exit.sh
