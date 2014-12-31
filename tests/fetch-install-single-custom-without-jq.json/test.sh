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

function testFetchManually () {
	assertFalse "Cache is empty" "[[ -d 'package-cache/anotheruser/pack1/' ]]"
	assertFalse "Package is not installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	jqnpm fetch anotheruser/pack1
	popd >/dev/null

	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"
	assertFalse "Package is not installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertTrue "Cache is loaded" "[[ -d 'package-cache/anotheruser/pack1/' ]]"
}

function testInstallManually () {
	assertFalse "Cache is empty" "[[ -d 'package-cache/anotheruser/pack1/' ]]"
	assertFalse "Package is not installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	jqnpm install anotheruser/pack1
	popd >/dev/null

	assertTrue "jq.json is generated" "[[ -s 'local-project/jq.json' ]]"
	assertTrue "jq.json has package without version" "[[ $(<"local-project/jq.json" jq '.dependencies["anotheruser/pack1"]') == '""' ]]"
	assertTrue "Package is installed" "[[ -d 'local-project/.jq/packages/anotheruser/pack1/' ]]"
	assertTrue "Cache is loaded" "[[ -d 'package-cache/anotheruser/pack1/' ]]"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
