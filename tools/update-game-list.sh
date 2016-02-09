#!/bin/bash
GAMEDATA=../gamedata
MODDATA=${GAMEDATA}/mods
GAMELIST=${GAMEDATA}/__game_list
MODLIST=${GAMEDATA}/__mod_list
GAMEFILES=$(find "${GAMEDATA}" -maxdepth 1 -type f | egrep -v '(\/_|README.md)')
#-printf '"%p" ')
MODFILES=$(find "${MODDATA}" -type f)
# -printf '"%p" ')
#echo $GAMEFILES
#echo $MODFILES
egrep -H '"(mod|game)name"' ${GAMEFILES} | sed -e 's/^[a-z0-9A-Z\/\.]\+\///g' -e 's/[\:\t ]\+/ /g' -e 's/fn_set[^ ]\+ [^ ]\+ [^ ]\+ //g' | sort -u > ${GAMELIST}
egrep -H '"(mod|game)name"' ${MODFILES} | sed -e "s|${MODDATA}[\/]*||g" -e 's/[\:\t ]\+/ /g' -e 's/fn_set[^ ]\+ [^ ]\+ [^ ]\+ //g' | sort -u > ${MODLIST}

#[ \t]*fn_set_game_[^ \t]*[ \t]+[^ \t]+[ \t]*"(mod|game)name"[ \t]*/ /g'
#| sed -e 's/^[a-z0-9A-Z\/\.]\+\///g' -e 's/\:[ \t]*fn_set_game_\(param|setting\).* [^ \t]\+[ \t]*"modname"[ \t]*/ /g'

