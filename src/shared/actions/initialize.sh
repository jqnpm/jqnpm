function initialize {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"

	local failed="false"

	if isInsidePackageWithRoot;
	then
		local localPackageRoot=$(getLocalPackageRoot)

		failed="true"

		debug 1 "is this already a package? Found nearest package root '${packageMetadataDirectoryName}/' in '$(echo -nE "$localPackageRoot" | replaceHomeWithTilde)' starting in '$(echo -nE "$PWD" | replaceHomeWithTilde)'"
	fi

	if hasPackageMetadataFile;
	then
		local nearestJqJson="$(getNearestJqJson)"

		failed="true"

		debug 1 "is this already a package? Found nearest metadata file '${packageMetadataFilename}' '$(echo -nE "$nearestJqJson" | replaceHomeWithTilde)' starting in '$(echo -nE "$PWD" | replaceHomeWithTilde)'"
	fi

	if [[ "$failed" != "false" ]];
	then
		die 1 "stopping due to previous errors."
	fi

	createMinimalJqJsonIfNecessary
	createPackageRootIfNecessary
	createMinimalMainJqIfNecessary
}
