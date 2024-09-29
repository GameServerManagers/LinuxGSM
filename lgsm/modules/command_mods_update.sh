#!/bin/bash
# LinuxGSM command_mods_update.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Updates installed mods along with mods_list.sh and mods_core.sh.

commandname="MODS-UPDATE"
commandaction="Updating mods"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
mods_core.sh

# Prevents specific files being overwritten upon update (set by ${modkeepfiles}).
# For that matter, remove cfg files after extraction before copying them to destination.
fn_remove_cfg_files() {
	if [ "${modkeepfiles}" != "OVERWRITE" ] && [ "${modkeepfiles}" != "NOUPDATE" ]; then
		echo -e "the following files/directories will be preserved:"
		fn_sleep_time_1
		# Count how many files there are to remove.
		filestopreserve=$(echo -e "${modkeepfiles}" | awk -F ';' '{ print NF }')
		# Test all subvalues of "modkeepfiles" using the ";" separator.
		for ((preservefilesindex = 1; preservefilesindex < filestopreserve; preservefilesindex++)); do
			# Put the current file we are looking for into a variable.
			filetopreserve=$(echo -e "${modkeepfiles}" | awk -F ';' -v x=${preservefilesindex} '{ print $x }')
			echo -e "	* serverfiles/${filetopreserve}"
			# If it matches an existing file that have been extracted delete the file.
			if [ -f "${extractdest}/${filetopreserve}" ] || [ -d "${extractdest}/${filetopreserve}" ]; then
				rm -r "${extractdest:?}/${filetopreserve}"
				# Write the file path in a tmp file, to rebuild a full file list as it is rebuilt upon update.
				if [ ! -f "${modsdir}/.removedfiles.tmp" ]; then
					touch "${modsdir}/.removedfiles.tmp"
				fi
				echo -e "${filetopreserve}" >> "${modsdir}/.removedfiles.tmp"
			fi
		done
	fi
}

fn_print_dots "Update addons/mods"
fn_mods_check_installed
fn_print_info_nl "Update addons/mods: ${installedmodscount} addons/mods will be updated"
fn_script_log_info "${installedmodscount} mods or addons will be updated"
fn_mods_installed_list
# Go through all available commands, get details and display them to the user.
for ((ulindex = 0; ulindex < ${#installedmodslist[@]}; ulindex++)); do
	# Current mod is the "ulindex" value of the array we're going through.
	currentmod="${installedmodslist[ulindex]}"
	fn_mod_get_info
	# Display installed mods and the update policy.
	if [ -z "${modkeepfiles}" ]; then
		# If modkeepfiles is not set for some reason, that's a problem.
		fn_script_log_error "Could not find update policy for ${modprettyname}"
		fn_print_error_nl "Could not find update policy for ${modprettyname}"
		exitcode="1"
		core_exit.sh
	# If the mod won't get updated.
	elif [ "${modkeepfiles}" == "NOUPDATE" ]; then
		echo -e "	* ${red}{modprettyname}${default} (won't be updated)"
	# If the mode is just overwritten.
	elif [ "${modkeepfiles}" == "OVERWRITE" ]; then
		echo -e "	* ${modprettyname} (overwrite)"
	else
		echo -e "	* ${yellow}${modprettyname}${default} (retain common custom files)"
	fi
done

## Update
# List all installed mods and apply update.
# Reset line value.
installedmodsline="1"
while [ "${installedmodsline}" -le "${installedmodscount}" ]; do
	currentmod=$(sed "${installedmodsline}q;d" "${modsinstalledlistfullpath}")
	if [ "${currentmod}" ]; then
		fn_mod_get_info
		# Don not update mod if the policy is set to "NOUPDATE".
		if [ "${modkeepfiles}" == "NOUPDATE" ]; then
			fn_print_info "${modprettyname} will not be updated to preserve custom files"
			fn_script_log_info "${modprettyname} will not be updated to preserve custom files"
		else
			echo -e ""
			echo -e "==> Updating ${modprettyname}"
			fn_create_mods_dir
			fn_mods_clear_tmp_dir
			fn_mods_create_tmp_dir
			fn_mod_install_files
			fn_mod_lowercase
			fn_remove_cfg_files
			fn_mod_create_filelist
			fn_mod_copy_destination
			fn_mod_add_list
			fn_mod_tidy_files_list
			fn_mods_clear_tmp_dir
		fi
		((installedmodsline++))
	else
		fn_print_fail "No mod was selected"
		fn_script_log_fail "No mod was selected"
		exitcode="1"
		core_exit.sh
	fi
done
echo -e ""
fn_print_ok_nl "Mods update complete"
fn_script_log_info "Mods update complete"

core_exit.sh
