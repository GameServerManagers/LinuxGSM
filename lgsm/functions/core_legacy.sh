#!/bin/bash
# LinuxGSM core_legacy.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Code for backwards compatability with older versions of LinuxGSM.

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

# This is to help the transition to v20.3.0 and above
legacy_versions_array=( v20.2.1 v20.2.0 v20.1.5 v20.1.4 v20.1.3 v20.1.2 v20.1.1 v20.1.0 v19.12.5 v19.12.4 v19.12.3 v19.12.2 v19.12.1 v19.12.0 )
for legacy_version in "${legacy_versions_array[@]}"; do
	if [ "${version}" == "${legacy_version}" ]; then
		legacymode=1
	fi
done

if [ -z "${serverfiles}" ]; then
	serverfiles="${filesdir}"
fi

if [ -z "${logdir}" ]; then
	logdir="${rootdir}/log"
fi

if [ -z "${lgsmlogdir}" ]; then
	lgsmlogdir="${scriptlogdir}"
fi

if [ -z "${lgsmlog}" ]; then
	lgsmlog="${scriptlog}"
fi

if [ -z "${lgsmlogdate}" ]; then
	lgsmlogdate="${scriptlogdate}"
fi

if [ -z "${steamcmddir}" ]; then
	steamcmddir="${HOME}/.steam/steamcmd"
fi

if [ -z "${lgsmdir}" ]; then
	lgsmdir="${rootdir}/lgsm"
fi

if [ -z "${tmpdir}" ]; then
	tmpdir="${lgsmdir}/tmp"
fi

if [ -z "${alertlog}" ]; then
	alertlog="${emaillog}"
fi

if [ -z "${servicename}" ]; then
	servicename="${selfname}"
fi

# Alternations to workshop variables.
if [ -z "${wsapikey}" ]; then
	if [ "${workshopauth}" ]; then
		wsapikey="${workshopauth}"
	elif [ "${authkey}" ]; then
		wsapikey="${authkey}"
	fi
fi

if [ -z "${wscollectionid}" ]; then
	if [ "${workshopauth}" ]; then
		wscollectionid="${ws_collection_id}"
	elif [ "${authkey}" ]; then
		wscollectionid="${workshopcollectionid}"
	fi
fi

if [ -z "${wsstartmap}" ]; then
	if [ "${ws_start_map}" ]; then
		wscollectionid="${ws_start_map}"
	fi
fi
