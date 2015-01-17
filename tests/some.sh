#!/usr/bin/env bash
set -e

source "${BASH_SOURCE%/*}/shared-functions.sh"


function runSomeTests {
	for argument in "$@";
	do
		resolved=$(resolvePath "$argument")

		if [[ -d "$resolved" ]];
		then
			runTestsInFolder "$resolved"
		else
			runTestsInFile "$resolved"
		fi
	done
}


pushd "${BASH_SOURCE%/*}" >/dev/null
runSomeTests "$@"
popd >/dev/null
