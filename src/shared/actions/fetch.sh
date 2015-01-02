function fetchSingle {
	(( "$#" != 1 )) && die 1 "not the right number of arguments to '$FUNCNAME'"
	IFS='@' read -ra nameAndVersion <<< "$1"
	shift

	local dependencyName="${nameAndVersion[0]}"
	local dependencySemverRange="${nameAndVersion[1]}"

	debugInPackageIfAvailable 4 "(fetching) dependency '${dependencyName}'@'${dependencySemverRange}'"

	# TODO: use a local folder per remote server, /github.com/?
	# TODO: make building remote and cache variables functions.
	local remote="${JQNPM_REMOTE_BASE:-$config_default_remoteBase}/${dependencyName}${JQNPM_REMOTE_SUFFIX:-$config_default_remoteSuffix}"
	local cache="${JQNPM_PACKAGES_CACHE:-$config_default_packagesCache}/${dependencyName}"

	if [[ ! -d "$cache" ]];
	then
		mkdir -p "$cache"
	fi

	# TODO: get list of local tags, match against it.
	# TODO: get a list of remote tags.
	# TODO: only download the best-matching tag, not the entire repository.
	# TODO: use --bare repos, bundles or maybe zip files in cache?
	# git clone --branch <tag> --single-branch --depth 1 "$remote" "$cache"
	# TODO: fail gracefully if git fails.
	debugInPackageIfAvailable 3 $(echo -E "Cloning '${remote}' to '${cache}'" | replaceHomeWithTilde)
	git clone --single-branch --depth 1 --quiet "$remote" "$cache"
}

function fetchSingleManually {
	(( "$#" != 1 )) && die 1 "not the right number of arguments to '$FUNCNAME'"
	debugInPackageIfAvailable 4 "(fetching manually) ${1}"

	fetchSingle "$1"
}

function fetchFromJqJson {
	(( "$#" != 0 )) && die 1 "not the right number of arguments to '$FUNCNAME'"
	# TODO: enable arguments controlling what is being fetched.
	# For now, assume jq.json is being used, or die.
	requiresJqJson

	# Reads jq.json, clone remote repos to ./jq/packages/username/reponame
	# This continues recursively.	

	# TODO: this array handling feels hacky.
	# http://mywiki.wooledge.org/BashFAQ/020
	unset directDependencyNames i
	while IFS= read -r -d '' dependencyName; do
		directDependencyNames[i++]="$dependencyName"
	done < <(getDirectDependencyNames)

	debugInPackage 4 "(preparing fetch) numberOfDirectDependencyNames: ${numberOfDirectDependencyNames} directDependencyNames: '${directDependencyNames[@]}'"

	hasDirectDependencies || return 0;

	for dependencyName in "${directDependencyNames[@]}";
	do
		# TODO: use the semantic version and match against remote repo git tags.
		local dependencySemverRange=$(getDirectDependencyVersion "$dependencyName")

		fetchSingle "${dependencyName}@${dependencySemverRange}"

		local cache="${JQNPM_PACKAGES_CACHE:-$config_default_packagesCache}/${dependencyName}"

		# Fetch recursively.
		pushd "$cache" >/dev/null
		"$jqnpmSourceFile" fetch
		popd >/dev/null
	done
}

function fetch {
	(( "$#" > 1 )) && die 1 "not the right number of arguments to '$FUNCNAME'"
	if [[ -z "$1" ]];
	then
		fetchFromJqJson
	else
		fetchSingleManually "$1"
	fi
}