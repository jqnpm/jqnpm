#!/bin/bash

function resolveDirectory {
	(cd -- "$1"; echo -nE "$PWD")
}

# Isn't there a better way to do this? String wise ./ and ../ squisher that doesn't re-parse directories/links?
function resolvePath {
	if [[ -d "$1" ]];
	then
		resolveDirectory "$1"
	else
		echo "$(resolveDirectory "$(dirname "$1")")/$(basename -a "$1")"
	fi
}

function runTestsInFile {
	file="$1"
	shift

	local dirpath=$(dirname "$file")
	local dirname=$(basename -a "$dirpath")
	local filename=$(basename -a "$file")
	local shortTestPath="${dirname}/${filename}"

    local LIGHT_BLUE="[1;34m"
    local NO_COLOUR="[0m"

	echo
	echo -nE "------------------------- "
	echo -ne "${LIGHT_BLUE}"
	echo -nE "$shortTestPath"
	echo -ne "${NO_COLOUR}"
	echo -nE " -------------------------"
	echo

	# Execute tests in a subshell in their own directory.
	pushd "$dirpath" >/dev/null
	( "$file" )
	popd >/dev/null
}

function runTestsInFolder {
	folder="$1"
	shift

	while IFS= read -r -d '' file;
	do
		runTestsInFile "$file"
	done < <(find "$folder" -mindepth 1 -maxdepth 1 -type f -name '*.sh' -print0)
}
