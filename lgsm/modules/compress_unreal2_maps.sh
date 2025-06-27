#!/bin/bash
# LinuxGSM compress_unreal2_maps.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Compresses unreal maps.

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
if ! fn_prompt_yn "Start compression?" Y; then
	exitcode=0
	core_exit.sh
fi
mkdir -pv "${compressedmapsdir}" > /dev/null 2>&1

# Remove old compressed files using find
echo -e "Removing old compressed .uz2 files..."
find "${serverfiles}" \( -name "*.ut2.uz2" -o -name "*.rom.uz2" -o -name "*.utx.uz2" -o -name "*.uax.uz2" -o -name "*.usx.uz2" -o -name "*.ukx.uz2" -o -name "*.u.uz2" -o -name "*.ogg.uz2" -o -name "*.int.uz2" \) -type f -exec rm -fv {} \;

echo -e "Searching for Unreal Engine files to compress..."
echo -e "Look in game config file for maps"

# mapext=$(awk -F= '/^[[:space:]]*MapExt[[:space:]]*=/ {gsub(/^[ \t"]+|[ \t"]+$/, "", $2); print $2; exit}' "${servercfgfullpath}")
# echo "Detected map extension: $mapext"

# List of extensions to compress (excluding .ogg)
exts="ut2 kfm rom u ucl upl ini int utx uax ukx usx"

# Remove old compressed files for these extensions
for ext in $exts; do
	find "${serverfiles}" -name "*.${ext}.uz2" -type f -exec rm -fv {} \;
done

cd "${systemdir}" || exit

# Find and compress files, then move .uz2 to compressedmapsdir
find "${serverfiles}" \( "$(for ext in $exts; do echo -name "*.${ext}" -o; done | sed 's/ -o$//')" \) -type f \
	-exec sh -c '
        compressedmapsdir="$1"
        file="$2"
        printf "Compressing: %s\n" "$file"
        ./ucc-bin compress "$file" --nohomedir && \
        printf "Moving: %s -> %s\n" "$file.uz2" "$compressedmapsdir" && \
        mv -fv "$file.uz2" "$compressedmapsdir"
    ' _ "${compressedmapsdir}" {} \;

echo -e "Compression complete. All .uz2 files moved to: ${compressedmapsdir}"

core_exit.sh
