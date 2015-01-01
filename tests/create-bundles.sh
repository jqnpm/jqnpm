#!/usr/bin/env bash
set -e

# Create an upstream repository, create a clone, copy files, push, create bundle.
# Why use an upstream repository? Don't know; I forgot why.

function resolveDirectory {
	(cd -- "$1"; echo -nE "$PWD")
}

# Isn't there a better way to do this? String wise ./ and ../ squisher that doesn't re-parse directories/links?
function resolvePath {
	if [[ -d "$1" ]];
	then
		resolveDirectory "$1"
	else
		echo "$(resolveDirectory "$(dirname "$1")")/$(basename -a "$1")"
	fi
}

# TODO: re-use these TMP functions across files.
function createTempFileDirectoryIfNecessary {
	if [[ ! -d "$internalTmpDir" ]];
	then
		local base=$(basename "$BASH_SOURCE")

		internalTmpDir=$(mktemp -d "${TMPDIR:-TMP}${base}.XXXXXX")
	fi
}

function rmTempFileDirectory {
	if [[ ! -z "${internalTmpDir}" && -d "${internalTmpDir}" ]];
	then
		rm -rf "${internalTmpDir}"
	fi
}

# TODO: is this EXIT trap interfering with shunit2 testing traps?
trap 'rmTempFileDirectory' EXIT

function getTempFilePath {
	createTempFileDirectoryIfNecessary

	local tmpPath="$(mktemp "${internalTmpDir}/tmp.XXXXXX")"

	echo -nE "$tmpPath"
}
# END TMP functions.

function createBundle {
	name="$1"
	shift
	normalName="${name}-normal"

	[[ ! -d "$1" ]] && { echo "Couldn't find the source path: '${1}'" >&2; exit 1; }
	sourcePath=$(resolvePath "$1")
	shift

	[[ ! -d "$1" ]] && { echo "Couldn't find the output path: '${1}'" >&2; exit 1; }
	outputPath="$(resolvePath "$1")"
	shift

	createTempFileDirectoryIfNecessary

	pushd "$internalTmpDir" >/dev/null

		# Origin repository.
		git init --quiet --bare "$name" >/dev/null

		# Normal version of the origin repository.
		git clone --quiet "$name" "$normalName" &>/dev/null

		pushd "$normalName" >/dev/null
			cp -vrX "$sourcePath"/* .
			git add .
			git commit --quiet -m "Bundle contents"
			git push --quiet
		popd >/dev/null

		# Create a bundle from the origin repository.
		pushd "$name" >/dev/null
			git bundle create "../${name}.bundle" --all &>/dev/null
		popd >/dev/null

		cp "${name}.bundle" "$outputPath"

		rm -rf "$name" "$normalName" "${name}.bundle"

	popd >/dev/null
}

function createBundles {
	# TODO: this array handling feels hacky.
	# http://mywiki.wooledge.org/BashFAQ/020
	unset packageSourceDirectories i
	while IFS= read -r -d '' packageSourceDirectory; do
		packageSourceDirectories[i++]="$packageSourceDirectory"
	done < <(find "$PWD" -mindepth 2 -maxdepth 2 -type d -name 'package-source' -print0)

	for packageSourceDirectory in "${packageSourceDirectories[@]}"
	do
		# TODO: this array handling feels hacky.
		# http://mywiki.wooledge.org/BashFAQ/020
		unset packageDirectories i
		while IFS= read -r -d '' packageDirectory; do
			packageDirectories[i++]="$packageDirectory"
		done < <(find "$packageSourceDirectory" -mindepth 2 -maxdepth 2 -type d -print0)

		for packageDirectory in "${packageDirectories[@]}";
		do
			local name=$(basename "$packageDirectory")
			local outputDirectory=$(dirname "$(echo "$packageDirectory" | sed 's/package-source/remote-base/')")

			mkdir -p "$outputDirectory"

			createBundle "$name" "$packageDirectory" "${outputDirectory}/"
		done
	done 
}

pushd "${BASH_SOURCE%/*}" >/dev/null
createBundles
popd >/dev/null
