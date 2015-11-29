function createTempFileDirectoryIfNecessary {
	if [[ ! -d "$internalTmpDir" ]];
	then
		local base=$(basename "$JQNPM_SOURCE")

		echo -nE $(mktemp -d "${base}.XXXXXX")
	fi
}

declare -g internalTmpDir=$(createTempFileDirectoryIfNecessary)

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

function getAdressableTempFilePath {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	# TODO: validate path format.
	local adress="$1"

	createTempFileDirectoryIfNecessary

	local tmpPath="${internalTmpDir}/tmp.${adress}"

	echo -nE "$tmpPath"
}

