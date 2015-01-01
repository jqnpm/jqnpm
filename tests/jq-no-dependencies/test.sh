#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function testExecuteWithNullInput () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	result=$(jqnpm execute --null-input)
	popd >/dev/null

	assertEquals "Result" '"test output"' "$result"
}

function testExecuteWithNullInputAndRawOutput () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	local result=$(jqnpm execute --null-input --raw-output)
	popd >/dev/null

	assertEquals "Result" 'test output' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
