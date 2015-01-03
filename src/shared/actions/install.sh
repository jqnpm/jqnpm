function installSingle {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	IFS='@' read -ra nameAndVersion <<< "$1"
	shift

	local dependencyName="${nameAndVersion[0]}"
	local dependencySemverRange="${nameAndVersion[1]}"

	# Make sure the remote repository is in the local cache.
	# TODO: implement --no-fetch.
	"$jqnpmSourceFile" fetch "${dependencyName}@${dependencySemverRange}"

	debugInPackageIfAvailable 4 "(installing) dependency '${dependencyName}'@'${dependencySemverRange}'"

	local cache="${JQNPM_PACKAGES_CACHE:-$config_default_packagesCache}/${dependencyName}"
	local localDependencyPath="${PWD}/${localJqPackageBase}/${dependencyName}"

	mkdir -p "$localDependencyPath"

	# Use `git archive` to copy git content instead of the repository.
	pushd "$cache" >/dev/null
	# TODO: use the right tag.
	git archive HEAD | tar x -C "$localDependencyPath"
	popd >/dev/null
}

function installSingleManually {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	debugInPackageIfAvailable 4 "(installing manually) ${1}"

	installSingle "$1"

	# TODO: if semver range is empty, extract most recent dependency version, use it as the single '=1.2.3' range when saving.
	addOrUpdateDependencyAndRangeInJqJson "$1"
}

function installFromJqJson {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	requiresJqJson

	# Reads jq.json, puts files in ./jq/packages/
	# ./jq/packages/$dependencyName/
	# ./jq/packages/$dependencyName/jq/main.jq (and any other files in the package)
	# Then reads ./jq/packages/$dependencyName/jq.json, and installs $subdependencies.
	# ./jq/packages/$dependencyName/.jq/packages/$subdependency/
	# This continues recursively.	
	# TODO: build a dependency graph to detect circular dependencies.

	# TODO: this array handling feels hacky.
	# http://mywiki.wooledge.org/BashFAQ/020
	unset directDependencyNames i
	while IFS= read -r -d '' dependencyName; do
		directDependencyNames[i++]="$dependencyName"
	done < <(getDirectDependencyNames)

	debugInPackage 4 "(preparing install) numberOfDirectDependencyNames: ${numberOfDirectDependencyNames} directDependencyNames: '${directDependencyNames[@]}'"

	hasDirectDependencies || return 0;

	for dependencyName in "${directDependencyNames[@]}";
	do
		# TODO: use the semantic version and match against remote repo git tags.
		local dependencySemverRange=$(getDirectDependencyVersion "$dependencyName")

		installSingle "${dependencyName}@${dependencySemverRange}"

		local localDependencyPath="${PWD}/${localJqPackageBase}/${dependencyName}"

		# Install recursively.
		pushd "$localDependencyPath" >/dev/null
		"$jqnpmSourceFile" install
		popd >/dev/null
	done
}

function install {
	(( "$#" > 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	if [[ -z "$1" ]];
	then
		installFromJqJson
	else
		installSingleManually "$1"
	fi
}
