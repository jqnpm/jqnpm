#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function cleanup {
	git clean -fdX "package-cache/" "local-project/" >/dev/null
}

function oneTimeSetUp () {
	cleanup
}

function tearDown () {
	cleanup
}

function testJqExecutionWithoutJqJsonNorMainJq () {
	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	local result=$(echo '{ "hello": "world" }' | "$jqCommandUnderTest")
	popd >/dev/null

	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"
	assertEquals "Result" '"main world"' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
