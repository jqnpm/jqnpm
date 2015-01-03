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

function testInitGood () {
	assertFalse "jq.json doesn't exist" "[[ -s 'jq-good-local-project/jq.json' ]]"

	pushd "jq-good-local-project" >/dev/null
	jqnpm init
	popd >/dev/null

	assertTrue "jq/main.jq is generated" "[[ -s 'jq-good-local-project/jq/main.jq' ]]"
	assertTrue "jq.json is generated" "[[ -s 'jq-good-local-project/jq.json' ]]"
	assertTrue "jq.json empty dependencies" "[[ $(<"jq-good-local-project/jq.json" jq '.dependencies | length') == '0' ]]"
	assertTrue "jq.json has package name same as this folder minus jq- prefix" "[[ $(<"jq-good-local-project/jq.json" jq '.name') == '"good-local-project"' ]]"
	assertTrue "jq.json has package version" "[[ $(<"jq-good-local-project/jq.json" jq '.version') == '"0.1.0"' ]]"
	assertTrue "jq.json has jq version" "[[ $(<"jq-good-local-project/jq.json" jq '.engines["jq"]') == '"^1.5.0"' ]]"
	assertTrue "jq.json has jqnpm version" "[[ $(<"jq-good-local-project/jq.json" jq '.engines["jqnpm"]') == '"^1.0.0"' ]]"
}

function testInitGoodWithPrefix () {
	assertFalse "jq.json doesn't exist" "[[ -s 'good-local-project-without-jq-prefix/jq.json' ]]"

	pushd "good-local-project-without-jq-prefix" >/dev/null
	local result=$(jqnpm init 2>&1)
	popd >/dev/null

	assertTrue "jq.json has package name same as this folder" "[[ $(<"good-local-project-without-jq-prefix/jq.json" jq '.name') == '"good-local-project-without-jq-prefix"' ]]"
	assertTrue "Warning about no jq- prefix" "[[ \"${result}\" =~ not.*'jq-' ]]"
}

function singleJqInitWithBadFolderName () {
	local dirname="$1"

	assertFalse "jq.json doesn't exist" "[[ -s '${dirname}/jq.json' ]]"

	pushd "$dirname" >/dev/null
	jqnpm init &>/dev/null
	local result="$?"
	popd >/dev/null

	assertFalse "jq.json doesn't exist" "[[ -s '${dirname}/jq.json' ]]"
	assertEquals "Result" '200' "$result"
}

function testAllJqInitWithBadFolderName () {
	while IFS= read -r -d '' dirpath;
	do
		dirname=$(basename -a "$dirpath")
		echo "Subdirectory: '${dirname}'"

		singleJqInitWithBadFolderName "$dirname"
	done < <(find "$PWD" -mindepth 1 -maxdepth 1 -type d -not -name '*good*' -print0)
}


source "${BASH_SOURCE%/*}/../test-runner.sh"
