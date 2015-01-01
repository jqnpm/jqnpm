#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function testJqExecutionWithNullInput () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	local result=$("$jqCommandUnderTest" --null-input)
	popd >/dev/null

	assertEquals "Result" '"from non-standard location"' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
