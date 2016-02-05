#!/bin/bash
# LGSM core_dl.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="050216"

# Description: Deals with all downloads for LGSM.

fn_curl_dl(){
curl_filename=$1
curl_filepath=$2
curl_url=$3
echo "curl_filename $curl_filename"
echo "curl_url ${curl_url}"
echo "curl_filepath ${curl_filepath}"

echo -ne "Downloading ${mm_file_latest}...\c"

curl_dl=$(curl --fail -o "${curl_filepath}" "${curl_url}" )
exitcode=$?
if [ $? -ne 0 ]; then
	fn_printfaileol
	echo "${curl_dl}"
	echo -e "${url}\n"
	exit ${exitcode}
else
	fn_printokeol
fi
}