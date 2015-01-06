#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../prepare.sh"


function oneTimeSetUp () {
	export JQNPM_PACKAGES_CACHE="${BASH_SOURCE%/*}/package-cache"
	export JQNPM_REMOTE_BASE="${BASH_SOURCE%/*}/remote-base"
	export JQNPM_REMOTE_SUFFIX=".bundle"

	# Clean up before tests, in case previous run crashed.
	cleanup
}

function cleanup {
	rm -rf "package-cache/anotheruser/"
	rm -rf "package-cache/someuser/"
	git clean -fdX "package-cache/" "local-project/" >/dev/null
}

function tearDown () {
	cleanup
}

function testJqExecution () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project/one/two" >/dev/null
	if jqnpm install;
	then
		local result=$("$jqCommandUnderTest" --null-input --raw-output)
	fi
	popd >/dev/null

	assertTrue "Package anotheruser/pack1 is installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertEquals "Result" 'abcdef' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
