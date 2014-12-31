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
	git clean -fdX . >/dev/null
}

function tearDown () {
	cleanup
}

function testFetchFromJqJson () {
	assertFalse "Cache is empty" "[[ -d 'package-cache/anotheruser/pack1/' ]]"
	assertFalse "Package is not installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertTrue "jq.json has package version range" "[[ $(<"local-project/jq.json" jq '.dependencies["anotheruser/pack1"]') == '"^1.0.0"' ]]"

	pushd "local-project" >/dev/null
	jqnpm fetch anotheruser/pack1
	popd >/dev/null

	assertTrue "jq.json has package version range" "[[ $(<"local-project/jq.json" jq '.dependencies["anotheruser/pack1"]') == '"^1.0.0"' ]]"
	assertFalse "Package is not installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertTrue "Cache is loaded" "[[ -d 'package-cache/anotheruser/pack1/' ]]"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
