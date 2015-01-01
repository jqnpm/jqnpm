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

function testInit () {
	assertFalse "jq.json doesn't exist" "[[ -s 'local-project/jq.json' ]]"

	pushd "local-project" >/dev/null
	jqnpm init
	popd >/dev/null

	assertTrue "src/main.jq is generated" "[[ -s 'local-project/src/main.jq' ]]"
	assertTrue "jq.json is generated" "[[ -s 'local-project/jq.json' ]]"
	assertTrue "jq.json empty dependencies" "[[ $(<"local-project/jq.json" jq '.dependencies | length') == '0' ]]"
	assertTrue "jq.json has package name same as this folder" "[[ $(<"local-project/jq.json" jq '.name') == '"local-project"' ]]"
	assertTrue "jq.json has package version" "[[ $(<"local-project/jq.json" jq '.version') == '"0.1.0"' ]]"
	assertTrue "jq.json has jq version" "[[ $(<"local-project/jq.json" jq '.engines["jq"]') == '"^1.5.0"' ]]"
	assertTrue "jq.json has jqnpm version" "[[ $(<"local-project/jq.json" jq '.engines["jqnpm"]') == '"^1.0.0"' ]]"
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
