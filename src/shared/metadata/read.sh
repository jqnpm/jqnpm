function currentMetadata {
	cat "$(getNearestJqJson)"
}

function getDirectDependencyNames {
	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output 'def delim: [ 00 ] | implode; (if .dependencies then (.dependencies | keys | (join(delim) + delim)) else empty end)'
}

function getPackageName {
	# TODO: encode output with '@sh'?
	currentMetadata | jq --join-output '.name // ""'
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
