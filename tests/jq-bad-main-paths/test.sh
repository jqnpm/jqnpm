#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function singleJqExecutionWithBadJqJsonMainPath () {
	localProjectDirectory="$1"

	assertTrue "jq.json exists" "[[ -s '$localProjectDirectory/jq.json' ]]"

	pushd "$localProjectDirectory" >/dev/null
	# "Normally jq exits with 2 if there was any usage problem or system error"
	# NOTE: hiding the output as `jq` is expected *not* to work.
	# NOTE: debugging output is also hidden.
	"$jqCommandUnderTest" --null-input &>/dev/null
	local result="$?"
	popd >/dev/null

	assertEquals "Result" '2' "$result"
}


function testAllJqExecutionWithBadJqJsonMainPath () {
	while IFS= read -r -d '' dirpath;
	do
		dirname=$(basename -a "$dirpath")
		echo "Subdirectory: '${dirname}'"

		singleJqExecutionWithBadJqJsonMainPath "$dirname"
	done < <(find "$PWD" -mindepth 1 -maxdepth 1 -type d -print0)
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
