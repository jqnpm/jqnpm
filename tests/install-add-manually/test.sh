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

	pushd "local-project" >/dev/null
	jqnpm install
	assertTrue "Package is installed" "[[ -d '.jq/packages/anotheruser/pack1/' ]]"
	assertFalse "Package is not installed" "[[ -d '.jq/packages/someuser/pack2/' ]]"
	pushd "one/two" >/dev/null
	jqnpm install "someuser/pack2"
	popd >/dev/null
	popd >/dev/null

	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"
	assertFalse "jq.json does not exist" "[[ -s 'local-project/one/two/jq.json' ]]"
	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/someuser/pack2/' ]]"
	assertEquals "Result" 'abcdefghi' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
