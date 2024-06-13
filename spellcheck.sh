#!/bin/bash

# When editing this file, please check whether the changes also need to be applied to the LinuxGSM and LinuxGSM-Dev-Docs repositories.

# Temporary file for cspell output
tempFile=$(mktemp)

# Run cspell on all files and capture the output
cspell "**" > "$tempFile" 2>&1

# Process the output to extract unique words and save them to spelling_errors.json
# This assumes that the spelling errors are identifiable in a specific format from cspell output
grep "Unknown word" "$tempFile" | grep -oP "\(\K[^\)]+" | sort -u | jq -R . | jq -s . > spelling_errors.json

# Cleanup
rm "$tempFile"

echo "Spelling errors have been saved to spelling_errors.json"
