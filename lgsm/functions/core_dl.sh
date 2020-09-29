#!/bin/bash
# LinuxGSM core_dl.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://linuxgsm.com
# Description: Deals with all downloads for LinuxGSM.

# remote_fileurl: The URL of the file: http://example.com/dl/File.tar.bz2
# local_filedir: location the file is to be saved: /home/server/lgsm/tmp
# local_filename: name of file (this can be different from the url name): file.tar.bz2
# chmodx: Optional, set to "chmodx" to make file executable using chmod +x
# run: Optional, set run to execute the file after download
# forcedl: Optional, force re-download of file even if exists
# md5: Optional, set an md5 sum and will compare it against the file.
#
# Downloads can be defined in code like so:
# fn_fetch_file "${remote_fileurl}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
# fn_fetch_file "http://example.com/file.tar.bz2" "/some/dir" "file.tar.bz2" "chmodx" "run" "forcedl" "10cd7353aa9d758a075c600a6dd193fd"

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Emptys contents of the LinuxGSM tmpdir.
fn_clear_tmp(){
	echo -en "clearing LinuxGSM tmp directory..."
	if [ -d "${tmpdir}" ]; then
		rm -rf "${tmpdir:?}/"*
		local exitcode=$?
		if [ ${exitcode} -eq 0 ]; then
			fn_print_ok_eol_nl
			fn_script_log_pass "clearing LinuxGSM tmp directory"
		else
			fn_print_error_eol_nl
			fn_script_log_error "clearing LinuxGSM tmp directory"
		fi
	fi
}

fn_dl_md5(){
	# Runs MD5 Check if available.
	if [ "${md5}" != "0" ]&&[ "${md5}" != "nomd5" ]; then
		echo -en "verifying ${local_filename} with MD5..."
		fn_sleep_time
		md5sumcmd=$(md5sum "${local_filedir}/${local_filename}"|awk '{print $1;}')
		if [ "${md5sumcmd}" != "${md5}" ]; then
			fn_print_fail_eol_nl
			echo -e "${local_filename} returned MD5 checksum: ${md5sumcmd}"
			echo -e "expected MD5 checksum: ${md5}"
			fn_script_log_fatal "Verifying ${local_filename} with MD5"
			fn_script_log_info "${local_filename} returned MD5 checksum: ${md5sumcmd}"
			fn_script_log_info "Expected MD5 checksum: ${md5}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Verifying ${local_filename} with MD5"
			fn_script_log_info "${local_filename} returned MD5 checksum: ${md5sumcmd}"
			fn_script_log_info "Expected MD5 checksum: ${md5}"
		fi
	fi
}

# Extracts bzip2, gzip or zip files.
# Extracts can be defined in code like so:
# fn_dl_extract "${local_filedir}" "${local_filename}" "${extractdir}"
# fn_dl_extract "/home/gameserver/lgsm/tmp" "file.tar.bz2" "/home/gamserver/serverfiles"
fn_dl_extract(){
	local_filedir="${1}"
	local_filename="${2}"
	extractdir="${3}"
	# Extracts archives.
	echo -en "extracting ${local_filename}..."
	mime=$(file -b --mime-type "${local_filedir}/${local_filename}")
	if [ ! -d "${extractdir}" ]; then
		mkdir "${extractdir}"
	fi
	if [ "${mime}" == "application/gzip" ]||[ "${mime}" == "application/x-gzip" ]; then
		extractcmd=$(tar -zxf "${local_filedir}/${local_filename}" -C "${extractdir}")
	elif [ "${mime}" == "application/x-bzip2" ]; then
		extractcmd=$(tar -jxf "${local_filedir}/${local_filename}" -C "${extractdir}")
	elif [ "${mime}" == "application/x-xz" ]; then
		extractcmd=$(tar -xf "${local_filedir}/${local_filename}" -C "${extractdir}")
	elif [ "${mime}" == "application/zip" ]; then
		extractcmd=$(unzip -qo -d "${extractdir}" "${local_filedir}/${local_filename}")
	fi
	local exitcode=$?
	if [ ${exitcode} -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "Extracting download"
		if [ -f "${lgsmlog}" ]; then
			echo -e "${extractcmd}" >> "${lgsmlog}"
		fi
		echo -e "${extractcmd}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
		fn_script_log_pass "Extracting download"
	fi
}

# Trap to remove file download if canceled before completed.
fn_fetch_trap(){
	echo -e ""
	echo -en "downloading ${local_filename}..."
	fn_print_canceled_eol_nl
	fn_script_log_info "Downloading ${local_filename}...CANCELED"
	fn_sleep_time
	rm -f "${local_filedir:?}/${local_filename}"
	echo -en "downloading ${local_filename}..."
	fn_print_removed_eol_nl
	fn_script_log_info "Downloading ${local_filename}...REMOVED"
	core_exit.sh
}

fn_fetch_file(){
	remote_fileurl="${1}"
	remote_fileurl_backup="${2}"
	remote_fileurl_name="${3}"
	remote_fileurl_backup_name="${4}"
	local_filedir="${5}"
	local_filename="${6}"
	chmodx="${7:-0}"
	run="${8:-0}"
	forcedl="${9:-0}"
	md5="${10:-0}"

	# Download file if missing or download forced.
	if [ ! -f "${local_filedir}/${local_filename}" ]||[ "${forcedl}" == "forcedl" ]; then
		# If backup fileurl exists include it.
		if [ -n "${remote_fileurl_backup}" ]; then
			# counter set to 0 to allow second try
			counter=0
			remote_fileurls_array=( remote_fileurl remote_fileurl_backup )
		else
			# counter set to 1 to not allow second try
			counter=1
			remote_fileurls_array=( remote_fileurl )
		fi
		for remote_fileurl_array in "${remote_fileurls_array[@]}"
		do
			if [ "${remote_fileurl_array}" == "remote_fileurl" ]; then
				fileurl="${remote_fileurl}"
				fileurl_name="${remote_fileurl_name}"
			elif [ "${remote_fileurl_array}" == "remote_fileurl_backup" ]; then
				fileurl="${remote_fileurl_backup}"
				fileurl_name="${remote_fileurl_backup_name}"
			fi
			counter=$((counter+1))
			if [ ! -d "${local_filedir}" ]; then
				mkdir -p "${local_filedir}"
			fi
			# Trap will remove part downloaded files if canceled.
			trap fn_fetch_trap INT
			# Larger files show a progress bar.
			if [ "${local_filename##*.}" == "bz2" ]||[ "${local_filename##*.}" == "gz" ]||[ "${local_filename##*.}" == "zip" ]||[ "${local_filename##*.}" == "jar" ]||[ "${local_filename##*.}" == "xz" ]; then
				echo -en "downloading ${local_filename}..."
				fn_sleep_time
				echo -en "\033[1K"
				curlcmd=$(curl --progress-bar --fail -L -o "${local_filedir}/${local_filename}" "${fileurl}")
				echo -en "downloading ${local_filename}..."
			else
				echo -en "fetching ${fileurl_name} ${local_filename}...\c"
				curlcmd=$(curl -s --fail -L -o "${local_filedir}/${local_filename}" "${fileurl}" 2>&1)
			fi
			local exitcode=$?

			# Download will fail if downloads a html file.
			if [ -f "${local_filedir}/${local_filename}" ]; then
				if [ -n "$(head "${local_filedir}/${local_filename}" | grep "DOCTYPE" )" ]; then
					rm "${local_filedir:?}/${local_filename:?}"
					local exitcode=2
				fi
			fi

			# On first try will error. On second try will fail.
			if [ ${exitcode} -ne 0 ]; then
				if [ ${counter} -ge 2 ]; then
					fn_print_fail_eol_nl
					if [ -f "${lgsmlog}" ]; then
						fn_script_log_fatal "Downloading ${local_filename}"
						fn_script_log_fatal "${fileurl}"
					fi
					core_exit.sh
				else
					fn_print_error_eol_nl
					if [ -f "${lgsmlog}" ]; then
						fn_script_log_error "Downloading ${local_filename}"
						fn_script_log_error "${fileurl}"
					fi
				fi
			else
				fn_print_ok_eol
				sleep 0.3
				echo -en "\033[2K\\r"
				if [ -f "${lgsmlog}" ]; then
					fn_script_log_pass "Downloading ${local_filename}"
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
		fn_dl_md5
		# Execute file if run is set.
		if [ "${run}" == "run" ]; then
			# shellcheck source=/dev/null
			source "${local_filedir}/${local_filename}"
		fi
	fi
}

# GitHub file download functions.
# Used to simplify downloading specific files from GitHub.

# github_file_url_dir: the directory of the file in the GitHub: lgsm/functions
# github_file_url_name: the filename of the file to download from GitHub: core_messages.sh
# githuburl: the full GitHub url

# remote_fileurl: The URL of the file: http://example.com/dl/File.tar.bz2
# local_filedir: location the file is to be saved: /home/server/lgsm/tmp
# local_filename: name of file (this can be different from the url name): file.tar.bz2
# chmodx: Optional, set to "chmodx" to make file executable using chmod +x
# run: Optional, set run to execute the file after download
# forcedl: Optional, force re-download of file even if exists
# md5: Optional, set an md5 sum and will compare it against the file.

# Fetches files from the Git repo.
fn_fetch_file_github(){
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	if [ "${legacymode}" == "1" ]; then
		# For legacy versions - code can be removed at a future date
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	elif [ "${githubbranch}" == "master" ]&&[ "${commandname}" != "UPDATE-LGSM" ]; then
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
	md5="${7:-0}"
	# Passes vars to the file download function.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
}

# Fetches config files from the Git repo.
fn_fetch_config(){
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	if [ "${githubbranch}" == "master" ]&&[ "${commandname}" != "UPDATE-LGSM" ]; then
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
	md5="nomd5"
	# Passes vars to the file download function.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
}

# Fetches modules from the Git repo during first download.
fn_fetch_function(){
	github_file_url_dir="lgsm/functions"
	github_file_url_name="${functionfile}"
	if [ "${githubbranch}" == "master" ]&&[ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="Bitbucket"
	local_filedir="${functionsdir}"
	local_filename="${github_file_url_name}"
	chmodx="chmodx"
	run="run"
	forcedl="noforce"
	md5="nomd5"
	# Passes vars to the file download function.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"
}

# Fetches modules from the Git repo during update-lgsm.
fn_update_function(){
	github_file_url_dir="lgsm/functions"
	github_file_url_name="${functionfile}"
	if [ "${githubbranch}" == "master" ]&&[ "${commandname}" != "UPDATE-LGSM" ]; then
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${version}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${version}/${github_file_url_dir}/${github_file_url_name}"
	else
		remote_fileurl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
		remote_fileurl_backup="https://bitbucket.org/${githubuser}/${githubrepo}/raw/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fi
	remote_fileurl_name="GitHub"
	remote_fileurl_backup_name="Bitbucket"
	local_filedir="${functionsdir}"
	local_filename="${github_file_url_name}"
	chmodx="chmodx"
	run="norun"
	forcedl="noforce"
	md5="nomd5"
	# Passes vars to the file download function.
	fn_fetch_file "${remote_fileurl}" "${remote_fileurl_backup}" "${remote_fileurl_name}" "${remote_fileurl_backup_name}" "${local_filedir}" "${local_filename}" "${chmodx}" "${run}" "${forcedl}" "${md5}"

}

# Check that curl is installed
if [ ! "$(command -v curl 2>/dev/null)" ]; then
	echo -e "[ FAIL ] Curl is not installed"
	exit 1
fi
