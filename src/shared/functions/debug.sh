function isDebugAtLevel {
	(( "$#" < 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	# TODO: output debug message level.
	# 0 fatal
	# 1 errors
	# 2 warnings
	# 3 information
	# 4 debug
	# 5 verbose

	if (( ${JQNPM_DEBUG_LEVEL:-2} >= $messageLevel ));
	then
		return 0;
	fi

	return 1;
}

function debug {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	isDebugAtLevel "$messageLevel" && echo -E "jqnpm:" "$@" >&2

	return 0;
}

function debugInPackageIfAvailable {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	if hasPackageMetadataFile;
	then
		debugInPackage "$messageLevel" "[$(getPackageName)]" "$@"
	else
		debug "$messageLevel" "$@"
	fi

	return 0;
}

function debugInPackage {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	debug "$messageLevel" "[$(getPackageName)]" "$@"

	return 0;
}

function die {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i exitcode="$1"
	shift

	debug 0 "$@"
	exit "$exitcode"
}
