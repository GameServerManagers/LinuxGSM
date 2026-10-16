#!/bin/bash
# LinuxGSM compress_unreal_maps.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Compresses unreal and unreal2 custom content for HTTP redirect.

commandname="MAP-COMPRESSOR"
commandaction="Compressing Maps"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh

if [ "${engine}" == "unreal" ]; then
	compressext="uz"
	compressargs=()
else
	compressext="uz2"
	compressargs=(--nohomedir)
fi

# Package types clients can download from a redirect server.
exts=(u ut2 kfm rom unr utx uax usx ukx umx)
stockcontentfile="${shortname}-stock-content.md5"

fn_print_header
echo -e "Will compress custom content in:"
echo -e ""
echo -e "${serverfiles}"
echo -e ""
echo -e "Compressed files saved to:"
echo -e ""
echo -e "${compressedmapsdir}"
echo -e ""
totalseconds=3
for seconds in {3..1}; do
	fn_print_warn "map compression starting in: ${totalseconds}"
	totalseconds=$((totalseconds - 1))
	fn_sleep_time_1
	if [ "${seconds}" == "0" ]; then
		break
	fi
done
fn_print_nl

fn_fetch_file_github "lgsm/data" "${stockcontentfile}" "${datadir}" "nochmodx" "norun" "forcedl" "nohash"
declare -A stockcontent
while read -r md5 filename; do
	stockcontent["${filename}"]+=" ${md5} "
done < "${datadir}/${stockcontentfile}"

if ! mkdir -p "${compressedmapsdir}"; then
	fn_print_fail_nl "Unable to create ${compressedmapsdir}"
	fn_script_log_fail "Unable to create ${compressedmapsdir}"
	core_exit.sh
fi

findargs=()
for ext in "${exts[@]}"; do
	findargs+=(-o -iname "*.${ext}")
done
mapfile -t files < <(find "${serverfiles}" -type f \( "${findargs[@]:1}" \) | sort)

cd "${executabledir}" || core_exit.sh

declare -A keepfiles
compressedcount=0
uptodatecount=0
stockcount=0
removedcount=0
failedfiles=()
for file in "${files[@]}"; do
	filename="$(basename "${file}")"
	if [ -n "${stockcontent["${filename}"]}" ]; then
		md5="$(md5sum "${file}" | awk '{print $1}')"
		if [[ "${stockcontent["${filename}"]}" == *" ${md5} "* ]]; then
			stockcount=$((stockcount + 1))
			continue
		fi
	fi
	compressedfile="${compressedmapsdir}/${filename}.${compressext}"
	keepfiles["${filename}.${compressext}"]=1
	if [ -f "${compressedfile}" ] && [ "${compressedfile}" -nt "${file}" ]; then
		uptodatecount=$((uptodatecount + 1))
		continue
	fi
	echo -en "compressing file [ ${italic}${filename} -> ${filename}.${compressext}${default} ]\c"
	uccoutput="$("${executable}" compress "${file}" "${compressargs[@]}" 2>&1)"
	if grep -qF "Compressed ${file} -> ${file}.${compressext}" <<< "${uccoutput}" && [ -f "${file}.${compressext}" ] && mv -f "${file}.${compressext}" "${compressedfile}"; then
		fn_print_ok_eol_nl
		compressedcount=$((compressedcount + 1))
	else
		fn_print_fail_eol_nl
		fn_script_log_error "Compressing ${file}"
		rm -f "${file:?}.${compressext}"
		failedfiles+=("${filename}")
	fi
done

mapfile -t oldfiles < <(find "${compressedmapsdir}" -maxdepth 1 -type f -name "*.${compressext}")
for file in "${oldfiles[@]}"; do
	filename="$(basename "${file}")"
	if [ -z "${keepfiles["${filename}"]}" ]; then
		echo -en "removing old compressed file [ ${italic}${filename}${default} ]\c"
		if rm -f "${file}"; then
			fn_print_ok_eol_nl
			removedcount=$((removedcount + 1))
		else
			fn_print_fail_eol_nl
		fi
	fi
done

echo -e ""
echo -e "Compressed: ${compressedcount}"
echo -e "Already up to date: ${uptodatecount}"
echo -e "Stock content skipped: ${stockcount}"
echo -e "Old files removed: ${removedcount}"
fn_script_log_info "Compressed: ${compressedcount}, up to date: ${uptodatecount}, stock skipped: ${stockcount}, removed: ${removedcount}, failed: ${#failedfiles[@]}"
echo -e ""
if [ "${#failedfiles[@]}" -gt 0 ]; then
	fn_print_warn_nl "Failed to compress ${#failedfiles[@]} file(s): ${failedfiles[*]}"
	fn_script_log_warn "Failed to compress: ${failedfiles[*]}"
	exitcode=3
else
	fn_print_ok_nl "Compression complete: compressed files saved to: ${compressedmapsdir}"
	fn_script_log_pass "Compression complete"
fi
echo -e ""
echo -e "Upload ${compressedmapsdir} to a web server, then set in ${servercfgfullpath}:"
echo -e ""
echo -e "[IpDrv.HTTPDownload]"
echo -e "RedirectToURL=http://example.com/path/"
echo -e "UseCompression=True"

core_exit.sh
