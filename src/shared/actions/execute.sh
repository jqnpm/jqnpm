# TODO: remove execute capabilities once jq is up to speed with the package import algorithm.
# One should not have to use `jqnpm execute` when `jq` is enough.
# https://github.com/joelpurra/jqnpm/blob/master/CONTRIBUTE.md#requirements-for-the-jq-binary
function execute {
	if hasPackageMetadataFile && isDebugAtLevel 4;
	then
		# TODO: this array handling feels hacky.
		# http://mywiki.wooledge.org/BashFAQ/020
		unset directDependencyNames i
		while IFS= read -r -d '' dependencyName; do
			directDependencyNames[i++]="$dependencyName"
		done < <(getDirectDependencyNames)

		local numberOfDirectDependencyNames="${#directDependencyNames[@]}"

		debugInPackageIfAvailable 4 "(preparing execute) numberOfDirectDependencyNames: ${numberOfDirectDependencyNames} directDependencyNames: '${directDependencyNames[@]}'"
	fi

	if hasValidPackageMainJq;
	then
		local mainPath=$(getValidPackageMainJq)

		debugInPackageIfAvailable 3 "(preparing execute) found the main jq file: '${mainPath}'"
	else
		debugInPackageIfAvailable 4 "(preparing execute) found no main jq file"
	fi

	if hasPackageMetadataFile && hasDirectDependencies;
	then
		if hasValidPackageMainJq;
		then
			# TODO: don't *completely* redefine the orginal library path?
			# The default contains useful, and therefore possibly widespread, defaults.
			# The defaults are also system-dependent.

			# Take care when editing the follow line, so debugging information and actual command stay in sync.
			debugInPackageIfAvailable 5 "(executing jq)" jq -L "$localJqPackageBase" -f "$mainPath" "$@"
			jq -L "$localJqPackageBase" -f "$mainPath" "$@"
		else
			# Take care when editing the follow line, so debugging information and actual command stay in sync.
			debugInPackageIfAvailable 5 "(executing jq)" jq -L "$localJqPackageBase" "$@"
			jq -L "$localJqPackageBase" "$@"
		fi
	else
		if hasValidPackageMainJq;
		then
			# Take care when editing the follow line, so debugging information and actual command stay in sync.
			debugInPackageIfAvailable 5 "(executing jq)" jq -f "$mainPath" "$@"
			jq -f "$mainPath" "$@"
		else
			# Take care when editing the follow line, so debugging information and actual command stay in sync.
			debugInPackageIfAvailable 5 "(executing jq)" jq "$@"
			jq "$@"
		fi
	fi
}
