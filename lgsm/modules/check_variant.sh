#!/bin/bash
# LinuxGSM check_variant.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Handles server variants and the --variant and --version options.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# Variants available for this game server. The first is the default.
fn_variant_list() {
	variants=()
	variantnames=()
	if [ "${shortname}" == "mc" ]; then
		variants=("vanilla" "fabric" "paper" "purpur")
		variantnames=("Vanilla" "Fabric" "PaperMC" "Purpur")
	fi
}

# Settings that change with the variant.
fn_variant_settings() {
	if [ "${shortname}" == "mc" ]; then
		if [ "${variant}" == "vanilla" ]; then
			variantexecutable="./minecraft_server.jar"
		elif [ "${variant}" == "fabric" ]; then
			variantexecutable="./fabric-server-launch.jar"
		elif [ "${variant}" == "paper" ]; then
			variantexecutable="./paper.jar"
		elif [ "${variant}" == "purpur" ]; then
			variantexecutable="./purpur.jar"
		fi
	fi
	if [ "${variant}" != "${variants[0]}" ] && [ -n "${variantexecutable}" ]; then
		executable="${variantexecutable}"
	fi
}

# The config setting that --version changes.
fn_variant_versionvar() {
	versionvar=""
	if [ "${shortname}" == "mc" ] || [ "${shortname}" == "pmc" ]; then
		versionvar="mcversion"
	fi
}

# Writes a setting to the config that already sets it, otherwise to common.cfg.
fn_variant_set_config() {
	local key="${1}"
	local value="${2}"
	local cfgfile=""
	local checkcfg
	for checkcfg in "${configdirserver}/secrets-${selfname}.cfg" "${configdirserver}/${selfname}.cfg" "${configdirserver}/secrets-common.cfg"; do
		if [ -f "${checkcfg}" ] && grep -qE "^[[:blank:]]*${key}=" "${checkcfg}"; then
			cfgfile="${checkcfg}"
			break
		fi
	done
	if [ -z "${cfgfile}" ]; then
		cfgfile="${configdirserver}/common.cfg"
	fi
	if grep -qE "^[[:blank:]]*${key}=" "${cfgfile}"; then
		sed -i -E "s|^[[:blank:]]*${key}=.*|${key}=\"${value}\"|" "${cfgfile}"
	else
		if [ -s "${cfgfile}" ] && [ -n "$(tail -c 1 "${cfgfile}")" ]; then
			echo "" >> "${cfgfile}"
		fi
		echo "${key}=\"${value}\"" >> "${cfgfile}"
	fi
	printf -v "${key}" '%s' "${value}"
	fn_print_ok_nl "Setting ${key} to ${value} in ${cfgfile##*/}"
	fn_script_log_pass "Setting ${key} to ${value} in ${cfgfile}"
}

fn_variant_parse_args() {
	local argcommands=(i install ai auto-install u update fu force-update)
	local argcommand
	local acceptargs=0
	local index
	local arg
	for argcommand in "${argcommands[@]}"; do
		if [ "${getopt}" == "${argcommand}" ]; then
			acceptargs=1
		fi
	done
	if [ "${acceptargs}" != "1" ]; then
		return
	fi
	# Scripts installed before options were supported do not pass them on.
	if ! declare -p lgsmargs > /dev/null 2>&1; then
		if [[ "${userinput2}" == --* ]]; then
			fn_print_fail_nl "Options need a newer ${selfname} script: run ./${selfname} update-lgsm first"
			fn_script_log_fail "Options need a newer ${selfname} script"
			core_exit.sh
		fi
		return
	fi
	for ((index = 1; index < ${#lgsmargs[@]}; index++)); do
		arg="${lgsmargs[index]}"
		if [[ "${arg}" == --variant=* ]]; then
			argvariant="${arg#*=}"
		elif [ "${arg}" == "--variant" ]; then
			((index++))
			argvariant="${lgsmargs[index]}"
		elif [[ "${arg}" == --version=* ]]; then
			argversion="${arg#*=}"
		elif [ "${arg}" == "--version" ]; then
			((index++))
			argversion="${lgsmargs[index]}"
		else
			fn_print_fail_nl "Unknown option: ${arg}"
			fn_script_log_fail "Unknown option: ${arg}"
			core_exit.sh
		fi
	done
}

fn_variant_prompt() {
	local answer
	local checkcfg
	local variantindex
	if [ "${getopt}" != "i" ] && [ "${getopt}" != "install" ]; then
		return
	fi
	if [ "${#variants[@]}" -lt 2 ] || [ -n "${argvariant+x}" ]; then
		return
	fi
	for checkcfg in "${configdirserver}/secrets-${selfname}.cfg" "${configdirserver}/${selfname}.cfg" "${configdirserver}/secrets-common.cfg" "${configdirserver}/common.cfg"; do
		if [ -f "${checkcfg}" ] && grep -qE "^[[:blank:]]*variant=" "${checkcfg}"; then
			return
		fi
	done
	echo -e ""
	echo -e "${bold}${lightyellow}Select ${gamename} Server Variant${default}"
	fn_messages_separator
	for variantindex in "${!variants[@]}"; do
		if [ "${variantindex}" -eq 0 ]; then
			echo -e "$((variantindex + 1))) ${variantnames[variantindex]} (default)"
		else
			echo -e "$((variantindex + 1))) ${variantnames[variantindex]}"
		fi
	done
	while true; do
		answer=""
		if ! read -e -p "Variant [1]: " -r answer && [ -z "${answer}" ]; then
			echo -e ""
		fi
		answer="${answer:-1}"
		if [[ "${answer}" =~ ^[0-9]+$ ]] && [ "${answer}" -ge 1 ] && [ "${answer}" -le "${#variants[@]}" ]; then
			argvariant="${variants[answer - 1]}"
			break
		elif [[ " ${variants[*]} " == *" ${answer} "* ]]; then
			argvariant="${answer}"
			break
		fi
		fn_print_warning_nl "Enter a number from 1 to ${#variants[@]}"
	done
	fn_variant_versionvar
	if [ -n "${versionvar}" ] && [ -z "${argversion+x}" ]; then
		while true; do
			answer=""
			if ! read -e -p "Version [${!versionvar:-latest}]: " -r answer && [ -z "${answer}" ]; then
				echo -e ""
			fi
			if [ -z "${answer}" ]; then
				break
			elif [[ "${answer}" =~ ^[A-Za-z0-9._+-]+$ ]]; then
				argversion="${answer}"
				break
			fi
			fn_print_warning_nl "Invalid version: ${answer}"
		done
	fi
}

fn_variant_apply_args() {
	if [ -n "${argvariant+x}" ]; then
		if [ "${#variants[@]}" -eq 0 ]; then
			fn_print_fail_nl "${gamename} has no variants"
			fn_script_log_fail "${gamename} has no variants"
			core_exit.sh
		fi
		if [[ " ${variants[*]} " != *" ${argvariant} "* ]]; then
			fn_print_fail_nl "Unknown variant: ${argvariant}. Available variants: ${variants[*]}"
			fn_script_log_fail "Unknown variant: ${argvariant}"
			core_exit.sh
		fi
		fn_variant_set_config "variant" "${argvariant}"
	fi
	if [ -n "${argversion+x}" ]; then
		fn_variant_versionvar
		if [ -z "${versionvar}" ]; then
			fn_print_fail_nl "${gamename} does not support --version"
			fn_script_log_fail "${gamename} does not support --version"
			core_exit.sh
		fi
		if [[ ! "${argversion}" =~ ^[A-Za-z0-9._+-]+$ ]]; then
			fn_print_fail_nl "Invalid version: ${argversion}"
			fn_script_log_fail "Invalid version: ${argversion}"
			core_exit.sh
		fi
		fn_variant_set_config "${versionvar}" "${argversion}"
	fi
}

# Records the variant now installed in serverfiles.
fn_variant_record() {
	if [ -n "${variant}" ] && [ -d "${serverfiles}" ]; then
		echo "${variant}" > "${serverfiles}/variant.txt"
		installedvariant="${variant}"
	fi
}

# Warns about data that does not carry across a variant change.
fn_variant_change_warning() {
	if [ "${shortname}" == "mc" ]; then
		if { [ "${installedvariant}" == "paper" ] || [ "${installedvariant}" == "purpur" ]; } && { [ "${variant}" == "vanilla" ] || [ "${variant}" == "fabric" ]; }; then
			fn_print_warning_nl "${installedvariantname} keeps the Nether and End in world_nether and world_the_end. ${variantname} does not load them from there."
			fn_script_log_warn "${installedvariantname} keeps the Nether and End in world_nether and world_the_end. ${variantname} does not load them from there."
		fi
		if [ "${installedvariant}" == "fabric" ] || [ "${variant}" == "fabric" ]; then
			fn_print_warning_nl "Mods and plugins are not shared between ${installedvariantname} and ${variantname}."
			fn_script_log_warn "Mods and plugins are not shared between ${installedvariantname} and ${variantname}."
		fi
	fi
	fn_print_info_nl "Take a backup before changing variant: ./${selfname} backup"
}

fn_variant_list
fn_variant_parse_args
fn_variant_prompt
fn_variant_apply_args

if [ "${#variants[@]}" -gt 0 ]; then
	if [ -z "${variant}" ]; then
		variant="${variants[0]}"
	fi
	variantname=""
	installedvariant="$(head -n 1 "${serverfiles}/variant.txt" 2> /dev/null)"
	installedvariant="${installedvariant:-${variants[0]}}"
	for variantindex in "${!variants[@]}"; do
		if [ "${variants[variantindex]}" == "${variant}" ]; then
			variantname="${variantnames[variantindex]}"
		fi
		if [ "${variants[variantindex]}" == "${installedvariant}" ]; then
			installedvariantname="${variantnames[variantindex]}"
		fi
	done
	if [ -z "${variantname}" ]; then
		fn_print_fail_nl "Unknown variant: ${variant}. Available variants: ${variants[*]}"
		fn_script_log_fail "Unknown variant: ${variant}"
		core_exit.sh
	fi
	fn_variant_settings
else
	unset variant
fi
