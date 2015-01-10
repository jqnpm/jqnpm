function fetchSingle {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	IFS='@' read -ra nameAndVersion <<< "$1"
	shift

	local dependencyName="${nameAndVersion[0]}"
	local dependencySemverRange="${nameAndVersion[1]}"

	debugInPackageIfAvailable 4 "(fetching single) dependency '${dependencyName}'@'${dependencySemverRange}' starting in path: $(echo -nE "$PWD" | replaceHomeWithTilde)"

	# TODO: use a local folder per remote server, /github.com/?
	# TODO: make building remote and cache variables functions.
	local remote="${JQNPM_REMOTE_BASE:-$config_default_remoteBase}/${dependencyName}${JQNPM_REMOTE_SUFFIX:-$config_default_remoteSuffix}"
	local cache="${JQNPM_PACKAGES_CACHE:-$config_default_packagesCache}/${dependencyName}"

	# TODO: get list of local tags, match against it.
	# TODO: get a list of remote tags.
	# TODO: only download the best-matching tag, not the entire repository.
	# TODO: use --bare repos, bundles or maybe zip files in cache?
	# git clone --branch <tag> --single-branch --depth 1 "$remote" "$cache"
	# TODO: fail gracefully if git fails.
	if [[ ! -d "$cache" ]];
	then
		mkdir -p "$cache"

		debugInPackageIfAvailable 3 "Cloning repository '$(echo -nE "$remote" | replaceHomeWithTilde)' to '$(echo -nE "$cache" | replaceHomeWithTilde)'"

		# Fetch new repository
		git clone --single-branch --depth 1 --quiet "$remote" "$cache"
	else
		pushd "$cache" >/dev/null
		debugInPackageIfAvailable 3 "Fetching new commits '$(echo -nE "$remote" | replaceHomeWithTilde)' to '$(echo -nE "$cache" | replaceHomeWithTilde)'"

		# Update existing repository
		git reset --hard &>/dev/null
		git checkout master &>/dev/null
		git reset --hard master &>/dev/null
		git pull --rebase --quiet &>/dev/null
		git reset --hard master &>/dev/null
		popd >/dev/null
	fi

	# Fetch recursively.
	pushd "$cache" >/dev/null
	"$jqnpmSourceFile" fetch
	popd >/dev/null
}

function fetchSingleManually {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	debugInPackageIfAvailable 4 "(fetching manually) '${1}' starting in path: $(echo -nE "$PWD" | replaceHomeWithTilde)"

	fetchSingle "$1"
}

function fetchFromJqJson {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	# TODO: enable arguments controlling what is being fetched.
	# For now, assume jq.json is being used, or die.
	requiresJqJson

	debugInPackageIfAvailable 5 "(attempting fetch from jq.json) starting in path: $(echo -nE "$PWD" | replaceHomeWithTilde)"

	# Reads jq.json, clone remote repos to ./jq/packages/username/reponame
	# This continues recursively.	

	# TODO: this array handling feels hacky.
	# http://mywiki.wooledge.org/BashFAQ/020
	unset directDependencyNames i
	while IFS= read -r -d '' dependencyName; do
		directDependencyNames[i++]="$dependencyName"
	done < <(getDirectDependencyNames)

	debugInPackageIfAvailable 4 "(preparing fetch) directDependencyNames: '${directDependencyNames[@]}'"

	hasDirectDependencies || return 0;

	for dependencyName in "${directDependencyNames[@]}";
	do
		# TODO: use the semantic version and match against remote repo git tags.
		local dependencySemverRange=$(getDirectDependencyVersion "$dependencyName")

		fetchSingle "${dependencyName}@${dependencySemverRange}"
	done
}

function fetch {
	(( "$#" > 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	if [[ -z "$1" ]];
	then
		fetchFromJqJson
	else
		fetchSingleManually "$1"
	fi
}
