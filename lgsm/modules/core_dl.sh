#!/bin/bash
# LinuxGSM core_dl.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Deals with all downloads for LinuxGSM.

# remote_fileurl: The URL of the file: http://example.com/dl/File.tar.bz2
# local_filedir: location the file is to be saved: /home/server/lgsm/tmp
# local_filename: name of file (this can be different from the url name): file.tar.bz2
# chmodx: Optional, set to "chmodx" to make file executable using chmod +x
# run: Optional, set run to execute the file after download
# forcedl: Optional, force re-download of file even if exists
# hash: Optional, set an hash sum and will compare it against the file.
#
# Downloads can be defined in code like so:
# fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
# fn_fetch_file "http://example.com/file.tar.bz2" "http://example.com/file2.tar.bz2" "file.tar.bz2" "file2.tar.bz2" "/some/dir" "file.tar.bz2" "chmodx" "run" "forcedl" "10cd7353aa9d758a075c600a6dd193fd"

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_dl_steamcmd() {
	fn_print_start_nl "${remotelocation}"
	fn_script_log_info "${commandaction} ${selfname}: ${remotelocation}"
	if [ -n "${branch}" ]; then
		echo -e "Branch: ${branch}"
		fn_script_log_info "Branch: ${branch}"
	fi
	if [ -n "${betapassword}" ]; then
		echo -e "Branch password: ${betapassword}"
		fn_script_log_info "Branch password: ${betapassword}"
	fi
	if [ -d "${steamcmddir}" ]; then
		cd "${steamcmddir}" || exit
	fi

	# Unbuffer will allow the output of steamcmd not buffer allowing a smooth output.
	# unbuffer us part of the expect package.
	if [ "$(command -v unbuffer 2> /dev/null)" ]; then
		unbuffer="unbuffer"
	fi

	# Validate will be added as a parameter if required.
	if [ "${commandname}" == "VALIDATE" ] || [ "${commandname}" == "INSTALL" ]; then
		validate="validate"
	fi

	# To do error checking for SteamCMD the output of steamcmd will be saved to a log.
	steamcmdlog="${lgsmlogdir}/${selfname}-steamcmd.log"

	# clear previous steamcmd log
	if [ -f "${steamcmdlog}" ]; then
		rm -f "${steamcmdlog:?}"
	fi
	counter=0
	while [ "${counter}" == "0" ] || [ "${exitcode}" != "0" ]; do
		counter=$((counter + 1))
		# Select SteamCMD parameters
		# If GoldSrc (appid 90) servers. GoldSrc (appid 90) require extra commands.
		if [ "${appid}" == "90" ]; then
			# If using a specific branch.
			if [ -n "${branch}" ] && [ -n "${betapassword}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" -betapassword "${betapassword}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			elif [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_set_config 90 mod "${appidmod}" +app_update "${appid}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		# Force Windows Platform type.
		elif [ "${steamcmdforcewindows}" == "yes" ]; then
			if [ -n "${branch}" ] && [ -n "${betapassword}" ]; then
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" -betapassword "${betapassword}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			elif [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +@sSteamCmdForcePlatformType windows +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		# All other servers.
		else
			if [ -n "${branch}" ] && [ -n "${betapassword}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" -betapassword "${betapassword}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			elif [ -n "${branch}" ]; then
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" -beta "${branch}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			else
				${unbuffer} ${steamcmdcommand} +force_install_dir "${serverfiles}" +login "${steamuser}" "${steampass}" +app_update "${appid}" ${validate} +quit | uniq | tee -a "${lgsmlog}" "${steamcmdlog}"
			fi
		fi

		# Error checking for SteamCMD. Some errors will loop to try again and some will just exit.
		# Check also if we have more errors than retries to be sure that we do not loop to many times and error out.
		exitcode=$?
		if [ -n "$(grep -i "Error!" "${steamcmdlog}" | tail -1)" ] && [ "$(grep -ic "Error!" "${steamcmdlog}")" -ge "${counter}" ]; then
			# Not enough space.
			if [ -n "$(grep "0x202" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download server files"
				fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download server files"
				core_exit.sh
				# Not enough space.
			elif [ -n "$(grep "0x212" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download server files"
				fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: Not enough disk space to download server files"
				core_exit.sh
			# Need tp purchase game.
			elif [ -n "$(grep "No subscription" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Steam account does not have a license for the required game"
				fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: Steam account does not have a license for the required game"
				core_exit.sh
			# Two-factor authentication failure
			elif [ -n "$(grep "Two-factor code mismatch" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Two-factor authentication failure"
				fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: Two-factor authentication failure"
				core_exit.sh
			# Incorrect Branch password
			elif [ -n "$(grep "Password check for AppId" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: betapassword is incorrect"
				fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: betapassword is incorrect"
				core_exit.sh
			# Update did not finish.
			elif [ -n "$(grep "0x402" "${steamcmdlog}" | tail -1)" ] || [ -n "$(grep "0x602" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Update required but not completed - check network"
				fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Update required but not completed - check network"
			# Disk write failure.
			elif [ -n "$(grep "0x606" "${steamcmdlog}" | tail -1)" ] || [ -n "$(grep "0x602" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Disk write failure"
				fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Disk write failure"
			# Missing update files.
			elif [ -n "$(grep "0x626" "${steamcmdlog}" | tail -1)" ] || [ -n "$(grep "0x626" "${steamcmdlog}" | tail -1)" ]; then
				fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Missing update files"
				fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Missing update files"
			else
				fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Unknown error occured"
				echo -en "Please provide content log to LinuxGSM developers https://linuxgsm.com/steamcmd-error"
				fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Unknown error occured"
			fi
		elif [ "${exitcode}" != 0 ]; then
			fn_print_error2_nl "${commandaction} ${selfname}: ${remotelocation}: Exit code: ${exitcode}"
			fn_script_log_error "${commandaction} ${selfname}: ${remotelocation}: Exit code: ${exitcode}"
		else
			fn_print_complete_nl "${commandaction} ${selfname}: ${remotelocation}"
			fn_script_log_pass "${commandaction} ${selfname}: ${remotelocation}"
		fi

		if [ "${counter}" -gt "10" ]; then
			fn_print_failure_nl "${commandaction} ${selfname}: ${remotelocation}: Did not complete the download, too many retrys"
			fn_script_log_fail "${commandaction} ${selfname}: ${remotelocation}: Did not complete the download, too many retrys"
			core_exit.sh
		fi
	done
}

# Emptys contents of the LinuxGSM tmpdir.
fn_clear_tmp() {
	echo -en "clearing LinuxGSM tmp directory..."
	if [ -d "${tmpdir}" ]; then
		rm -rf "${tmpdir:?}/"*
		local exitcode=$?
		if [ "${exitcode}" != 0 ]; then
			fn_print_error_eol_nl
			fn_script_log_error "clearing LinuxGSM tmp directory"
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "clearing LinuxGSM tmp directory"
		fi
	fi
}

fn_dl_hash() {
	# Runs Hash Check if available.
	if [ "${hash}" != "0" ] && [ "${hash}" != "nohash" ] && [ "${hash}" != "nomd5" ]; then
		# MD5
		if [ "${#hash}" == "32" ]; then
			hashbin="md5sum"
			hashtype="MD5"
		# SHA1
		elif [ "${#hash}" == "40" ]; then
			hashbin="sha1sum"
			hashtype="SHA1"
		# SHA256
		elif [ "${#hash}" == "64" ]; then
			hashbin="sha256sum"
			hashtype="SHA256"
		# SHA512
		elif [ "${#hash}" == "128" ]; then
			hashbin="sha512sum"
			hashtype="SHA512"
		else
			fn_script_log_error "hash lengh not known for hash type"
			fn_print_error_nl "hash lengh not known for hash type"
			core_exit.sh
		fi
		echo -en "verifying ${local_filename} with ${hashtype}..."
		fn_sleep_time
		hashsumcmd=$(${hashbin} "${local_filedir}/${local_filename}" | awk '{print $1}')
		if [ "${hashsumcmd}" != "${hash}" ]; then
			fn_print_fail_eol_nl
			echo -e "${local_filename} returned ${hashtype} checksum: ${hashsumcmd}"
			echo -e "expected ${hashtype} checksum: ${hash}"
			fn_script_log_fail "Verifying ${local_filename} with ${hashtype}"
			fn_script_log_info "${local_filename} returned ${hashtype} checksum: ${hashsumcmd}"
			fn_script_log_info "Expected ${hashtype} checksum: ${hash}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Verifying ${local_filename} with ${hashtype}"
			fn_script_log_info "${local_filename} returned ${hashtype} checksum: ${hashsumcmd}"
			fn_script_log_info "Expected ${hashtype} checksum: ${hash}"
		fi
	fi
}

# Extracts bzip2, gzip or zip files.
# Extracts can be defined in code like so:
# fn_dl_extract "${local_filedir}" "${local_filename}" "${extractdest}" "${extractsrc}"
# fn_dl_extract "/home/gameserver/lgsm/tmp" "file.tar.bz2" "/home/gamserver/serverfiles"
fn_dl_extract() {
	local_filedir="${1}"
	local_filename="${2}"
	extractdest="${3}"
	extractsrc="${4}"
	# Extracts archives.
	echo -en "extracting ${local_filename}..."

	if [ ! -d "${extractdest}" ]; then
		mkdir "${extractdest}"
	fi
	if [ ! -f "${local_filedir}/${local_filename}" ]; then
		fn_print_fail_eol_nl
		echo -en "file ${local_filedir}/${local_filename} not found"
		fn_script_log_fail "Extracting ${local_filename}"
		fn_script_log_fail "File ${local_filedir}/${local_filename} not found"
		core_exit.sh
	fi
	mime=$(file -b --mime-type "${local_filedir}/${local_filename}")
	if [ "${mime}" == "application/gzip" ] || [ "${mime}" == "application/x-gzip" ]; then
		if [ -n "${extractsrc}" ]; then
			extractcmd=$(tar -zxf "${local_filedir}/${local_filename}" -C "${extractdest}" --strip-components=1 "${extractsrc}")
		else
			extractcmd=$(tar -zxf "${local_filedir}/${local_filename}" -C "${extractdest}")
		fi
	elif [ "${mime}" == "application/x-bzip2" ]; then
		if [ -n "${extractsrc}" ]; then
			extractcmd=$(tar -jxf "${local_filedir}/${local_filename}" -C "${extractdest}" --strip-components=1 "${extractsrc}")
		else
			extractcmd=$(tar -jxf "${local_filedir}/${local_filename}" -C "${extractdest}")
		fi
	elif [ "${mime}" == "application/x-xz" ]; then
		if [ -n "${extractsrc}" ]; then
			extractcmd=$(tar -Jxf "${local_filedir}/${local_filename}" -C "${extractdest}" --strip-components=1 "${extractsrc}")
		else
			extractcmd=$(tar -Jxf "${local_filedir}/${local_filename}" -C "${extractdest}")
		fi
	elif [ "${mime}" == "application/zip" ]; then
		if [ -n "${extractsrc}" ]; then
			temp_extractdir="${tmpdir}/Xonotic"
			extractcmd=$(unzip -qo "${local_filedir}/${local_filename}" "${extractsrc}/*" -d "${temp_extractdir}")
			find "${temp_extractdir}/${extractsrc}" -mindepth 1 -maxdepth 1 -exec mv -t "${extractdest}" {} +
			rm -rf "${temp_extractdir}"
		else
			extractcmd=$(unzip -qo -d "${extractdest}" "${local_filedir}/${local_filename}")
		fi
	fi
	local exitcode=$?
	if [ "${exitcode}" != 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fail "Extracting ${local_filename}"
		if [ -f "${lgsmlog}" ]; then
			echo -e "${extractcmd}" >> "${lgsmlog}"
		fi
		echo -e "${extractcmd}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Extracting ${local_filename}"
	fi
}

# Trap to remove file download if canceled before completed.
fn_fetch_trap() {
	echo -e ""
	echo -en "downloading ${local_filename}..."
	fn_print_canceled_eol_nl
	fn_script_log_info "Downloading ${local_filename}...CANCELED"
	rm -f "${local_filedir:?}/${local_filename}"
	echo -en "downloading ${local_filename}..."
	fn_print_removed_eol_nl
	fn_script_log_info "Downloading ${local_filename}...REMOVED"
	core_exit.sh
}

# Will check a file exists and download it. Will not exit if fails to download.
fn_check_file() {
	remote_fileurl="${1}"
	remote_fileurl_backup="${2}"
	remote_fileurl_name="${3}"
	remote_fileurl_backup_name="${4}"
	remote_filename="${5}"
	# If backup fileurl exists include it.
	if [ -n "${remote_fileurl_backup}" ]; then
		# counter set to 0 to allow second try
		counter=0
		remote_fileurls_array=(remote_fileurl remote_fileurl_backup)
	else
		# counter set to 1 to not allow second try
		counter=1
		remote_fileurls_array=(remote_fileurl)
	fi
	for remote_fileurl_array in "${remote_fileurls_array[@]}"; do
		if [ "${remote_fileurl_array}" == "remote_fileurl" ]; then
			fileurl="${remote_fileurl}"
			fileurl_name="${remote_fileurl_name}"
		elif [ "${remote_fileurl_array}" == "remote_fileurl_backup" ]; then
			fileurl="${remote_fileurl_backup}"
			fileurl_name="${remote_fileurl_backup_name}"
		fi
		counter=$((counter + 1))
		echo -en "checking ${fileurl_name} ${remote_filename}...\c"
		curlcmd=$(curl --output /dev/null --silent --head --fail "${fileurl}" 2>&1)
		local exitcode=$?

		# On first try will error. On second try will fail.
		if [ "${exitcode}" != 0 ]; then
			if [ ${counter} -ge 2 ]; then
				fn_print_fail_eol_nl
				if [ -f "${lgsmlog}" ]; then
					fn_script_log_fail "Checking ${remote_filename}"
					fn_script_log_fail "${fileurl}"
					checkflag=1
				fi
			else
				fn_print_error_eol_nl
				if [ -f "${lgsmlog}" ]; then
					fn_script_log_error "Checking ${remote_filename}"
					fn_script_log_error "${fileurl}"
					checkflag=2
				fi
			fi
		else
			fn_print_ok_eol
			echo -en "\033[2K\\r"
			if [ -f "${lgsmlog}" ]; then
				fn_script_log_pass "Checking ${remote_filename}"
				checkflag=0
			fi
			break
		fi
	done

	if [ -f "${local_filedir}/${local_filename}" ]; then
		fn_dl_hash
		# Execute file if run is set.
		if [ "${run}" == "run" ]; then
			# shellcheck source=/dev/null
			source "${local_filedir}/${local_filename}"
		fi
	fi
}

fn_fetch_file() {
	remote_fileurl="${1}"
	remote_fileurl_backup="${2}"
	remote_fileurl_name="${3}"
	remote_fileurl_backup_name="${4}"
	local_filedir="${5}"
	local_filename="${6}"
	chmodx="${7:-0}"
	run="${8:-0}"
	forcedl="${9:-0}"
	hash="${10:-0}"

	# Download file if missing or download forced.
	if [ ! -f "${local_filedir}/${local_filename}" ] || [ "${forcedl}" == "forcedl" ]; then
		# If backup fileurl exists include it.
		if [ -n "${remote_fileurl_backup}" ]; then
			# counter set to 0 to allow second try
			counter=0
			remote_fileurls_array=(remote_fileurl remote_fileurl_backup)
		else
			# counter set to 1 to not allow second try
			counter=1
			remote_fileurls_array=(remote_fileurl)
		fi
		for remote_fileurl_array in "${remote_fileurls_array[@]}"; do
			if [ "${remote_fileurl_array}" == "remote_fileurl" ]; then
				fileurl="${remote_fileurl}"
				fileurl_name="${remote_fileurl_name}"
			elif [ "${remote_fileurl_array}" == "remote_fileurl_backup" ]; then
				fileurl="${remote_fileurl_backup}"
				fileurl_name="${remote_fileurl_backup_name}"
			fi
			counter=$((counter + 1))
			if [ ! -d "${local_filedir}" ]; then
				mkdir -p "${local_filedir}"
			fi
			# Trap will remove part downloaded files if canceled.
			trap fn_fetch_trap INT
			curlcmd=(curl --connect-timeout 3 --fail -L -o "${local_filedir}/${local_filename}" --retry 2 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.${randomint}.212 Safari/537.36")

			# if is large file show progress, else be silent
			local exitcode=""
			large_files=("bz2" "gz" "zip" "jar" "xz")
			if grep -qE "(^|\s)${local_filename##*.}(\s|$)" <<< "${large_files[@]}"; then
				echo -en "downloading ${local_filename}..."
				fn_sleep_time
				echo -en "\033[1K"
				"${curlcmd[@]}" --progress-bar "${fileurl}" 2>&1
				exitcode="$?"
			else
				echo -en "fetching ${fileurl_name} ${local_filename}...\c"
				"${curlcmd[@]}" --silent --show-error "${fileurl}" 2>&1
				exitcode="$?"
			fi

			# Download will fail if downloads a html file.
			if [ -f "${local_filedir}/${local_filename}" ]; then
				if head -n 1 "${local_filedir}/${local_filename}" | grep -q "DOCTYPE"; then
					rm "${local_filedir:?}/${local_filename:?}"
					local exitcode=2
				fi
			fi

			# On first try will error. On second try will fail.
			if [ "${exitcode}" != 0 ]; then
				if [ ${counter} -ge 2 ]; then
					fn_print_fail_eol_nl
					if [ -f "${lgsmlog}" ]; then
						fn_script_log_fail "Downloading ${local_filename}..."
						fn_script_log_fail "${fileurl}"
					fi
					core_exit.sh
				else
					fn_print_error_eol_nl
					if [ -f "${lgsmlog}" ]; then
						fn_script_log_error "Downloading ${local_filename}..."
						fn_script_log_error "${fileurl}"
					fi
				fi
			else
				fn_print_ok_eol_nl
				if [ -f "${lgsmlog}" ]; then
					fn_script_log_pass "Downloading ${local_filename}..."
				fi

				# Make file executable if chmodx is set.
				if [ "${chmodx}" == "chmodx" ]; then
					chmod +x "${local_filedir}/${local_filename}"
				fi

				# Remove trap.
				trap - INT

				break
			fi
		done
	fi

	if [ -f "${local_filedir}/${local_filename}" ]; then
		fn_dl_hash
		# Execute file if run is set.
		if [ "${run}" == "run" ]; then
			# shellcheck source=/dev/null
			source "${local_filedir}/${local_filename}"
		fi
	fi
}

# GitHub file download modules.
# Used to simplify downloading specific files from GitHub.

# github_file_url_dir: the directory of the file in the GitHub: lgsm/modules
# github_file_url_name: the filename of the file to download from GitHub: core_messages.sh
# github_file_url_dir: the directory of the file in the GitHub: lgsm/modules
# github_file_url_name: the filename of the file to download from GitHub: core_messages.sh
# githuburl: the full GitHub url

# remote_fileurl: The URL of the file: http://example.com/dl/File.tar.bz2
# local_filedir: location the file is to be saved: /home/server/lgsm/tmp
# local_filename: name of file (this can be different from the url name): file.tar.bz2
# chmodx: Optional, set to "chmodx" to make file executable using chmod +x
# run: Optional, set run to execute the file after download
# forcedl: Optional, force re-download of file even if exists
# hash: Optional, set an hash sum and will compare it against the file.

# Fetches files from the Git repo.
fn_fetch_file_github() {
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${githubbranch}" == "master" ] && [ "${githubuser}" == "GameServerManagers" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="Bitbucket"
	local_filedir="${3}"
	local_filename="${github_file_url_name}"
	chmodx="${4:-0}"
	run="${5:-0}"
	forcedl="${6:-0}"
	hash="${7:-0}"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
}

fn_check_file_github() {
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	if [ "${githubbranch}" == "master" ] && [ "${githubuser}" == "GameServerManagers" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="Bitbucket"
	fn_check_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${github_file_url_name}"
}

# Fetches config files from the Git repo.
fn_fetch_config() {
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${githubbranch}" == "master" ] && [ "${githubuser}" == "GameServerManagers" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="Bitbucket"
	local_filedir="${3}"
	local_filename="${4}"
	chmodx="nochmodx"
	run="norun"
	forcedl="noforce"
	hash="nohash"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
}

# Fetches modules from the Git repo during first download.
fn_fetch_module() {
	github_file_url_dir="lgsm/modules"
	github_file_url_name="${modulefile}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${githubbranch}" == "master" ] && [ "${githubuser}" == "GameServerManagers" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="Bitbucket"
	local_filedir="${modulesdir}"
	local_filename="${github_file_url_name}"
	chmodx="chmodx"
	run="run"
	forcedl="noforce"
	hash="nohash"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"
}

# Fetches modules from the Git repo during update-lgsm.
fn_update_module() {
	github_file_url_dir="lgsm/modules"
	github_file_url_name="${modulefile}"
	# If master branch will currently running LinuxGSM version to prevent "version mixing". This is ignored if a fork.
	if [ "${githubbranch}" == "master" ] && [ "${githubuser}" == "GameServerManagers" ] && [ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="Bitbucket"
	local_filedir="${modulesdir}"
	local_filename="${github_file_url_name}"
	chmodx="chmodx"
	run="norun"
	forcedl="noforce"
	hash="nohash"
	# Passes vars to the file download module.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${hash}"

}

# Function to download latest github release.
# $1 GitHub user / organisation.
# $2 Repo name.
# $3 Destination for download.
# $4 Search string in releases (needed if there are more files that can be downloaded from the release pages).
fn_dl_latest_release_github() {
	local githubreleaseuser="${1}"
	local githubreleaserepo="${2}"
	local githubreleasedownloadpath="${3}"
	local githubreleasesearch="${4}"
	local githublatestreleaseurl="https://api.github.com/repos/${githubreleaseuser}/${githubreleaserepo}/releases/latest"

	# Get last github release.
	# If no search for the release filename is set, just get the first file from the latest release.
	if [ -z "${githubreleasesearch}" ]; then
		githubreleaseassets=$(curl -s "${githublatestreleaseurl}" | jq '[ .assets[] ]')
	else
		githubreleaseassets=$(curl -s "${githublatestreleaseurl}" | jq "[ .assets[]|select(.browser_download_url | contains(\"${githubreleasesearch}\")) ]")
	fi

	# Check how many releases we got from the api and exit if we have more then one.
	if [ "$(echo -e "${githubreleaseassets}" | jq '. | length')" -gt 1 ]; then
		fn_print_fatal_nl "Found more than one release to download - Please report this to the LinuxGSM issue tracker"
		fn_script_log_fail "Found more than one release to download - Please report this to the LinuxGSM issue tracker"
	else
		# Set variables for download via fn_fetch_file.
		githubreleasefilename=$(echo -e "${githubreleaseassets}" | jq -r '.[]name')
		githubreleasedownloadlink=$(echo -e "${githubreleaseassets}" | jq -r '.[]browser_download_url')

		# Error if no version is there.
		if [ -z "${githubreleasefilename}" ]; then
			fn_print_fail_nl "Cannot get version from GitHub API for ${githubreleaseuser}/${githubreleaserepo}"
			fn_script_log_fail "Cannot get version from GitHub API for ${githubreleaseuser}/${githubreleaserepo}"
		else
			# Fetch file from the remote location from the existing module to the ${tmpdir} for now.
			fn_fetch_file "${githubreleasedownloadlink}" "" "${githubreleasefilename}" "" "${githubreleasedownloadpath}" "${githubreleasefilename}"
		fi
	fi
}
