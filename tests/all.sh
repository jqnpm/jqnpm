#!/usr/bin/env bash
set -e

function runAllTests {
    local LIGHT_BLUE="[1;34m"
    local NO_COLOUR="[0m"

	while IFS= read -r -d '' file;
	do
		local dirpath=$(dirname "$file")
		local dirname=$(basename -a "$dirpath")
		local filename=$(basename -a "$file")
		local shortTestPath="${dirname}/${filename}"

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
	done < <(find "$PWD" -mindepth 2 -maxdepth 2 -type f -name '*.sh' -print0)
}

pushd "${BASH_SOURCE%/*}" >/dev/null
runAllTests
popd >/dev/null
