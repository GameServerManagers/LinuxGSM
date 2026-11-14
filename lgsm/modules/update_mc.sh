#!/bin/bash
# LinuxGSM update_mc.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of Minecraft: Java Edition servers.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_update_dl() {
	# Download and extract files to serverfiles.
	fn_fetch_file "${remotebuildurl}" "" "" "" "${tmpdir}" "${remotebuildfilename}" "chmodx" "norun" "noforce" "${remotebuildhash:-nohash}"
	cp -f "${tmpdir}/${remotebuildfilename}" "${serverfiles}/${variantexecutable#./}"
	if [ "${variant}" != "vanilla" ]; then
		echo "${remotebuild}" > "${serverfiles}/build.txt"
	fi
	fn_variant_record
	fn_clear_tmp
}

fn_update_localbuild() {
	# Gets local build info.
	fn_print_dots "Checking local build: ${remotelocation}"
	if [ "${installedvariant}" != "${variant}" ]; then
		localbuild="${installedvariant}"
	elif [ "${variant}" == "vanilla" ]; then
		# Uses executable to get local build.
		if [ -d "${executabledir}" ]; then
			cd "${executabledir}" || exit
			localbuild=$(unzip -p "minecraft_server.jar" version.json | jq -r '.id')
		fi
	else
		localbuild=$(head -n 1 "${serverfiles}/build.txt" 2> /dev/null)
	fi
	if [ -z "${localbuild}" ]; then
		fn_print_error "Checking local build: ${remotelocation}: missing local build info"
		fn_script_log_error "Missing local build info"
		fn_script_log_error "Set localbuild to 0"
		localbuild="0"
	else
		fn_print_ok "Checking local build: ${remotelocation}"
		fn_script_log_pass "Checking local build"
	fi
}

fn_update_remotebuild_vanilla() {
	apiurl="https://launchermeta.mojang.com/mc/game/version_manifest.json"
	remotebuildresponse=$(curl -s "${apiurl}")
	# Latest release.
	if [ "${branch}" == "release" ] && [ "${mcversion}" == "latest" ]; then
		remotebuild=$(echo "${remotebuildresponse}" | jq -r '.latest.release')
	# Latest snapshot.
	elif [ "${branch}" == "snapshot" ] && [ "${mcversion}" == "latest" ]; then
		remotebuild=$(echo "${remotebuildresponse}" | jq -r '.latest.snapshot')
	# Specific release/snapshot.
	else
		remotebuild=$(echo "${remotebuildresponse}" | jq -r --arg branch "${branch}" --arg mcversion "${mcversion}" '.versions | .[] | select(.type==$branch and .id==$mcversion) | .id')
	fi
	remotebuildfilename="minecraft_server.${remotebuild}.jar"
	# Generate link to version manifest json.
	remotebuildmanifest=$(echo "${remotebuildresponse}" | jq -r --arg branch "${branch}" --arg mcversion "${remotebuild}" '.versions | .[] | select(.type==$branch and .id==$mcversion) | .url')
	# Generate link to server.jar
	remotebuildmanifestresponse=$(curl -s "${remotebuildmanifest}")
	remotebuildurl=$(echo "${remotebuildmanifestresponse}" | jq -r '.downloads.server.url')
	remotebuildhash=$(echo "${remotebuildmanifestresponse}" | jq -r '.downloads.server.sha1 // "nohash"')
}

fn_update_remotebuild_fabric() {
	apiurl="https://meta.fabricmc.net/v2/versions"
	remotebuildresponse=$(curl -s "${apiurl}/game")
	if [ "${mcversion}" == "latest" ]; then
		if [ "${branch}" == "snapshot" ]; then
			remotebuildmcversion=$(echo "${remotebuildresponse}" | jq -r '.[0].version')
		else
			remotebuildmcversion=$(echo "${remotebuildresponse}" | jq -r '[.[] | select(.stable)][0].version')
		fi
	else
		remotebuildmcversion=$(echo "${remotebuildresponse}" | jq -r --arg mcversion "${mcversion}" '.[] | select(.version==$mcversion) | .version')
	fi
	remotebuildloader=$(curl -s "${apiurl}/loader" | jq -r '[.[] | select(.stable)][0].version')
	remotebuildinstaller=$(curl -s "${apiurl}/installer" | jq -r '[.[] | select(.stable)][0].version')
	if [ -n "${remotebuildmcversion}" ] && [ "${remotebuildmcversion}" != "null" ] && [ "${remotebuildloader}" != "null" ] && [ "${remotebuildinstaller}" != "null" ]; then
		# Combines Minecraft: Java Edition version and Fabric loader. e.g 1.21.10-0.17.3
		remotebuild="${remotebuildmcversion}-${remotebuildloader}"
		remotebuildfilename="fabric-server-mc.${remotebuildmcversion}-loader.${remotebuildloader}-launcher.${remotebuildinstaller}.jar"
		remotebuildurl="${apiurl}/loader/${remotebuildmcversion}/${remotebuildloader}/${remotebuildinstaller}/server/jar"
	fi
	remotebuildhash="nohash"
}

fn_update_remotebuild_purpur() {
	apiurl="https://api.purpurmc.org/v2/purpur"
	remotebuildresponse=$(curl -s "${apiurl}")
	if [ "${mcversion}" == "latest" ]; then
		remotebuildmcversion=$(echo "${remotebuildresponse}" | jq -r '.versions[-1]')
	else
		remotebuildmcversion=$(echo "${remotebuildresponse}" | jq -r --arg mcversion "${mcversion}" '.versions[] | select(.==$mcversion)')
	fi
	if [ -n "${remotebuildmcversion}" ] && [ "${remotebuildmcversion}" != "null" ]; then
		remotebuildpurpurbuild=$(curl -s "${apiurl}/${remotebuildmcversion}" | jq -r '.builds.latest')
		remotebuildhash=$(curl -s "${apiurl}/${remotebuildmcversion}/${remotebuildpurpurbuild}" | jq -r '.md5 // "nohash"')
		# Combines Minecraft: Java Edition version and Purpur build. e.g 1.21.10-2535
		remotebuild="${remotebuildmcversion}-${remotebuildpurpurbuild}"
		remotebuildfilename="purpur-${remotebuild}.jar"
		remotebuildurl="${apiurl}/${remotebuildmcversion}/${remotebuildpurpurbuild}/download"
	fi
}

fn_update_remotebuild() {
	# Gets remote build info.
	unset remotebuild remotebuildurl remotebuildhash
	if [ "${variant}" == "fabric" ]; then
		fn_update_remotebuild_fabric
	elif [ "${variant}" == "purpur" ]; then
		fn_update_remotebuild_purpur
	else
		fn_update_remotebuild_vanilla
	fi

	if [ "${firstcommandname}" != "INSTALL" ]; then
		fn_print_dots "Checking remote build: ${remotelocation}"
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_fail "Checking remote build: ${remotelocation}"
			fn_script_log_fail "Checking remote build"
			core_exit.sh
		else
			fn_print_ok "Checking remote build: ${remotelocation}"
			fn_script_log_pass "Checking remote build"
		fi
	else
		# Checks if remotebuild variable has been set.
		if [ -z "${remotebuild}" ] || [ "${remotebuild}" == "null" ]; then
			fn_print_failure "Unable to get remote build"
			fn_script_log_fail "Unable to get remote build"
			core_exit.sh
		fi
	fi
}

fn_update_compare() {
	fn_print_dots "Checking for update: ${remotelocation}"
	# Update has been found or force update.
	if [ "${localbuild}" != "${remotebuild}" ] || [ "${forceupdate}" == "1" ] || [ "${installedvariant}" != "${variant}" ]; then
		# Create update lockfile.
		date '+%s' > "${lockdir:?}/update.lock"
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}Update${default} available"
		fn_print_nl "* Local build: ${red}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		if [ "${installedvariant}" != "${variant}" ]; then
			fn_print_nl "* Variant: ${red}${installedvariantname}${default} > ${green}${variantname}${default}"
		else
			fn_print_nl "* Variant: ${variantname}"
		fi
		if [ -n "${branch}" ]; then
			fn_print_nl "* Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
		fn_print "\n"
		fn_script_log_info "Update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "Variant: ${installedvariant} > ${variant}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		fn_script_log_info "${localbuild} > ${remotebuild}"
		if [ "${installedvariant}" != "${variant}" ]; then
			fn_variant_change_warning
		fi

		if [ "${commandname}" == "UPDATE" ]; then
			unset updateonstart
			fn_update_apply fn_update_dl
			if [ "${updatestatus}" == "0" ] && [ "${localbuild}" == "0" ]; then
				exitbypass=1
				command_start.sh
				fn_firstcommand_reset
				exitbypass=1
				fn_sleep_time_5
				command_stop.sh
				fn_firstcommand_reset
			fi
			unset exitbypass
			alert="update"
		elif [ "${commandname}" == "CHECK-UPDATE" ]; then
			alert="check-update"
		fi
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		fn_print "\n"
		fn_print_nl "${bold}${underline}No update${default} available"
		fn_print_nl "* Local build: ${green}${localbuild}${default}"
		fn_print_nl "* Remote build: ${green}${remotebuild}${default}"
		fn_print_nl "* Variant: ${variantname}"
		if [ -n "${branch}" ]; then
			fn_print_nl "* Branch: ${branch}"
		fi
		fn_print "\n"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${remotebuild}"
		fn_script_log_info "Variant: ${variant}"
		if [ -n "${branch}" ]; then
			fn_script_log_info "Branch: ${branch}"
		fi
		if [ -f "${rootdir}/.dev-debug" ]; then
			fn_print_nl "Remote build info"
			fn_print_nl "* apiurl: ${apiurl}"
			fn_print_nl "* remotebuildfilename: ${remotebuildfilename}"
			fn_print_nl "* remotebuildurl: ${remotebuildurl}"
			fn_print_nl "* remotebuild: ${remotebuild}"
		fi
	fi
}

if [ "${variant}" == "paper" ]; then
	update_pmc.sh
	return
fi

# The location where the builds are checked and downloaded.
if [ "${variant}" == "fabric" ]; then
	remotelocation="fabricmc.net"
elif [ "${variant}" == "purpur" ]; then
	remotelocation="purpurmc.org"
else
	remotelocation="mojang.com"
fi

if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_remotebuild
	fn_update_dl
else
	fn_print_dots "Checking for update"
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	fn_update_localbuild
	fn_update_remotebuild
	fn_update_compare
fi
