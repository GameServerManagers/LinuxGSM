#!/bin/bash
# LinuxGSM install_hlwon.sh module
# Author: Daniel Gibbs
# Contributors: https://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Installs the native protocol 46 Half-Life WON2 server.

# shellcheck disable=SC2034
moduleselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

won2url="https://raw.githubusercontent.com/Ch0wW/docker-hlds-won2/6f10592b2cec307d9e3b0f288a2d093ef43dc7c9"

fn_fetch_file "https://web.archive.org/web/20221208044729/http://dl.4players.de/f0/4players/halflife/server/linux/hlds_l_3111_full.bin" "" "" "" "${tmpdir}" "hlds_l_3111_full.bin" "nochmodx" "norun" "noforce" "d9c9cb32a55a814ae6fd6e36568ea9c8"
tail -c +8338 "${tmpdir}/hlds_l_3111_full.bin" | head -c 121907818 > "${tmpdir}/hlds_l_3111_full.tar.gz"
fn_dl_extract "${tmpdir}" "hlds_l_3111_full.tar.gz" "${serverfiles}" "hlds_l"

fn_fetch_file "${won2url}/install/hlds_l_3111e_update.tar.gz" "" "" "" "${tmpdir}" "hlds_l_3111e_update.tar.gz" "nochmodx" "norun" "noforce" "79baaaf4b3c7902928047f30917dc635"
fn_dl_extract "${tmpdir}" "hlds_l_3111e_update.tar.gz" "${serverfiles}" "hlds_l"

fn_fetch_file "${won2url}/patch/hlds_run" "" "" "" "${serverfiles}" "hlds_run" "chmodx" "norun" "forcedl" "d0eede0d87ec6ba5ee07d38ffcdff762"
fn_fetch_file "${won2url}/patch/nowon.so" "" "" "" "${serverfiles}" "nowon.so" "nochmodx" "norun" "noforce" "da6f293808a6030919f6085abb01cff3"
fn_fetch_file "${won2url}/patch/hlds_20040707fix.so" "" "" "" "${serverfiles}" "hlds_20040707fix.so" "nochmodx" "norun" "noforce" "021ed516e44c71121742a85c8655e360"
fn_fetch_file "${won2url}/patch/hlshield.so" "" "" "" "${serverfiles}" "hlshield.so" "nochmodx" "norun" "noforce" "07297d332cb5c93a2bdbc287ac72a624"
fn_fetch_file "${won2url}/config/valve/valvecomm.lst" "" "" "" "${serverfiles}/valve" "valvecomm.lst" "nochmodx" "norun" "forcedl" "384b7e260d5ca61565ceba7a6695c4ff"
fn_clear_tmp
