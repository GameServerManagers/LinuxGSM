#!/bin/bash

# Define Useful functions
function join_by { local IFS="$1"; shift; echo "$*"; }

function trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# Set RegExp to find functions and variables
funcregex="^([^#].*)\(\)"
varregex="^([^#].*)[^!]=(.*)"

# Declare the master game server array so we can iterate over all arrays at the end
gameservers=()

# find all files in config-default directory
while read line; do
   # Check if the file is the _default and regexp the server short name from the path
   if [[ $line =~ config-lgsm\/(.*)\/_default.cfg ]]; then
       # Get the short name from the regexp and declare the associative arrays for func and vars
       gameserver=${BASH_REMATCH[1]}
       echo "Processing ${gameserver}..."
       gameservers+=( "${gameserver}" )

       # Define dynamic arrays - func is standard array, whilst vars is [key]=value
       gameserverfuncs="${gameserver}funcs"
       gameservervars="${gameserver}vars"
       declare -a ${gameserverfuncs}
       declare -A ${gameservervars}

       # Read file, check for function matches an then check for var matches
       while IFS= read -r line; do

          #FUNCS
          if [[ ${line} =~ $funcregex ]]; then
               declare ${gameserverfuncs}+="${BASH_REMATCH[1]}"
          fi

          # VARS - note that the regex is greedy only, therefore additional work is required to make it work like a lazy one
          # Likewise we need to exclude comments
          if [[ ${line} =~ $varregex ]]; then
               parsedline=${line%%#*}
               IFS='=' read -r -a array <<< "${parsedline}"
               key=$(trim "${array[0]}")
               array=("${array[@]:1}") #removed the 1st element
               value=$(join_by "=" "${array[@]}")
               declare ${gameservervars}[${key}]="${value}"
          fi
       done < ${line}
   fi
done < <(find "${BASH_SOURCE%/*}/../lgsm/config-default/" -type f)
echo "Finished Analysing, Processing Output..."
# printf "%s\n" "${gameservers[@]}"

# OUTPUT RESULTS - for now STDOUT CSV, later to file
echo "gameserver,type,key,value" > "${BASH_SOURCE%/*}/../lgsm/data/default_parameters.csv"
for x in "${!gameservers[@]}"; do
    funcsname="${gameservers[$x]}funcs"
    varsname="${gameservers[$x]}vars"

    # FUNCTIONS
    declare -n funcsnameref="${funcsname}"
    if [[ ${#funcsnameref[@]} -gt 0 ]]; then
        for f in "${!funcsname[@]}"; do printf "%s,%s,%s,\n" "${gameservers[$x]}" "Function" "${!funcsname[$f]}" >> ${BASH_SOURCE%/*}/../lgsm/data/default_parameters.csv ; done
    fi
    #VARIABLES
    tmp="${varsname}"
    declare -nl pointer="$tmp"
    for i in "${!pointer[@]}"
    do
        value="${pointer[$i]}"
        # CSV needs to have quotes escaped with ""
        if [[ ${value:0:1} == "\"" && ${value: -1} == "\"" ]]; then
			substr=$(echo "${value}" | sed -r 's/"(.*)"/\1/g')
		else
			substr="${value}"
		fi
		escaped=$(echo "${substr}" | sed -r 's/"/""/g')
		value="\"${escaped}\""
        printf "%s,%s,%s,%s\n" "${gameservers[$x]}" "Parameter" "$i" "${value}" >> "${BASH_SOURCE%/*}/../lgsm/data/default_parameters.csv"
    done
done

# sort output
(head -n1 "${BASH_SOURCE%/*}/../lgsm/data/default_parameters.csv" && tail -n+2 "${BASH_SOURCE%/*}/../lgsm/data/default_parameters.csv" | sort -k1,1 -k2,2 -k3,3) > "${BASH_SOURCE%/*}/../lgsm/data/default_parameters_tmp.csv"
mv "${BASH_SOURCE%/*}/../lgsm/data/default_parameters_tmp.csv" "${BASH_SOURCE%/*}/../lgsm/data/default_parameters.csv"
# sort -k1,1 -k2,2 -k3,3 ../lgsm/data/default_parameters.csv -o ../lgsm/data/default_parameters.csv
