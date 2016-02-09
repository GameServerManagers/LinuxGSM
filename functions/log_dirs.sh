#!/bin/bash

fn_create_log_dir() {
        target="${1}"
        link="${2}"
	createdir=${3:-1}
        if [ "${target}" == "" ]; then
                return;
        fi
        if [ ! -e "${target}" ] && [ $createdir -gt 0 ]; then
                mkdir -p "${target}"
        fi
        if [ "${link}" == "" ]; then
                return;
        fi
        if [ "$(readlink -f "${link}")" != "${target}" ] && [ -e "${target}" ]; then
	        if [ ! -e "$(dirname "${link}")" ]; then
        	        mkdir -p "$(dirname "${link}")"
	        fi
                ln -nfsv "${target}" "${link}"
        fi
}

fn_create_log_dir "${gamelogdir}" "${logdir}/server" 0
fn_create_log_dir "${scriptlogdir}"
fn_create_log_dir "${consolelogdir}"
fn_create_log_dir "${rootdir}/Steam/logs" "${logdir}/steamcmd"
fn_create_log_dir "${systemdir}/addons/sourcemod/logs" "${logdir}/sourcemod" 0

# Create dir's for the script and console logs
#touch "${scriptlog}"
#touch "${consolelog}"
#touch "${emaillog}"

# If a server is 7 Days to Die.
if [ "${gamename}" == "7 Days To Die" ]; then
        if [ ! -h "${gamelogdir}/output_log.txt" ]; then
                ln -nfsv "${filesdir}/7DaysToDie_Data/output_log.txt" "${gamelogdir}/output_log.txt"
        fi
fi

