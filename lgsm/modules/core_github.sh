#!/bin/bash
# LinuxGSM core_github.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: core module file for updates via github

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

github_api="https://api.github.com"

fn_githublocalversionfile() {
	local githubreleaseuser="${1}"
	local githubreleaserepo="${2}"

	githublocalversionfile="${datadir}/github-${githubreleaseuser}-${githubreleaserepo}-version"
}

# $1 githubuser/group
# $2 github repo name
fn_github_get_latest_release_version() {
	local githubreleaseuser="${1}"
	local githubreleaserepo="${2}"
	local githublatestreleaseurl="${github_api}/repos/${githubreleaseuser}/${githubreleaserepo}/releases/latest"

	githubreleaseversion=$(curl -s --connect-timeout 3 "${githublatestreleaseurl}" | jq '.tag_name')

	# error if no version is there
	if [ -z "${githubreleaseversion}" ]; then
		fn_print_fail_nl "Cannot get version from GitHub API for ${githubreleaseuser}/${githubreleaserepo}"
		fn_script_log_fail "Cannot get version from GitHub API for ${githubreleaseuser}/${githubreleaserepo}"
	fi
}

# $1 githubuser/group
# $2 github repo name
fn_github_set_latest_release_version() {
	local githubreleaseuser="${1}"
	local githubreleaserepo="${2}"

	fn_githublocalversionfile "${githubreleaseuser}" "${githubreleaserepo}"

	local githublatestreleaseurl="${github_api}/repos/${githubreleaseuser}/${githubreleaserepo}/releases/latest"
	githubreleaseversion=$(curl -s "${githublatestreleaseurl}" | jq -r '.tag_name')

	# error if no version is there
	if [ -z "${githubreleaseversion}" ]; then
		fn_print_fail_nl "Cannot get version from GitHub API for ${githubreleaseuser}/${githubreleaserepo}"
		fn_script_log_fail "Cannot get version from GitHub API for ${githubreleaseuser}/${githubreleaserepo}"
	else
		echo "${githubreleaseversion}" > "${githublocalversionfile}"
	fi
}

# $1 githubuser/group
# $2 github repo name
fn_github_get_installed_version() {
	local githubreleaseuser="${1}"
	local githubreleaserepo="${2}"

	fn_githublocalversionfile "${githubreleaseuser}" "${githubreleaserepo}"

	githublocalversion=$(cat "${githublocalversionfile}")
}

# $1 githubuser/group
# $2 github repo name
# if a update needs to be downloaded - updateneeded is set to 1
fn_github_compare_version() {
	local githubreleaseuser="${1}"
	local githubreleaserepo="${2}"
	exitcode=0
	updateneeded=0

	fn_githublocalversionfile "${githubreleaseuser}" "${githubreleaserepo}"
	local githublatestreleaseurl="${github_api}/repos/${githubreleaseuser}/${githubreleaserepo}/releases/latest"

	githublocalversion=$(cat "${githublocalversionfile}")
	githubreleaseversion=$(curl -s "${githublatestreleaseurl}" | jq '.tag_name')

	# error if no version is there
	if [ -z "${githubreleaseversion}" ]; then
		fn_print_fail_nl "Can not get version from Github Api for ${githubreleaseuser}/${githubreleaserepo}"
		fn_script_log_fail "Can not get version from Github Api for ${githubreleaseuser}/${githubreleaserepo}"
	else
		if [ "${githublocalversion}" == "${githubreleaseversion}" ]; then
			echo -en "\n"
			echo -e "No update from github.com/${githubreleaseuser}/${githubreleaserepo}/ available:"
			echo -e "* Local build: ${red}${githublocalversion}${default}"
			echo -e "* Remote build: ${green}${githubreleaseversion}${default}"
			echo -en "\n"
		else
			# check if version that is installed is higher than the remote version to not override it
			last_version=$(echo -e "${githublocalversion}\n${githubreleaseversion}" | sort -V | head -n1)
			if [ "${githubreleaseversion}" == "${last_version}" ]; then
				echo -en "\n"
				echo -e "Update from github.com/${githubreleaseuser}/${githubreleaserepo}/ available:"
				echo -e "* Local build: ${red}${githublocalversion}${default}"
				echo -e "* Remote build: ${green}${githubreleaseversion}${default}"
				echo -en "\n"
				updateneeded=1
			else
				# local version is higher than the remote version output this to the user
				# strange case but could be possible, as a release could be removed from github
				echo -en "\n"
				echo -e "Local version is newer than the remote version"
				echo -e "* Local version: ${green}${githublocalversion}${default}"
				echo -e "* Remote version: ${green}${githubreleaseversion}${default}"
				echo -en "\n"
				exitcode=1
			fi
		fi
	fi
}
