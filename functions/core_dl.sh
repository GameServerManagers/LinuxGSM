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


fn_dl_file(){
# defines variables from other script file
dl_filename=$1
dl_filepath=$2
dl_url=$3
dl_md5=$4

if [ ! -f "${dl_filepath}/${dl_filename}" ]||[ -n "${retry_dl}" ]; then
	echo -ne "downloading ${dl_filename}..."
	dl=$(curl --progress-bar --fail -o "${dl_filepath}/${dl_filename}" "${dl_url}")
	exitcode=$?
	echo -ne "downloading ${dl_filename}...\c"
	if [ ${exitcode} -ne 0 ]; then
		fn_printfaileol
		echo -e "${dl_url}\n"
		exit ${exitcode}
	else
		fn_printokeol
	fi
else	
	echo -e "${dl_filename} already exists...\c"
	fn_dl_md5
	while true; do
		read -e -i "n" -p "Download again? [y/N]" yn
		case $yn in
		[Yy]* ) fn_dl; retry_dl=1;;
		[Nn]* ) break;;
		* ) echo "Please answer yes or no.";;
	esac
	done
fi	

fn_dl_md5
}



# Downloads file using curl and run it if required
fn_dl_file(){
fileurl="${1}"
filedir="${2}"
filename="${3}"
run=${4:-0}
force=${5:-0}
md5=${6}
# If the file is missing or forced, then download
if [ ! -f "${filedir}" ] || [ "${force}" == "1" ] || [ "${force}" == "yes" ]; then
	if [ ! -d "${filedir}" ]; then
		mkdir -p "${filedir}"
	fi
	
	# Check curl exists and use available path
	curlpaths="$(command -v curl 2>/dev/null) $(which curl >/dev/null 2>&1) /usr/bin/curl /bin/curl /usr/sbin/curl /sbin/curl $(echo $PATH | sed "s/\([:]\|\$\)/\/curl /g")"
	for curlcmd in ${curlpaths}
	do
		if [ -x "${curlcmd}" ]; then
			curlcmd=${curlcmd}
			break
		fi
	done
	# If curl exists download file
	if [ "$(basename ${curlcmd})" == "curl" ]; then
		# if larger file shows progress bar
		if [ "${filename}" == *".tar"* ]; then
			curlfetch=$(${curlcmd} --progress-bar -s --fail -o "${filedir}/${filename}" "${fileurl}" 2>&1)
		else	
			curlfetch=$(${curlcmd} -s --fail -o "${filedir}/${filename}" "${fileurl}" 2>&1)
		fi
		if [ $? -ne 0 ]; then
			fn_printfaileol
			echo "${curlfetch}"
			echo -e "${fileurl}\n"
			fn_scriptlog "failed to download ${filedir}/${filename}"
			fn_scriptlog "${curlfetch}"
			fn_scriptlog -e "${fileurl}\n"
			sleep 1
			echo "Removing failed ${filename}..."
			rm -f "${filedir}/${filename}"
			if [ $? -ne 0 ]; then
				fn_printfaileol
			else
				fn_printokeol
			fi 
			exit 1
		else
			fn_printokeol
			fn_scriptlog "downloaded ${filedir}/${filename}"
		fi		
	else
		echo -e "fn_printfaileol"
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