#!/usr/bin/env bash
set -e

function runAllTests {
	while IFS= read -r -d '' file;
	do
		dirpath=$(dirname "$file")	
		dirname=$(basename -a "$dirpath")
		filename=$(basename -a "$file")
		echo "${dirname}/${filename}"

		# Execute tests in a subshell in their own directory.
		pushd "$dirpath" >/dev/null
		( "$file" )
		popd >/dev/null
	done < <(find "$PWD" -mindepth 2 -maxdepth 2 -type f -name '*.sh' -print0)
}

pushd "${BASH_SOURCE%/*}" >/dev/null
runAllTests
popd >/dev/null
