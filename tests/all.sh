#!/usr/bin/env bash
set -e

source "${BASH_SOURCE%/*}/shared-functions.sh"


function runAllTests {
	while IFS= read -r -d '' file;
	do
		runTestsInFile "$file"
	done < <(find "$PWD" -mindepth 2 -maxdepth 2 -type f -name '*.sh' -print0)
}


pushd "${BASH_SOURCE%/*}" >/dev/null
runAllTests "$@"
popd >/dev/null
