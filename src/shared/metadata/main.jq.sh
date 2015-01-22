function getBestNewMainJqPath {
	if isInsidePackageWithRoot;
	then
		local localPackageRoot=$(getLocalPackageRoot)

		echo -nE "${localPackageRoot}/${defaultPackageJqFile}"

		return 0;
	fi

	echo -nE "$defaultPackageJqFile"

	return 0;
}

function createMinimalMainJqIfNecessary {
	if ! hasValidPackageMainJq;
	then
		local bestNewMainJqPath=$(getBestNewMainJqPath)

		mkdir -p "$(dirname "$bestNewMainJqPath")"
		echo -E "# Write your jq code here!" >"$bestNewMainJqPath"
	fi
}

function getRelativePackageMainJqPath {
	if hasPackageMetadataFile;
	then
		local packageMainPathFromJqJson=$(getPackageMainPathFromJqJson)

		if [[ -z "$packageMainPathFromJqJson" ]];
		then
			echo -nE "${defaultPackageJqFile}"

			return 0;
		fi

		echo -nE "${packageMainPathFromJqJson}"

		return 0;
	fi

	echo -nE "${defaultPackageJqFile}"
}

function getAbsolutePackageMainJqPath {
	local bestEffectivePackageRoot=$(getBestEffectivePackageRoot)

	if hasPackageMetadataFile;
	then
		local packageMainPathFromJqJson=$(getRelativePackageMainJqPath)

		echo -nE "${bestEffectivePackageRoot}/${packageMainPathFromJqJson}"

		return 0;
	fi

	echo -nE "${bestEffectivePackageRoot}/${defaultPackageJqFile}"
}

function getValidPackageMainJq {
	if ! hasValidPackageMainJq;
	then
		die 200 "package did not have a valid main .jq file in the package."
	fi

	local absoluteMainPath="$(getAbsolutePackageMainJqPath)"

	debug 5 "found valid main path: '${absoluteMainPath}'"

	echo -nE "$absoluteMainPath"
}
