function requiresJqJson {
	hasPackageMetadataFile || die 1 "missing '${packageMetadataFilename}'."
}

function packageNameStartsWithLowercaseJqDash {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local packageName="$1"

	if [[ "$packageName" =~ ^jq- ]];
	then
		return 0
	fi

	return 1;
}

minimumRecommendedPackageNameLength=3
function packageNameMeetsLengthRequirement {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local packageName="$1"
	if (( "${#packageName}" >= minimumRecommendedPackageNameLength ));
	then
		return 0;
	fi

	return 1;
}

function isPackageNameValid {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local packageName="$1"

	# Only allows lowercase.
	if ! containsUppercaseAscii "$packageName" && [[ "$packageName" =~ ^[a-z][a-z0-9-]+$ ]] && ! [[ "$packageName" =~ -- ]];
	then
		return 0;
	fi

	return 1;
}

function hasValidPackageName {
	local packageName=$(getPackageName)

	if isPackageNameValid "$packageName";
	then
		return 0;
	fi

	return 1;
}

function getValidPackageName {
	local packageName=$(getPackageName)

	if ! isPackageNameValid "$packageName";
	then
		die 200 "package name was not valid."
	fi

	echo -nE "$packageName"
}

function getValidPackageNameOrEmptyString {
	local packageName=$(getPackageName)

	if ! isPackageNameValid "$packageName";
	then
		echo -n ""
	fi

	echo -nE "$packageName"
}

function simplePathIsInsidePackageCheck {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local path="$1"

	if [[ "$path" =~ \.\. ]] || [[ "$path" =~ // ]] || [[ "$path" =~ ^/ ]];
	then
		return 1;
	fi

	return 0;
}

function packageMainJqPathIsValid {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local relativeMainPath="$1"

	if simplePathIsInsidePackageCheck "$relativeMainPath" && [[ "${relativeMainPath:(-3)}" == ".jq" ]];
	then
		return 0;
	fi

	return 1;
}

function packageMainJqPathExists {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local mainPath="$1"

	if [[ -s "$mainPath" ]];
	then
		return 0;
	fi

	return 1;
}

function hasValidPackageMainJq {
	local relativeMainPath="$(getRelativePackageMainJqPath)"
	local absoluteMainPath="$(getAbsolutePackageMainJqPath)"

	if packageMainJqPathIsValid "$relativeMainPath" && packageMainJqPathExists "$absoluteMainPath";
	then
		return 0;
	fi

	return 1;
}
