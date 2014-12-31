#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function cleanup {
	git clean -fdX . >/dev/null
}

function oneTimeSetUp () {
	cleanup
}

function tearDown () {
	cleanup
}

function testExecuteWithoutJqJsonNorMainJq () {
	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	local result=$(echo '{ "hello": "world" }' | jqnpm execute)
	popd >/dev/null

	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"
	assertEquals "Result" '"main world"' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
