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
	echo -ne "verifying ${filename} with MD5...\c"
	local md5check=$(md5sum "${filedir}/${filename}"|awk '{print $1;}')
	if [ "${md5check}" != "${dl_md5}" ]; then
		fn_printfaileol
		echo "${filename} MD5 checksum: ${md5check}"
		echo "expected MD5 checksum: ${dl_md5}"
		fn_scriptlog "failed to verify ${filename} with MD5"
		fn_scriptlog "${filename} MD5 checksum: ${md5check}"
		fn_scriptlog "expected MD5 checksum: ${dl_md5}"
		exit 1	
	else
		fn_printokeol
		fn_scriptlog "verifyed ${filename} with MD5"
		fn_scriptlog "${filename} MD5 checksum: ${md5check}"
		fn_scriptlog "expected MD5 checksum: ${dl_md5}"		
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
	fn_printfaileol
	echo "${tarcmd}"
	exit ${exitcode}
else
	fn_printokeol
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
# fn_fetch_file "fileurl" "filedir" "filename" "run" "force" "md5"
fn_fetch_file(){
fileurl=${1}
filedir=${2}
filename=${3}
run=${4:-0}
force=${5:-0}
md5=${6}

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
		if [[ $filename == *"tar"* ]]; then
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
			fn_printfaileol
			echo "${curlcmd}"
			echo -e "${fileurl}\n"
			exit ${exitcode}
		else
			fn_printokeol
		fi
		# remove trap
		trap - INT	
	else
		fn_printfaileol
		echo "Curl is not installed!"
		echo -e ""
		exit 1
	fi
	fn_dl_md5
	# make file executable if run is set
	if [ "${run}" == "run" ]; then
		chmod +x "${filedir}/${filename}"
	fi
fi
# run file if run is set
if [ "${run}" == "run" ]; then
	source "${filedir}/${filename}"
fi
}


# fn_fetch_file_github
# Parameters:
# github_file_url_dir: The directory the file is located in teh GitHub repo
# github_file_url_name: name of file
# filepath: location file to be saved
# run: Optional, set to 1 to make file executable
# force: force download of file even if exists
fn_fetch_file_github(){
github_file_url_dir=${1}
github_file_url_name=${2}
filepath=${3}
filename="${github_file_url_name}"
run=${4:-0}
force=${5:-0}
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
echo -e "    fetching ${filename}...\c"
fn_fetch_file "${githuburl}" "${filepath}" "${filename}" "${run}" "${force}"
}



# Fetches functions
fn_fetch_function(){
github_file_url_dir="functions" # github dir containing the file
github_file_url_name="${functionfile}" # name of the github file
githuburl="https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${github_file_url_name}"
filedir="${functionsdir}" # local dir that will contain the file
filename="${github_file_url_name}" # name of the local file
run="run"
fn_fetch_file "${githuburl}" "${filedir}" "${filename}" "${run}"
}