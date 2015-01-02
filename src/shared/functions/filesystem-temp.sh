function createTempFileDirectoryIfNecessary {
	if [[ ! -d "$internalTmpDir" ]];
	then
		local base=$(basename "$jqnpmSourceFile")

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
