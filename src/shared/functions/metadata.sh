function hasPackageMetadataFile {
	if [[ -s "$packageMetadataFilename" ]];
	then
		return 0;
	fi

	return 1;
}

function getPackageMainJqPath {
	if hasPackageMetadataFile;
	then
		local mainPathFromJqJson=$(getPackageMainPath)
		local mainPath="${mainPathFromJqJson:-$defaultPackageJqFile}"

		echo -nE "$mainPath"
	else
		echo -nE "$defaultPackageJqFile"
	fi
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
	local mainPath="$1"

	if simplePathIsInsidePackageCheck "$mainPath" && [[ "${mainPath:(-3)}" == ".jq" ]];
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
	local mainPath="$(getPackageMainJqPath)"

	if packageMainJqPathIsValid "$mainPath" && packageMainJqPathExists "$mainPath";
	then
		return 0;
	fi

	return 1;
}

function getValidPackageMainJq {
	if ! hasValidPackageMainJq;
	then
		die 200 "package did not have a valid main .jq file in the package."
	fi

	local mainPath="$(getPackageMainJqPath)"

	echo "$mainPath"
}

function requiresJqJson {
	hasPackageMetadataFile || die 1 "missing '${packageMetadataFilename}'."
}

function replaceHomeWithTilde {
	local fixedHome="${HOME//|/\|}"

	sed "s|$fixedHome|~|g"
}

function currentMetadata {
	cat "$packageMetadataFilename"
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

function getDirectDependencyNames {
	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output 'def delim: [ 00 ] | implode; (if .dependencies then (.dependencies | keys | (join(delim) + delim)) else empty end)'
}

function getPackageName {
	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output '.name'
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
	# TODO: encode output with '@sh'?
	local packageName=$(getPackageName)

	if ! isPackageNameValid "$packageName";
	then
		die 200 "package name was not valid."
	fi

	echo -nE "$packageName"
}

function getValidPackageNameOrEmptyString {
	# TODO: encode output with '@sh'?
	local packageName=$(getPackageName)

	if ! isPackageNameValid "$packageName";
	then
		echo -n ""
	fi

	echo -nE "$packageName"
}

function getPackageMainPath {
	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output '.main // ""'
}

function getDirectDependencyVersion {
	(( "$#" < 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local dependencyName="$1"
	shift

	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output --arg dependencyName "$dependencyName" '.dependencies[$dependencyName]'
}

function hasDirectDependencies {
	# TODO: this array handling feels hacky.
	# http://mywiki.wooledge.org/BashFAQ/020
	unset directDependencyNames i
	while IFS= read -r -d '' dependencyName; do
		directDependencyNames[i++]="$dependencyName"
	done < <(getDirectDependencyNames)

	[[ -z "$directDependencyNames" ]] && return 1;

	local numberOfDirectDependencyNames="${#directDependencyNames[@]}"
	(( numberOfDirectDependencyNames == 0 )) && return 1;

	return 0;
}

# TODO: use "real" versions for jq and jqnpm.
read -d '' defaultMinmalJqJson <<-'EOF' || true
{
    "name": "TO BE REPLACED",
    "version": "0.1.0",
    "main": "./src/main.jq",
    "dependencies": {},
    "engines": {
        "jq": "^1.5.0",
        "jqnpm": "^1.0.0"
    }
}
EOF

function createMinimalJqJsonWithPackageName {
	local packageName="$1"

	if ! isPackageNameValid "$packageName";
	then
		die 200 "could not create minimal jq.json file due to malformed package name. The package name is based on the name of the current folder, by default. Because packages are (usually) made public, naming is important. Start the folder name with 'jq-' (recommended) and use only lowercase a-z, 0-9 and dashes: 'jq-good-name'. The 'jq-' part will be stripped in the package name, as it is already known to 'jq.json' that it is a jq package."
	fi

	if packageNameStartsWithLowercaseJqDash "$packageName";
	then
		packageName="${packageName:3}"
		debugInPackageIfAvailable 3 "folder (package) name prefix 'jq-' removed for the package name: '${packageName}'"
	else
		debugInPackageIfAvailable 2 "folder (package) name does not start with 'jq-': '${packageName}'"
	fi

	[[ -z "$packageName" ]] && die 200 "could not create minimal jq.json file due to an empty package name."

	packageNameMeetsLengthRequirement "$packageName" || debugInPackageIfAvailable 2 "package name length is shorter than ${minimumRecommendedPackageNameLength}: '${packageName}'"

	echo -nE "$defaultMinmalJqJson" | jq --arg "packageName" "$packageName" '.name=$packageName' > "$packageMetadataFilename"
}

function createMinimalJqJsonIfNecessary {
	if ! hasPackageMetadataFile;
	then
		local packageName=$(basename "$PWD")

		createMinimalJqJsonWithPackageName "$packageName"
	fi
}

function createMinmalMainJqIfNecessary {
	if ! hasValidPackageMainJq;
	then
		mkdir -p "$(dirname "$defaultPackageJqFile")"
		echo -E "# Write your jq code here!" >"$defaultPackageJqFile"
	fi
}

read -d '' addOrUpdateDependencyInJqJson <<-'EOF' || true
if (.dependencies | not)
then
	.dependencies = {}
else
	.
end
| .dependencies[$depName] = $depSemverRange
EOF

function addOrUpdateDependencyAndRangePairInJqJson {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local dependencyName="$1"
	shift
	local dependencySemverRange="$1"
	shift
	local tmpFilePath=$(getTempFilePath)

	createMinimalJqJsonIfNecessary

	<"$packageMetadataFilename" jq --arg depName "$dependencyName" --arg depSemverRange "$dependencySemverRange" "$addOrUpdateDependencyInJqJson" >"$tmpFilePath"
	cp "$tmpFilePath" "$packageMetadataFilename"
	rm "$tmpFilePath"
}

function addOrUpdateDependencyAndRangeInJqJson {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	IFS='@' read -ra nameAndVersion <<< "$1"
	shift

	local dependencyName="${nameAndVersion[0]}"
	local dependencySemverRange="${nameAndVersion[1]}"

	debugInPackageIfAvailable 4 "(adding/updating in jq.json) dependency '${dependencyName}'@'${dependencySemverRange}'"

	addOrUpdateDependencyAndRangePairInJqJson "$dependencyName" "$dependencySemverRange"
}
