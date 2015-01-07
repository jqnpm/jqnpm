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
