#!/bin/bash
# LGSM git manifest functions
# Author: Jared Ballou
# Website: http://gameservermanagers.com
#
# This is another oe of my POC tools. Eventually I want to have a pretty robust update/download system here
# Goals:
#  * Keep function files up to date on client machines
#  * Deploy other programs or support tools
#  * Learn more about GitHub API
#  * Parse JSON in Bash

# Temporary file location
cache_dir=/tmp/lgsm
githubuser="jaredballou"
githubrepo="linuxgsm"
githubbranch="master"

# Create cache directory if missing
if [ ! -e "${cache_dir}" ]
then
	mkdir -p "${cache_dir}"
fi

# fn_getgithash filename
# Calculate the Git hash for a file
function fn_getgithash(){
	filename=$1
	if [ -e $filename ]
	then
		printf "blob %d\0%s\n" "$(stat --format='%s' $filename)" "$(cat $filename)" | sha1sum | awk '{print $1}'
	else
		echo "NOTFOUND"
	fi
}

# Get latest commit from GitHub. Cache file for 60 minutes
lastcommit="${cache_dir}/lastcommit"
if [ $(find "${lastcommit}" -mmin +60 2>/dev/null) ]
then
	echo "found"
else
	curl -s "https://api.github.com/repos/${githubuser}/${githubrepo}/git/refs/heads/${githubbranch}" | ./functions/jq-linux64 -r '.object.sha' > "${lastcommit}"
fi

# Get manifest of all files at this revision in GitHub. These hashes are what we use to compare and select files that need to be updated.
lastcommit="$(cat "${lastcommit}")"
manifest="${cache_dir}/${lastcommit}.manifest"
if [ ! -e "${manifest}" ]
then
	curl -s "https://api.github.com/repos/${githubuser}/${githubrepo}/git/trees/${githubbranch}?recursive=1" | ./functions/jq-linux64 -r '.tree[] | .path + " " + .sha' > "${manifest}"
fi

# Check all files in functions for updates
for file in functions/*
do
	myhash=$(fn_getgithash $file)
	githash=$(grep "^$file " $manifest 2>/dev/null| cut -d" " -f2)
	if [ "${githash}" == "" ]
	then
		echo "Can't find ${file} in git!"
	elif [ "${myhash}" != "${githash}" ]
	then
		echo "Would fetch ${file}: have ${myhash}, expected ${githash}"
	else
		echo "${file} is OK"
	fi
done
