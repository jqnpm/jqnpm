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

function testExecute () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	jqnpm install
	local result=$(jqnpm execute --null-input --raw-output)
	popd >/dev/null

	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/.jq/packages/someuser/pack4/' ]]"
	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/someuser/pack2/' ]]"
	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/someuser/pack2/.jq/packages/anotheruser/pack3/' ]]"
	assertEquals "Result" 'abc123def456ghi789' "$result"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
