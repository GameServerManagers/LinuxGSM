#!/bin/bash
# LGSM core_dl.sh function
# Author: Daniel Gibbs
# Contributor: UltimateByte
# Website: https://gameservermanagers.com
# Description: Deals with all downloads for LGSM.

# fileurl: The URL of the file: http://example.com/dl/File.tar.bz2
# filedir: location the file is to be saved: /home/server/lgsm/tmp
# filename: name of file (this can be different from the url name): file.tar.bz2
# executecmd: Optional, set to "executecmd" to make file executable using chmod +x
# run: Optional, set to run to execute the file
# force: Optional, force re-download of file even if exists
# md5: Optional, Checks file against an md5 sum
#
# Downloads can be defined in code like so:
# fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
# fn_fetch_file "http://example.com/file.tar.bz2" "/some/dir" "file.tar.bz2" "executecmd" "run" "force" "10cd7353aa9d758a075c600a6dd193fd"

local commandname="DOWNLOAD"
local commandaction="Download"
local function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"

fn_dl_md5(){
	# Runs MD5 Check if available
	if [ "${md5}" != "0" ]&&[ "${md5}" != "nomd5" ]; then
		echo -ne "verifying ${filename} with MD5..."
		sleep 1
		local md5sumcmd=$(md5sum "${filedir}/${filename}"|awk '{print $1;}')
		if [ "${md5sumcmd}" != "${md5}" ]; then
			fn_print_fail_eol_nl
			echo "${filename} returned MD5 checksum: ${md5sumcmd}"
			echo "expected MD5 checksum: ${md5}"
			fn_script_log_fatal "Verifying ${filename} with MD5: FAIL"
			fn_script_log_info "${filename} returned MD5 checksum: ${md5sumcmd}"
			fn_script_log_info "Expected MD5 checksum: ${md5}"
			core_exit.sh
		else
			fn_print_ok_eol_nl
			fn_script_log_pass "Verifying ${filename} with MD5: OK"
			fn_script_log_info "${filename} returned MD5 checksum: ${md5sumcmd}"
			fn_script_log_info "Expected MD5 checksum: ${md5}"
		fi
	fi
}

# Extracts bzip2 or gzip or zip files
# Extracts can be defined in code like so:
# fn_dl_extract "${filedir}" "${filename}" "${extractdir}"
# fn_dl_extract "/home/gameserver/lgsm/tmp" "file.tar.bz2" "/home/gamserver/serverfiles"
fn_dl_extract(){
	filedir="${1}"
	filename="${2}"
	extractdir="${3}"
	# extracts archives
	echo -ne "extracting ${filename}..."
	fn_script_log_info "Extracting download"
	mime=$(file -b --mime-type "${filedir}/${filename}")

	if [ "${mime}" == "application/gzip" ]||[ "${mime}" == "application/x-gzip" ]; then
		tarcmd=$(tar -zxf "${filedir}/${filename}" -C "${extractdir}")
	elif [ "${mime}" == "application/x-bzip2" ]; then
		tarcmd=$(tar -jxf "${filedir}/${filename}" -C "${extractdir}")
	elif [ "${mime}" == "application/zip" ]; then
		tarcmd=$(unzip -d "${extractdir}" "${filedir}/${filename}")
	fi
	local exitcode=$?
	if [ ${exitcode} -ne 0 ]; then
		fn_print_fail_eol_nl
		fn_script_log_fatal "Extracting download: FAIL"
		echo "${tarcmd}" | tee -a "${scriptlog}"
		core_exit.sh
	else
		fn_print_ok_eol_nl
	fi
}

# Trap to remove file download if canceled before completed
fn_fetch_trap(){
	echo ""
	echo -ne "downloading ${filename}: "
	fn_print_canceled_eol_nl
	fn_script_log_info "downloading ${filename}: CANCELED"
	sleep 1
	rm -f "${filedir}/${filename}" | tee -a "${scriptlog}"
	echo -ne "downloading ${filename}: "
	fn_print_removed_eol_nl
	fn_script_log_info "downloading ${filename}: REMOVED"
	core_exit.sh
}

fn_fetch_file(){
	fileurl="${1}"
	filedir="${2}"
	filename="${3}"
	executecmd="${4:-0}"
	run="${5:-0}"
	force="${6:-0}"
	md5="${7:-0}"

	# If the file is missing, then download
	if [ ! -f "${filedir}/${filename}" ]; then
		if [ ! -d "${filedir}" ]; then
			mkdir -p "${filedir}"
		fi

		# Check curl exists and use available path
		curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl)"
		for curlcmd in ${curlpaths}
		do
			if [ -x "${curlcmd}" ]; then
				break
			fi
		done
		# If curl exists download file
		if [ "$(basename ${curlcmd})" == "curl" ]; then
			# trap to remove part downloaded files
			trap fn_fetch_trap INT
			# if larger file shows progress bar
			if [ ${filename##*.} == "bz2" ]||[ ${filename##*.} == "jar" ]; then
				echo -ne "downloading ${filename}..."
				sleep 1
				curlcmd=$(${curlcmd} --progress-bar --fail -L -o "${filedir}/${filename}" "${fileurl}")
				echo -ne "downloading ${filename}..."
			else
				echo -ne "    fetching ${filename}...\c"
				curlcmd=$(${curlcmd} -s --fail -L -o "${filedir}/${filename}" "${fileurl}" 2>&1)
			fi
			local exitcode=$?
			if [ ${exitcode} -ne 0 ]; then
				fn_print_fail_eol_nl
				if [ -f "${scriptlog}" ]; then
					fn_script_log_fatal "downloading ${filename}: FAIL"
				fi
				echo -e "${fileurl}" | tee -a "${scriptlog}"
				echo "${curlcmd}" | tee -a "${scriptlog}"
				core_exit.sh
			else
				fn_print_ok_eol_nl
				if [ -f "${scriptlog}" ]; then
					fn_script_log_pass "downloading ${filename}: OK"
				fi
			fi
			# remove trap
			trap - INT
		else
			fn_print_fail_eol_nl
			echo "Curl is not installed!"
			echo -e ""
			if [ -f "${scriptlog}" ]; then
				fn_script_log_fatal "Curl is not installed!"
			fi
			core_exit.sh
		fi
		# make file executecmd if executecmd is set
		if [ "${executecmd}" == "executecmd" ]; then
			chmod +x "${filedir}/${filename}"
		fi
	fi

	if [ -f "${filedir}/${filename}" ]; then
		fn_dl_md5
		# run file if run is set
		if [ "${run}" == "run" ]; then
			source "${filedir}/${filename}"
		fi
	fi
}



# fileurl: The directory the file is located in teh GitHub repo
# filedir: name of file
# filename: location file to be saved
# executecmd: set to "executecmd" to make file executecmd
# run: Optional, set to run to execute the file
# force: force download of file even if exists
# md5: Checks fail against an md5 sum


# Fetches files from the github repo
fn_fetch_file_github(){
	github_file_url_dir="${1}"
	github_file_url_name="${2}"
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fileurl="${githuburl}"
	filedir="${3}"
	filename="${github_file_url_name}"
	executecmd="${4:-0}"
	run="${5:-0}"
	force="${6:-0}"
	md5="${7:-0}"
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
}


# Fetches functions
fn_fetch_function(){
	github_file_url_dir="lgsm/functions" # github dir containing the file
	github_file_url_name="${functionfile}" # name of the github file
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fileurl="${githuburl}"
	filedir="${functionsdir}"
	filename="${github_file_url_name}"
	executecmd="executecmd"
	run="run"
	force="noforce"
	md5="nomd5"
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
}

fn_update_function(){
	exitbypass=1
	github_file_url_dir="lgsm/functions" # github dir containing the file
	github_file_url_name="${functionfile}" # name of the github file
	githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
	fileurl="${githuburl}"
	filedir="${functionsdir}"
	filename="${github_file_url_name}"
	executecmd="executecmd"
	run="norun"
	force="noforce"
	md5="nomd5"
	fn_fetch_file "${fileurl}" "${filedir}" "${filename}" "${executecmd}" "${run}" "${force}" "${md5}"
}
