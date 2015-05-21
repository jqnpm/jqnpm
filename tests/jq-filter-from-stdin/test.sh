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
	git clean -fdX "package-cache/" "local-project/" >/dev/null
}

function tearDown () {
	cleanup
}

function testJqExecution () {
	assertTrue "jq.json exists" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	if jqnpm install;
	then
		local result=$(echo 'import "anotheruser/pack1" as pack1; ["seems", "to", pack1::f, "work"] | join(" ")' | "$jqCommandUnderTest" --null-input --from-file /dev/stdin)
	fi
	popd >/dev/null

	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertEquals "Result" '"seems to abc work"' "$result"
}

source "${BASH_SOURCE%/*}/../test-runner.sh"
