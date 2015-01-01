#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function testImportRelativeJqFiles () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	local result=$("$jqCommandUnderTest" --null-input)
	popd >/dev/null

	assertEquals "Result" '"main.jq|same folder|subfolder|sibling folder|parent folder|folder outside of package"' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
