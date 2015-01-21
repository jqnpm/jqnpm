function installSingle {
	(( "$#" != 1 && "$#" != 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"

	local installGlobal="false"
	if (( "$#" == "1" )) && [[ "$1" == "--global" || "$1" == "-g" ]];
	then
		die 100 "cannot install local project globally"
	elif (( "$#" == "2" ));
	then
		if [[ "$1" == "--global" || "$1" == "-g" ]];
		then
			installGlobal="true"
			shift
		else
			die 100 "unknown combination of arguments '$@' in '$FUNCNAME'"
		fi
	fi

	IFS='@' read -ra nameAndVersion <<< "$1"
	shift

	local dependencyName="${nameAndVersion[0]}"
	local dependencySemverRange="${nameAndVersion[1]}"

	if [[ "$installGlobal" == "true" ]];
	then
		debugInPackageIfAvailable 5 "(installing single) '${dependencyName}@${dependencySemverRange}' globally"
	else
		debugInPackageIfAvailable 5 "(installing single) '${dependencyName}@${dependencySemverRange}' starting in path: $(echo -nE "$PWD" | replaceHomeWithTilde)"
	fi

	# Make sure the remote repository is in the local cache.
	# TODO: implement --no-fetch.
	"$jqnpmSourceFile" fetch "${dependencyName}@${dependencySemverRange}"

	debugInPackageIfAvailable 4 "(installing) dependency '${dependencyName}'@'${dependencySemverRange}'"

	local cache="${JQNPM_PACKAGES_CACHE:-$config_default_packagesCache}/${dependencyName}"

	local installTarget

	if [[ "$installGlobal" == "true" ]];
	then
		local globalDependencyPath="${globalJqPackageBase}/${dependencyName}"
		installTarget="$globalDependencyPath"
	else
		createPackageRootIfNecessary

		local packageRoot=$(getLocalPackageRoot)
		local localDependencyPath="${packageRoot}/${localJqPackageBase}/${dependencyName}"
		installTarget="$localDependencyPath"
	fi

	debugInPackageIfAvailable 5 "(installing single) '${dependencyName}@${dependencySemverRange}' target: $(echo -nE "$installTarget" | replaceHomeWithTilde)"

	[[ -d "$installTarget" ]] && rm -r "$installTarget"
	mkdir -p "$installTarget"

	# Use `git archive` to copy git content instead of the repository.
	pushd "$cache" >/dev/null
	# TODO: use the right tag.
	git archive HEAD | tar x -C "$installTarget"
	popd >/dev/null

	# Make this installed package an unambiguous package root of its own.
	mkdir -p "${installTarget}/${packageMetadataDirectoryName}"

	# Install recursively.
	pushd "$installTarget" >/dev/null
	"$jqnpmSourceFile" install
	popd >/dev/null
}

function installSingleManually {
	(( "$#" != 1 && "$#" != 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	debugInPackageIfAvailable 4 "(installing manually) '${1}' starting in path: $(echo -nE "$PWD" | replaceHomeWithTilde)"

	installSingle "$@"

	if [[ "$1" != "--global" && "$1" != "-g" ]];
	then
		# TODO: if semver range is empty, extract most recent dependency version, use it as the single '=1.2.3' range when saving.
		addOrUpdateDependencyAndRangeInJqJson "$1"
	fi
}

function installFromJqJson {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	requiresJqJson

	debugInPackageIfAvailable 5 "(attempting install from jq.json) starting in path: $(echo -nE "$PWD" | replaceHomeWithTilde)"

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

	debugInPackageIfAvailable 4 "(preparing install) directDependencyNames: '${directDependencyNames[@]}'"

	hasDirectDependencies || return 0;

	for dependencyName in "${directDependencyNames[@]}";
	do
		# TODO: use the semantic version and match against remote repo git tags.
		local dependencySemverRange=$(getDirectDependencyVersion "$dependencyName")

		installSingle "${dependencyName}@${dependencySemverRange}"
	done
}

function install {
	(( "$#" > 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"

	if (( "$#" == 0 ));
	then
		installFromJqJson
	else
		installSingleManually "$@"
	fi
}
