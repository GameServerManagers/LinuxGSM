#!/bin/bash
# LGSM fix_arma3.sh function
# Author: Daniel Gibbs
# Website: http://gameservermanagers.com
lgsm_version="271215"

# Fixes line 63: 20150 Segmentation fault (core dumped) #488

if [ -d "${rootdir}/.local/share/Arma\ 3" ]; then
	mkdir -p "${rootdir}/.local/share/Arma\ 3"
fi
