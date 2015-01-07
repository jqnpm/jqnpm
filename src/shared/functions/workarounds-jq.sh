function getJqMainPathWorkaroundTarget {
	# TODO DEBUG REMOVE: work around limitations in jq's `import` resolving algorithm.
	# Current jq assumes the main package path for package P is `P/basename(P).jq`.
	if hasValidPackageMainJq;
	then
		local originalMainPath=$(getValidPackageMainJq)
		local bestEffectivePackageRoot=$(getBestEffectivePackageRoot)
		local dirname=$(basename "$bestEffectivePackageRoot")
		local jqMainFileName="${dirname}.jq"
		local jqMainFilePath="${bestEffectivePackageRoot}/${dirname}.jq"

		echo -nE "$jqMainFilePath"

		return 0;
	fi

	die 300 "(jq workaround: main script) could not find a main jq file to apply the workaround"
}

function jqMainPathWorkaroundInstall {
	# TODO DEBUG REMOVE: work around limitations in jq's `import` resolving algorithm.
	# Current jq assumes the main package path for package P is `P/basename(P).jq`.
	if hasValidPackageMainJq;
	then
		local originalMainPath=$(getValidPackageMainJq)
		local jqMainPathWorkaroundTarget=$(getJqMainPathWorkaroundTarget)
		local jqMainPathWorkaroundTargetDirectory=$(dirname "$jqMainPathWorkaroundTarget")

		debugInPackageIfAvailable 2 "(jq workaround: main script) Copying real main script: '$(echo "$originalMainPath" | replaceHomeWithTilde)' to '$(echo "$jqMainPathWorkaroundTarget" | replaceHomeWithTilde)'"

		mkdir -p "$jqMainPathWorkaroundTargetDirectory"
		cp "$originalMainPath" "$jqMainPathWorkaroundTarget"
	fi

	return 0;
}
