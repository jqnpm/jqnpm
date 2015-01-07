function getLocalPackageRoot {
	# Here 'local' means not in $HOME.

	local originalPWD="$PWD"

	(
		until [[ -d "$packageMetadataDirectoryName" ]];
		do
			cd ..

			if [[ "$PWD" == "/" || "$PWD" == "$HOME" ]];
			then
				debug 5 "could not find nearest 'local' package root starting in '$(echo -nE "$originalPWD" | replaceHomeWithTilde)'"

				return 1;
			fi
		done

		debug 5 "found nearest 'local' package root '$(echo -nE "$PWD" | replaceHomeWithTilde)' starting in '$(echo -nE "$originalPWD" | replaceHomeWithTilde)'"

		echo -nE "${PWD}"
	)

	return 0;
}

function isInsidePackageWithRoot {
	if [[ ! -z $(getLocalPackageRoot 2>/dev/null) ]];
	then
		return 0;
	fi

	return 1;
}

function getNearestJqJsonDirectory {
	local originalPWD="$PWD"

	(
		until [[ -s "$packageMetadataFilename" ]];
		do
			if [[ "$PWD" == "/" ]];
			then
				debug 5 "could not find nearest 'jq.json' starting in '$(echo -nE "$originalPWD" | replaceHomeWithTilde)'"

				return 1;
			fi

			cd ..
		done

		debug 7 "found nearest directory with 'jq.json' '$(echo -nE "$PWD" | replaceHomeWithTilde)' starting in '$(echo -nE "$originalPWD" | replaceHomeWithTilde)'"

		echo -nE "$PWD"
	)

	return 0;
}

function getNearestJqJson {
	local nearestJqJsonDirectory=$(getNearestJqJsonDirectory 2>/dev/null)

	if [[ ! -z "$nearestJqJsonDirectory" ]];
	then
		local nearestJqJson="${nearestJqJsonDirectory}/${packageMetadataFilename}"

		debug 6 "found nearest 'jq.json' '$(echo -nE "$nearestJqJson" | replaceHomeWithTilde)' starting in '$(echo -nE "$PWD" | replaceHomeWithTilde)'"

		echo -nE "$nearestJqJson"

		return 0;
	fi

	return 1;
}

function hasPackageMetadataFile {
	if [[ -z $(getNearestJqJson 2>/dev/null) ]];
	then
		return 1;
	fi

	return 0;
}

function getBestEffectivePackageRoot {
	if isInsidePackageWithRoot;
	then
		getLocalPackageRoot

		return 0;
	fi

	if hasPackageMetadataFile;
	then
		getNearestJqJsonDirectory

		return 0;
	fi

	echo -nE "$PWD"

	return 0;
}

function getBestNewDotJqDirectoryPath {
	if isInsidePackageWithRoot;
	then
		die 300 "can't create a new '$packageMetadataDirectoryName' inside an existing package."
	fi

	if hasPackageMetadataFile;
	then
		local nearestJqJsonDirectory=$(getNearestJqJsonDirectory)

		echo -nE "${nearestJqJsonDirectory}/${packageMetadataDirectoryName}"

		return 0;
	fi

	echo -nE "$packageMetadataDirectoryName"

	return 0;
}

function getBestNewJqJsonPath {
	if isInsidePackageWithRoot;
	then
		local localPackageRoot=$(getLocalPackageRoot)

		echo -nE "${localPackageRoot}/${packageMetadataFilename}"

		return 0;
	fi

	echo -nE "$packageMetadataFilename"

	return 0;
}

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

function getValidPackageMainJq {
	if ! hasValidPackageMainJq;
	then
		die 200 "package did not have a valid main .jq file in the package."
	fi

	local absoluteMainPath="$(getAbsolutePackageMainJqPath)"

	debug 5 "found valid main path: '${absoluteMainPath}'"

	echo -nE "$absoluteMainPath"
}

function requiresJqJson {
	hasPackageMetadataFile || die 1 "missing '${packageMetadataFilename}'."
}

function replaceHomeWithTilde {
	local fixedHome="${HOME//|/\|}"

	sed "s|$fixedHome|~|g"
}

function currentMetadata {
	cat "$(getNearestJqJson)"
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
	currentMetadata | jq --join-output '.name // ""'
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

function getPackageMainPathFromJqJson {
	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output '.main // ""'
}

function getDirectDependencyVersion {
	(( "$#" < 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local dependencyName="$1"
	shift

	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output --arg dependencyName "$dependencyName" '.dependencies[$dependencyName] // ""'
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

function createPackageRootIfNecessary {
	if ! isInsidePackageWithRoot;
	then
		local bestNewDotJqDirectoryPath=$(getBestNewDotJqDirectoryPath)

		debug 5 "creating package root in: '${bestNewDotJqDirectoryPath}' in '$PWD'"

		mkdir -p "$bestNewDotJqDirectoryPath"
	fi
}

# TODO: use "real" versions for jq and jqnpm.
read -d '' defaultMinmalJqJson <<-'EOF' || true
{
    "name": "TO BE REPLACED",
    "version": "0.1.0",
    "main": "./jq/main.jq",
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

	local bestNewJqJsonPath=$(getBestNewJqJsonPath)

	debugInPackageIfAvailable 4 "creating new '${packageMetadataFilename}': '${bestNewJqJsonPath}'"

	echo -nE "$defaultMinmalJqJson" | jq --arg "packageName" "$packageName" '.name=$packageName' > "$bestNewJqJsonPath"
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
		local bestNewMainJqPath=$(getBestNewMainJqPath)

		mkdir -p "$(dirname "$bestNewMainJqPath")"
		echo -E "# Write your jq code here!" >"$bestNewMainJqPath"
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

	local packageMetadataFilePath=$(getNearestJqJson)

	debugInPackageIfAvailable 4 "(adding/updating in jq.json) dependency '${dependencyName}'@'${dependencySemverRange}' added to '$packageMetadataFilePath'"

	<"$packageMetadataFilePath" jq --arg depName "$dependencyName" --arg depSemverRange "$dependencySemverRange" "$addOrUpdateDependencyInJqJson" >"$tmpFilePath"
	cp "$tmpFilePath" "$packageMetadataFilePath"
	rm "$tmpFilePath"
}

function addOrUpdateDependencyAndRangeInJqJson {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	IFS='@' read -ra nameAndVersion <<< "$1"
	shift

	local dependencyName="${nameAndVersion[0]}"
	local dependencySemverRange="${nameAndVersion[1]}"

	debugInPackageIfAvailable 3 "(adding/updating in jq.json) dependency '${dependencyName}'@'${dependencySemverRange}'"

	addOrUpdateDependencyAndRangePairInJqJson "$dependencyName" "$dependencySemverRange"
}
