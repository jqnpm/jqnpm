#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function testJqExecutionShortForm () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"
	assertTrue "jq/main.jq exists" "[[ -s 'local-project/jq/main.jq' ]]"
	assertTrue "other.jq exists" "[[ -s 'local-project/other.jq' ]]"

	pushd "local-project" >/dev/null
	local result=$("$jqCommandUnderTest" --null-input -f "other.jq")
	popd >/dev/null

	assertEquals "Result" '"other output"' "$result"
}

function testJqExecutionLongForm () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"
	assertTrue "jq/main.jq exists" "[[ -s 'local-project/jq/main.jq' ]]"
	assertTrue "other.jq exists" "[[ -s 'local-project/other.jq' ]]"

	pushd "local-project" >/dev/null
	local result=$("$jqCommandUnderTest" --null-input --from-file "other.jq")
	popd >/dev/null

	assertEquals "Result" '"other output"' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
