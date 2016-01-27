#!/bin/bash
grep gamename ../gamedata/[a-z]* | grep -v 'README\.md' | sed -e 's/^[a-z0-9A-Z\/\.]\+\///g' -e 's/\:[ \t]*fn_set_game_params settings[ \t]*"gamename"[ \t]*/ /g' > ../gamedata/__game_list
