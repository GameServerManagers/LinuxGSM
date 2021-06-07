#!/bin/bash
# LinuxGSM update_fabricmc.sh function
# Author: Ceddicedced
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles updating of FabricMC servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_install_fabric(){
	# get build info
    installername=$(echo -e "fabric-installer-${latestfabricinstaller}.jar")
    installersha256=$(curl "https://${remotelocation}/net/fabricmc/fabric-installer/${latestfabricinstaller}/${installername}.sha256")
	fn_fetch_file "https://${remotelocation}/net/fabricmc/fabric-installer/${latestfabricinstaller}/${installername}" "" "" "" "${tmpdir}" "fabric-installer.jar" "nochmodx" "norun" "force" "${installersha256}"
	echo -e "Generating Fabric jars...\c"
	java -jar ${tmpdir}/fabric-installer.jar server -dir ${serverfiles} -mcversion ${mcversion} -downloadMinecraft &> ${logdir}/script/fabric-installer.log
	local exitcode=$?
	if [ "${exitcode}" == "0" ]; then
		fn_print_ok_eol_nl
		fn_script_log_pass "Generating Fabric jars"
		chmod u+x "${serverfiles}/${executable#./}"
		echo "${latestfabricloader}" > "${localversionfile}"
		fn_clear_tmp
	else
		fn_print_fail_eol_nl
		fn_script_log_fatal "Generating Fabric jars with loader ${installername} and version ${mcversion}"
		core_exit.sh
	fi
}

fn_update_fabricmc_localbuild(){
	# Gets local build info.
	fn_print_dots "Checking for update: ${remotelocation}: checking local build"
	sleep 0.5

	if [ ! -f "${localversionfile}" ]; then
		fn_print_error_nl "Checking for update: ${remotelocation}: checking local build: no local build files"
		fn_script_log_error "No local build file found"
	else
		localbuild=$(head -n 1 "${localversionfile}")
	fi

	if [ -z "${localbuild}" ]; then
		localbuild="0"
		fn_print_error "Checking for update: ${remotelocation}: waiting for local build: missing local build info"
		fn_script_log_error "Missing local build info, Set localbuild to 0"
	else
		fn_print_ok "Checking for update: ${remotelocation}: checking local build"
		fn_script_log_pass "Checking local build"
	fi
	sleep 0.5
}

fn_update_fabricmc_remotebuild(){
	# Gets remote build info.
	latestfabricinstaller=$(curl -s https://${remotelocation}/net/fabricmc/fabric-installer/maven-metadata.xml | grep -oPm1 "(?<=<latest>)[^<]+")
	latestfabricloader=$(curl -s https://${remotelocation}/net/fabricmc/fabric-loader/maven-metadata.xml | grep -oPm1 "(?<=<latest>)[^<]+")
	# Checks if latestfabricloader variable has been set.
	if [ -z "${latestfabricinstaller}" ]||[ -z "${latestfabricloader}" ]; then
		fn_print_failure "Unable to get remote build"
		fn_script_log_fatal "Unable to get remote build"
		core_exit.sh
	else
		fn_print_ok "Latest Fabric loader version ${latestfabricloader}"
		fn_script_log "Latest Fabric loader version ${latestfabricloader}"
	fi
}

fn_update_fabricmc_compare(){
	fn_print_dots "Checking for update: ${remotelocation}"
	sleep 0.5
	if [ "${localbuild}" != "${latestfabricloader}" ]||[ "${forceupdate}" == "1" ]; then
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "Update available for version ${latestfabricinstaller}"
		echo -e "* Local build: ${red}${localbuild}${default}"
		echo -e "* Remote build: ${green}${latestfabricloader}${default}"
		fn_script_log_info "Update available for version ${mcversion}"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${latestfabricloader}"
		fn_script_log_info "${localbuild} > ${latestfabricloader}"
		echo -en "\n"
		echo -en "applying update.\r"
		echo -en "\n"

		unset updateonstart

		check_status.sh
		# If server stopped.
		if [ "${status}" == "0" ]; then
			fn_install_fabric
		# If server started.
		else
			exitbypass=1
			command_stop.sh
			exitbypass=1
			fn_install_fabric
			exitbypass=1
			command_start.sh
		fi
		alert="update"
		alert.sh
	else
		fn_print_ok_nl "Checking for update: ${remotelocation}"
		echo -en "\n"
		echo -e "No update available for version ${mcversion}"
		echo -e "* Local build: ${green}${localbuild}${default}"
		echo -e "* Remote build: ${green}${latestfabricloader}${default}"
		fn_script_log_info "No update available"
		fn_script_log_info "Local build: ${localbuild}"
		fn_script_log_info "Remote build: ${latestfabricloader}"
	fi
}


# The location where the builds are checked and downloaded.
remotelocation="maven.fabricmc.net"


localversionfile="${datadir}/fabricmc-version"

# check if datadir was created, if not create it
if [ ! -d "${datadir}" ]; then
	mkdir -p "${datadir}"
fi


if [ "${mcversion}" == "latest" ]; then
	mcversion=$(curl -s "https://launchermeta.mojang.com/mc/game/version_manifest.json" | jq -r '.latest.release')
fi




if [ "${firstcommandname}" == "INSTALL" ]; then
	fn_update_fabricmc_remotebuild
	fn_install_fabric
else
	fn_print_dots "Checking for update: ${remotelocation}"
	fn_script_log_info "Checking for update: ${remotelocation}"
	sleep 0.5
	fn_update_fabricmc_localbuild
	fn_update_fabricmc_remotebuild
	fn_update_fabricmc_compare
fi
