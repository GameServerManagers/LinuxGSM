#!/bin/bash
# LGSM install_dependency.sh function
# Author: Jared Ballou
# Website: http://gameservermanagers.com
lgsm_version="260116"

fn_add_game_dependency() {
	# If the directory doesn't yet exist, exit the function.
	# This is so that we wait until the game is installed before putting these files in place
	if [ ! -e "${dependency_path}" ]; then
		return
	fi

	filename="${1}"
	md5sum="${2}"
	remote_path="dependencies/${filename}.${md5sum}"
	local_path="${dependency_path}/${filename}"
	local_md5="$(md5sum "${local_path}" | awk '{print $1}')"
	echo "Checking ${filename} for ${md5sum}"
	if [ "${local_md5}" != "${md5sum}" ]; then
		fn_getgithubfile "${local_path}" 0 "${remote_path}" 1
	fi
#"${function_selfname}" == "command_install.sh"
}
