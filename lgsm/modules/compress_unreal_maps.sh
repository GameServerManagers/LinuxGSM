#!/bin/bash
# LinuxGSM compress_unreal_maps.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Compresses unreal and unreal2 resources.

commandname="MAP-COMPRESSOR"
commandaction="Compressing Maps"
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"
fn_firstcommand_set

check.sh
fn_print_header
echo -e "Will compress all maps in:"
echo -e ""
pwd
echo -e ""
echo -e "Compressed maps saved to:"
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
mkdir -pv "${compressedmapsdir}" > /dev/null 2>&1

# List of extensions to compress
exts="ut2 kfm rom u ucl upl int utx uax ukx usx unr umx umod uzx"

# Remove old compressed files using find
for ext in ${exts}; do
	mapfile -t oldfiles < <(find "${serverfiles}" -name "*.${ext}.uz2" -type f)
	if [ ${#oldfiles[@]} -gt 0 ]; then
		echo -e "found ${#oldfiles[@]} old compressed file(s) to remove for extension: ${ext}"
	fi
	for file in "${oldfiles[@]}"; do
		if rm -f "$file"; then
			echo -en "removing file [ ${italic}$(basename "$file")${default} ]\c"
			fn_print_ok_eol_nl
		else
			echo -en "removing file [ ${italic}$(basename "$file")${default} ]\c"
			fn_print_fail_eol_nl
		fi
	done
done

cd "${systemdir}" || exit

# Find and compress files, then move .uz2 to compressedmapsdir
for ext in ${exts}; do
	# Collect all files with the current extension into an array
	mapfile -t files < <(find "${serverfiles}" -name "*.${ext}" -type f)
	for file in "${files[@]}"; do
		echo -en "compressing file [ ${italic}$(basename "$file") -> $(basename "$file").uz2${default} ]\c"
		if ! ./ucc-bin compress "${file}" --nohomedir > /dev/null 2>&1; then
			fn_print_fail_eol_nl
			core_exit.sh
		else
			fn_print_ok_eol_nl
		fi

		if ! mv -f "${file}.uz2" "${compressedmapsdir}" > /dev/null 2>&1; then
			echo -en "moving compressed file [ ${italic}$(basename "$file").uz2 -> ${compressedmapsdir}/$(basename "$file").uz2${default} ]\c"
			fn_print_fail_eol_nl
			core_exit.sh
		fi
	done
done

fn_print_ok_nl "Compression complete: All compressed files moved to: ${compressedmapsdir}"

core_exit.sh
