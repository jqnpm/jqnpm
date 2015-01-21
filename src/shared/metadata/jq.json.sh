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
		debugInPackageIfAvailable 3 "folder (package) name does not start with 'jq-': '${packageName}'"
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

