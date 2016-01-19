#!/bin/bash
# LGSM git manifest functions
# Author: Jared Ballou
# Website: http://gameservermanagers.com
#
# This is another one of my POC tools. Eventually I want to have a pretty robust update/download system here
# Goals:
#  * Keep function files up to date on client machines
#  * Deploy other programs or support tools
#  * Learn more about GitHub API
#  * Parse JSON in Bash

# fn_get_git_hash $filename
# Calculate the Git hash for a file
function fn_get_git_hash(){
	filename=$1
	if [ -e $filename ]
	then
		filesize=$(stat --format='%s' $filename)
		if [ "$(tail -c1 $filename)" == "" ]; then
			printf "blob %d\0%s\n" "${filesize}" "$(cat $filename)" | sha1sum | awk '{print $1}'
		else
			printf "blob %d\0%s" "${filesize}" "$(cat $filename)" | sha1sum | awk '{print $1}'
		fi
	fi
}

fn_get_github_manifest(){
	# Create cache directory if missing
	if [ ! -e "${cachedir}" ]; then
		mkdir -p "${cachedir}"
	fi
	# Get latest commit from GitHub. Cache file for 60 minutes
	if [ -e $lastcommit_file ]; then
		if [ $(($(date +%s) - $(date -r ${lastcommit_file} +%s))) -gt 3600 ]; then
			fetch=1
		else
			fetch=0
		fi
	else
		fetch=1
	fi
	if [ $fetch -eq 1 ]; then
		echo "Fetching ${lastcommit_file}"
		curl -s "https://api.github.com/repos/${githubuser}/${githubrepo}/git/refs/heads/${githubbranch}" -o "${lastcommit_file}.json"
		${lgsmdir}/functions/jq-linux64 -r '.object.sha' "${lastcommit_file}.json" > "${lastcommit_file}"
	fi
	# Get manifest of all files at this revision in GitHub. These hashes are what we use to compare and select files that need to be updated.
	manifest="${cachedir}/$(cat "${lastcommit_file}").manifest"
	if [ ! -e "${manifest}.json" ]; then
		curl -Ls "https://api.github.com/repos/${githubuser}/${githubrepo}/git/trees/${githubbranch}?recursive=1" -o "${manifest}.json"
	fi
	if [ ! -e "${manifest}" ]; then
		${lgsmdir}/functions/jq-linux64 -r '.tree[] | .path + " " + .sha' "${manifest}.json" > "${manifest}"
	fi
}

# Check files against manifest
fn_check_github_files(){
	prefix=$1
	files=${@:2}
	fn_get_github_manifest
	manifest="${cachedir}/$(cat "${lastcommit_file}").manifest"
	# Check all files in functions for updates
	for file in $files; do
		if [ -d $file ]; then
			echo "Descending into ${file}..."
			fn_check_github_files "${prefix}" ${file}/*
		else
			myhash=$(fn_get_git_hash $file)
			repofile=$(echo $file | sed -e "s|${1}[/]*||g")
			githash=$(grep "^$repofile " $manifest 2>/dev/null| cut -d" " -f2)
			if [ "${githash}" == "" ]; then
				echo "Can't find ${repofile} in git!"
			elif [ "${myhash}" != "${githash}" ]; then
				echo "Would fetch ${repofile}: have ${myhash}, expected ${githash}"
			else
				echo "${repofile} is OK"
			fi
		fi
	done
}
