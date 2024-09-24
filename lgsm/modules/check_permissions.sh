#!/bin/bash
# LinuxGSM check_permissions.sh
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Checks ownership & permissions of scripts, files and directories.

moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_check_ownership() {
	if [ -f "${rootdir}/${selfname}" ]; then
		if [ "$(find "${rootdir}/${selfname}" -not -user "$(whoami)" | wc -l)" -ne "0" ]; then
			selfownissue=1
		fi
	fi
	if [ -d "${lgsmdir}" ]; then
		if [ "$(find "${lgsmdir}" -not -user "$(whoami)" | wc -l)" -ne "0" ]; then
			lgsmownissue=1
		fi
	fi
	if [ -d "${modulesdir}" ]; then
		if [ "$(find "${modulesdir}" -not -name '*.swp' -not -user "$(whoami)" | wc -l)" -ne "0" ]; then
			funcownissue=1
		fi
	fi
	if [ -d "${serverfiles}" ]; then
		if [ "$(find "${serverfiles}" -not -name '*.swp' -not -user "$(whoami)" | wc -l)" -ne "0" ]; then
			filesownissue=1
		fi
	fi
	if [ "${selfownissue}" == "1" ] || [ "${lgsmownissue}" == "1" ] || [ "${filesownissue}" == "1" ]; then
		fn_print_fail_nl "Ownership issues found"
		fn_script_log_fail "Ownership issues found"
		fn_print_information_nl "The current user ($(whoami)) does not have ownership of the following files:"
		fn_script_log_info "The current user ($(whoami)) does not have ownership of the following files:"
		{
			echo -en "User\tGroup\tFile:"
			if [ "${selfownissue}" == "1" ]; then
				find "${rootdir}/${selfname}" -not -user "$(whoami)" -printf "%u\t%g\t%p\n"
			fi
			if [ "${lgsmownissue}" == "1" ]; then
				find "${lgsmdir}" -not -user "$(whoami)" -printf "%u\t%g\t%p\n"
			fi
			if [ "${filesownissue}" == "1" ]; then
				find "${serverfiles}" -not -user "$(whoami)" -printf "%u\t%g\t%p\n"
			fi

		} | column -s $'\t' -t | tee -a "${lgsmlog}"
		echo -e ""
		fn_print_information_nl "please see https://docs.linuxgsm.com/support/faq#fail-starting-game-server-permission-issues-found"
		fn_script_log "For more information, please see https://docs.linuxgsm.com/support/faq#fail-starting-game-server-permission-issues-found"
		if [ "${monitorflag}" == 1 ]; then
			alert="permissions"
			alert.sh
		fi
		core_exit.sh
	fi
}

fn_check_permissions() {
	# Check modules files are executable.
	if [ -d "${modulesdir}" ]; then
		findnotexecutable="$(find "${modulesdir}" -type f -not -executable)"
		findnotexecutablewc="$(find "${modulesdir}" -type f -not -executable | wc -l)"
		if [ "${findnotexecutablewc}" -ne "0" ]; then
			fn_print_error_nl "Permissions issues found"
			fn_script_log_error "Permissions issues found"
			fn_print_information_nl "The following files are not executable:"
			fn_script_log_info "The following files are not executable:"
			{
				echo -en "File:"
				echo -en "${findnotexecutable}"
			} | column -s $'\t' -t | tee -a "${lgsmlog}"

			# Attempt to make the files executable
			fn_print_information_nl "Attempting to fix permissions issues"
			fn_script_log_info "Attempting to fix permissions issues"
			echo "${findnotexecutable}" | xargs chmod +x

			# Re-check if there are still non-executable files
			findnotexecutable="$(find "${modulesdir}" -type f -not -executable)"
			findnotexecutablewc="$(find "${modulesdir}" -type f -not -executable | wc -l)"
			if [ "${findnotexecutablewc}" -ne "0" ]; then
				fn_print_fail_nl "Failed to resolve permissions issues"
				fn_script_log_fail "Failed to resolve permissions issues"
				if [ "${monitorflag}" == 1 ]; then
					alert="permissions"
					alert.sh
				fi
				core_exit.sh
			else
				fn_print_ok_nl "Permissions issues resolved"
				fn_script_log_pass "Permissions issues resolved"
			fi
		fi
	fi

	# Check rootdir permissions.
	if [ -d "${rootdir}" ]; then
		# Get permission numbers on directory should return 775.
		rootdirperm=$(stat -c %a "${rootdir}")
		# Grab the first and second digit for user and group permission.
		userrootdirperm="${rootdirperm:0:1}"
		grouprootdirperm="${rootdirperm:1:1}"
		if [ "${userrootdirperm}" != "7" ] && [ "${grouprootdirperm}" != "7" ]; then
			fn_print_fail_nl "Permissions issues found"
			fn_script_log_fail "Permissions issues found"
			fn_print_information_nl "The following directory does not have the correct permissions:"
			fn_script_log_info "The following directory does not have the correct permissions:"
			fn_script_log_info "${rootdir}"
			ls -l "${rootdir}"
			if [ "${monitorflag}" == 1 ]; then
				alert="permissions"
				alert.sh
			fi
			core_exit.sh
		fi
	fi

	# Check if executable is executable and attempt to fix it.
	# First get executable name.
	execname=$(basename "${executable}")
	if [ -f "${executabledir}/${execname}" ]; then
		# Get permission numbers on file under the form 775.
		execperm=$(stat -c %a "${executabledir}/${execname}")
		# Grab the first and second digit for user and group permission.
		userexecperm="${execperm:0:1}"
		groupexecperm="${execperm:1:1}"
		# Check for invalid user permission.
		if [ "${userexecperm}" == "0" ] || [ "${userexecperm}" == "2" ] || [ "${userexecperm}" == "4" ] || [ "${userexecperm}" == "6" ]; then
			# If user permission is invalid, then check for invalid group permissions.
			if [ "${groupexecperm}" == "0" ] || [ "${groupexecperm}" == "2" ] || [ "${groupexecperm}" == "4" ] || [ "${groupexecperm}" == "6" ]; then
				# If permission issues are found.
				fn_print_warn_nl "Permissions issue found"
				fn_script_log_warn "Permissions issue found"
				fn_print_information_nl "The following file is not executable:"
				ls -l "${executabledir}/${execname}"
				fn_script_log_info "The following file is not executable:"
				fn_script_log_info "${executabledir}/${execname}"
				fn_print_information_nl "Applying chmod u+x,g+x ${executabledir}/${execname}"
				fn_script_log_info "Applying chmod u+x,g+x ${execperm}"
				# Make the executable executable.
				chmod u+x,g+x "${executabledir}/${execname}"
				# Second check to see if it's been successfully applied.
				# Get permission numbers on file under the form 775.
				execperm=$(stat -c %a "${executabledir}/${execname}")
				# Grab the first and second digit for user and group permission.
				userexecperm="${execperm:0:1}"
				groupexecperm="${execperm:1:1}"
				if [ "${userexecperm}" == "0" ] || [ "${userexecperm}" == "2" ] || [ "${userexecperm}" == "4" ] || [ "${userexecperm}" == "6" ]; then
					if [ "${groupexecperm}" == "0" ] || [ "${groupexecperm}" == "2" ] || [ "${groupexecperm}" == "4" ] || [ "${groupexecperm}" == "6" ]; then
						# If errors are still found.
						fn_print_fail_nl "The following file could not be set executable:"
						ls -l "${executabledir}/${execname}"
						fn_script_log_warn "The following file could not be set executable:"
						fn_script_log_info "${executabledir}/${execname}"
						if [ "${monitorflag}" == "1" ]; then
							alert="permissions"
							alert.sh
						fi
						core_exit.sh
					fi
				fi
			fi
		fi
	fi
}

## The following fn_sys_perm_* function checks for permission errors in /sys directory.

# Checks for permission errors in /sys directory.
fn_sys_perm_errors_detect() {
	# Reset test variables.
	sysdirpermerror="0"
	classdirpermerror="0"
	netdirpermerror="0"
	# Check permissions.
	# /sys, /sys/class and /sys/class/net should be readable & executable.
	if [ ! -r "/sys" ] || [ ! -x "/sys" ]; then
		sysdirpermerror="1"
	fi
	if [ ! -r "/sys/class" ] || [ ! -x "/sys/class" ]; then
		classdirpermerror="1"
	fi
	if [ ! -r "/sys/class/net" ] || [ ! -x "/sys/class/net" ]; then
		netdirpermerror="1"
	fi
}

# Display a message on how to fix the issue manually.
fn_sys_perm_fix_manually_msg() {
	echo -e ""
	fn_print_information_nl "This error causes servers to fail starting properly"
	fn_script_log_info "This error causes servers to fail starting properly."
	echo -e "	* To fix this issue, run the following command as root:"
	fn_script_log_info "To fix this issue, run the following command as root:"
	echo -e "	  chmod a+rx /sys /sys/class /sys/class/net"
	fn_script_log "chmod a+rx /sys /sys/class /sys/class/net"
	fn_sleep_time_5
	if [ "${monitorflag}" == 1 ]; then
		alert="permissions"
		alert.sh
	fi
	core_exit.sh
}

# Attempt to fix /sys related permission errors if sudo is available, exits otherwise.
fn_sys_perm_errors_fix() {
	if sudo -n true > /dev/null 2>&1; then
		fn_print_dots "Fixing /sys permissions"
		fn_script_log_info "Fixing /sys permissions."
		if [ "${sysdirpermerror}" == "1" ]; then
			sudo chmod a+rx "/sys"
		fi
		if [ "${classdirpermerror}" == "1" ]; then
			sudo chmod a+rx "/sys/class"
		fi
		if [ "${netdirpermerror}" == "1" ]; then
			sudo chmod a+rx "/sys/class/net"
		fi
		# Run check again to see if it's fixed.
		fn_sys_perm_errors_detect
		if [ "${sysdirpermerror}" == "1" ] || [ "${classdirpermerror}" == "1" ] || [ "${netdirpermerror}" == "1" ]; then
			fn_print_error "Could not fix /sys permissions"
			fn_script_log_error "Could not fix /sys permissions."

			# Show the user how to fix.
			fn_sys_perm_fix_manually_msg
		else
			fn_print_ok_nl "Fixing /sys permissions"
			fn_script_log_pass "Permissions in /sys fixed"
		fi
	else
		# Show the user how to fix.
		fn_sys_perm_fix_manually_msg
	fi
}

# Processes to the /sys related permission errors check & fix/info.
fn_sys_perm_error_process() {
	fn_sys_perm_errors_detect
	# If any error was found.
	if [ "${sysdirpermerror}" == "1" ] || [ "${classdirpermerror}" == "1" ] || [ "${netdirpermerror}" == "1" ]; then
		fn_print_dots "Checking /sys permissions"
		fn_print_error_nl "Checking /sys permissions"
		fn_script_log_error "Checking /sys permissions"
		# Run the fix
		fn_sys_perm_errors_fix
	fi
}

## Run permisions checks when not root.
if [ "$(whoami)" != "root" ]; then
	fn_check_ownership
	fn_check_permissions
	if [ "${commandname}" == "START" ]; then
		fn_sys_perm_error_process
	fi
fi
