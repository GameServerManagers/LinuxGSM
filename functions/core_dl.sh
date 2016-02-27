#!/bin/bash
# LGSM core_dl.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="050216"

# Description: Deals with all downloads for LGSM.

# Downloads can be defined in code like so
# fn_dl "dl_filename" "dl_filepath" "dl_url" "dl_md5"
# fn_dl "file.tar.bz2" "/home/gameserver" "http://example.com/file.tar/bz2" "10cd7353aa9d758a075c600a6dd193fd"


fn_dl_md5(){
# Runs MD5 Check if available
if [ -n "${md5}" ]; then
	echo -ne "verifying ${filename} with MD5..."
	sleep 1
	local md5sumcmd=$(md5sum "${filedir}/${filename}"|awk '{print $1;}')
	if [ "${md5sumcmd}" != "${md5}" ]; then
		fn_printfaileolnl
		echo "${filename} returned MD5 checksum: ${md5sumcmd}"
		echo "expected MD5 checksum: ${md5}"
		fn_scriptlog "failed to verify ${filename} with MD5"
		fn_scriptlog "${filename} returned MD5 checksum: ${md5sumcmd}"
		fn_scriptlog "expected MD5 checksum: ${md5}"
		exit 1	
	else
		fn_printokeolnl
		fn_scriptlog "verifyed ${filename} with MD5"
		fn_scriptlog "${filename} returned MD5 checksum: ${md5sumcmd}"
		fn_scriptlog "expected MD5 checksum: ${md5}"		
	fi
fi	
}

fn_dl_extract(){
filedir=${1}
filename=${2}
extractdir=${3}
# extracts archives
echo -ne "extracting ${filename}..."
mime=$(file -b --mime-type "${filedir}/${filename}")

if [ "${mime}" == "application/gzip" ]; then
	tarcmd=$(tar -zxf "${filedir}/${filename}" -C "${extractdir}")
elif [ "${mime}" == "application/x-bzip2" ]; then
	tarcmd=$(tar -jxf "${filedir}/${filename}" -C "${extractdir}")
fi
local exitcode=$?
if [ ${exitcode} -ne 0 ]; then
	fn_printfaileolnl
	echo "${tarcmd}"
	exit ${exitcode}
else
	fn_printokeolnl
fi
}

# Trap to remove file download if canceled before completed
fn_fetch_trap() {
	echo ""
	fn_printinfomationnl "Cancelling download"
	sleep 1
	fn_printinfomation "Removing ${filename}"
	rm -f "${filedir}/${filename}"
}

# Downloads file using curl and run it if required
# fn_fetch_file "fileurl" "filedir" "filename" "executecmd" "run" "force" "md5"
fn_fetch_file(){
fileurl=${1}
filedir=${2}
filename=${3}
executecmd=${4:-0}
run=${5:-0}
force=${6:-0}
md5=${7}

# If the file is missing, then download
if [ ! -f "${filedir}/${filename}" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir -p "${filedir}"
	fi
	
	# Check curl exists and use available path
	curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl $(echo $PATH | sed "s/\([:]\|\$\)/\/curl /g")"
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
		if [ ${filename##*.} == "bz2" ]; then
			echo -ne "downloading ${filename}..."
			sleep 1
			curlcmd=$(${curlcmd} --progress-bar --fail -o "${filedir}/${filename}" "${fileurl}")
			echo -ne "downloading ${filename}..."
		else
			echo -ne "    fetching ${filename}...\c"
			curlcmd=$(${curlcmd} -s --fail -o "${filedir}/${filename}" "${fileurl}" 2>&1)
		fi
		local exitcode=$?
		if [ ${exitcode} -ne 0 ]; then
			fn_printfaileolnl
			echo "${curlcmd}"
			echo -e "${fileurl}\n"
			exit ${exitcode}
		else
			fn_printokeolnl
		fi
		# remove trap
		trap - INT	
	else
		fn_printfaileolnl
		echo "Curl is not installed!"
		echo -e ""
		exit 1
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


# fn_fetch_file_github
# Parameters:
# github_file_url_dir: The directory the file is located in teh GitHub repo
# github_file_url_name: name of file
# filepath: location file to be saved
# executecmd: set to "executecmd" to make file executecmd
# run: Optional, set to run to execute the file
# force: force download of file even if exists
fn_fetch_file_github(){
github_file_url_dir=${1}
github_file_url_name=${2}
filepath=${3}
filename="${github_file_url_name}"
executecmd=${4:-0}
run=${5:-0}
force=${6:-0}
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
fn_fetch_file "${githuburl}" "${filepath}" "${filename}" "${executecmd}" "${run}" "${force}"
}



# Fetches functions
fn_fetch_function(){
github_file_url_dir="functions" # github dir containing the file
github_file_url_name="${functionfile}" # name of the github file
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
filedir="${functionsdir}" # local dir that will contain the file
filename="${github_file_url_name}" # name of the local file
executecmd="executecmd"
run="run"
fn_fetch_file "${githuburl}" "${filedir}" "${filename}" "${executecmd}" "${run}"
}