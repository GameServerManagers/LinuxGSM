#!/bin/bash
GAMEDATA=../gamedata/
GAMELIST=${GAMEDATA}/__game_list
grep gamename ${GAMEDATA}/[a-z]* | grep -v 'README\.md' | sed -e 's/^[a-z0-9A-Z\/\.]\+\///g' -e 's/\:[ \t]*fn_set_game_params settings[ \t]*"gamename"[ \t]*/ /g' > ${GAMELIST}
