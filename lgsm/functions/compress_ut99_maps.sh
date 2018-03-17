#!/bin/bash
# LinuxGSM compress_ut99_maps.sh function
# Author: Daniel Gibbs
# Website: https://linuxgsm.com
# Description: Compresses unreal maps.

local commandaction="Unreal Map Compressor"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

check.sh
fn_print_header
echo "Will compress all maps in:"
echo ""
pwd
echo ""
echo "Compressed maps saved to:"
echo ""
echo "${compressedmapsdir}"
echo ""
if ! fn_prompt_yn "Start compression?" Y; then
	echo Exiting; return
fi
mkdir -pv "${compressedmapsdir}" > /dev/null 2>&1
rm -rfv "${serverfiles}/Maps/"*.unr.uz
cd "${systemdir}"
for map in "${serverfiles}/Maps/"*; do
	./ucc-bin compress "${map}" --nohomedir
done
mv -fv "${serverfiles}/Maps/"*.unr.uz "${compressedmapsdir}"
core_exit.sh
