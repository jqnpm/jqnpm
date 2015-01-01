#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function testJqExecutionWithNullInput () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	local result=$("$jqCommandUnderTest" --null-input)
	popd >/dev/null

	assertEquals "Result" '"test output"' "$result"
}

function testJqExecutionWithNullInputAndRawOutput () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	local result=$("$jqCommandUnderTest" --null-input --raw-output)
	popd >/dev/null

	assertEquals "Result" 'test output' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
