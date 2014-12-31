#!/usr/bin/env bash

function resolveDirectory {
	(cd -- "$1"; echo -nE "$PWD")
}

# Isn't there a better way to do this? String wise ./ and ../ squisher that doesn't re-parse directories/links?
function resolvePath {
	if [[ -d "$1" ]];
	then
		resolveDirectory "$1"
	else
		resolveDirectory "$(dirname "$1")/$(basename -a "$1")"
	fi
}

function addJqnpmDirectoryToPath {
	# Make sure we're running the right `jqnpm`.
	# TODO: might need to preprend ${BASH_SOURCE%/*}/ with $PWD/ to get the absolute path?
	local jqnpmDirectory=$(resolveDirectory "${BASH_SOURCE%/*}/../src")

	export PATH="$jqnpmDirectory:$PATH"
}

addJqnpmDirectoryToPath
